clear; clc
close all; imtool close all
%% %%%%%%%%%%%%%%%%%%%%%Open sequence images =)) 3D images
% Read image sequences
cd('');
lists=dir('*.tif');% list all files in folder in form of .tif
n=numel(lists);% number of array contents
Directory = '\slice';
i1=600;
i2=649;
for i=i1:i2
fname{i-i1+1}= sprintf('%s%05d.tif', Directory, i);
I{i-i1+1}=imread(fname{i-i1+1});
end
%% 3D images
[m n1]=size(I{1,1});
Im=[];
for i=1:(i2-i1)+1% Number of 2Dimages
    for j=1:m
        for k=1:n1
            Im(j,k,i)=I{1,i}(j,k);
        end
    end
end
OriginalImage=Im;
vtkwrite('\OriginalImage.vtk','structured_points', 'OriginalImage',OriginalImage);
%% %%%%%%%%%%%%%%%%%%%%%AirOnly+GrainOnly
%% Original image_Filtered
OriginalImage_Filtered=medfilt3(OriginalImage);
%% Air Only _ Grain Only for Filted image
G1_F=13946;
G2_F=16202;
%%%%%%%%Air
AirOnly_Filtered=OriginalImage_Filtered<G1_F;
%%%%%%%%Grain
GrainOnly_Filtered=OriginalImage_Filtered>G2_F;
%% Filtered image is chosen
AirOnly=AirOnly_Filtered;
AirOnly_Gray=OriginalImage.*double(AirOnly);
vtkwrite('\AirOnly.vtk','structured_points', 'AirOnly',AirOnly_Gray);
GrainOnly=GrainOnly_Filtered;
GrainOnly_Gray=OriginalImage.*double(GrainOnly);
vtkwrite('\GrainOnly.vtk','structured_points', 'GrainOnly',GrainOnly_Gray);
%% Correct GrainOnly
GrainOnly_C=GrainCorrection3(GrainOnly,15);
GrainOnly_C=imfill(GrainOnly_C,'holes');
GrainOnly_C_Gray=OriginalImage.*double(GrainOnly_C);
vtkwrite('\GrainOnly_C.vtk','structured_points', 'GrainOnly_C',GrainOnly_C_Gray);
%% 
GrainOnly=GrainOnly_C;
GrainOnly_Gray=OriginalImage.*double(GrainOnly);
vtkwrite('\GrainOnly.vtk','structured_points', 'GrainOnly',GrainOnly_Gray);
%% Check AirOnly, GrainOnly
se=strel('sphere',1);
figure,Histogram3(OriginalImage,AirOnly)
figure,Histogram3(OriginalImage,imerode(AirOnly,se))
figure,Histogram3(OriginalImage,GrainOnly)
figure,Histogram3(OriginalImage,imerode(GrainOnly,se))
%%%%%Moyen Gray, Std Calculation
OriginalImage_Compare=[OriginalImage OriginalImage OriginalImage OriginalImage];
Compare=[AirOnly imerode(AirOnly,se) GrainOnly imerode(GrainOnly,se)];
Compare=OriginalImage_Compare.*double(Compare);
[m n1 n]=size(OriginalImage);
[m0 n10 n0]=size(Compare);
No=n10/n1;
MoyenGray_Compare=Moyen_Calculation3(No,m,n1,n,Compare)
StandardDeviaion_Compare=StandardDeviation_Calculation3(No,m,n1,n,Compare)
%% %%Optional
se=strel('sphere',1);
AirOnly=imerode(AirOnly,se);
AirOnly_Gray=OriginalImage.*double(AirOnly);
vtkwrite('\AirOnly.vtk','structured_points', 'AirOnly',AirOnly_Gray);
%GrainOnly=imerode(GrainOnly,se);
%% Water is the rest
WaterAll=(OriginalImage-OriginalImage.*double(GrainOnly)-OriginalImage.*double(AirOnly))>0;
AirGrain_Gray=OriginalImage.*double(AirOnly+GrainOnly);
vtkwrite('\AirGrain.vtk','structured_points', 'AirGrain',AirGrain_Gray);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Air grain interface 
%% Air grain interface 
% Dilate AirOnly and GrainOnly
se=strel('sphere',2);
AirOnly_Dilate=imdilate(AirOnly,se);
se=strel('sphere',2);
GrainOnly_Dilate=imdilate(GrainOnly,se);
% Find Interfaces
AirGrain_Interface=and(AirOnly_Dilate,GrainOnly_Dilate);
AirGrain_Interface=AirGrain_Interface - and(AirOnly,AirGrain_Interface);
AirGrain_Interface=AirGrain_Interface - and(GrainOnly,AirGrain_Interface);
AirGrainInterface_Gray=OriginalImage.*double(AirOnly+GrainOnly+AirGrain_Interface);
vtkwrite('\AirGrainInterface.vtk','structured_points', 'AirGrainInterface',AirGrainInterface_Gray);
%% Dilate Air grain interface 
se=strel('disk',1);
AirGrain_Interface_Dilate=imdilate(AirGrain_Interface,se);
AirGrain_Interface_Dilate=AirGrain_Interface_Dilate - and(AirOnly,AirGrain_Interface_Dilate);
AirGrain_Interface_Dilate=AirGrain_Interface_Dilate - and(GrainOnly,AirGrain_Interface_Dilate);
%% Intersect
se=strel('sphere',3);
AirOnly_Dilate=imdilate(AirOnly,se);
se=strel('sphere',3);
GrainOnly_Dilate=imdilate(GrainOnly,se);
AirGrain_Interface_N=AirGrain_Interface+and(AirGrain_Interface_Dilate-AirGrain_Interface,and(AirOnly_Dilate,GrainOnly_Dilate));
AirGrainInterface_N_Gray=OriginalImage.*double(AirOnly+GrainOnly+AirGrain_Interface_N);
vtkwrite('\AirGrainInterface_N.vtk','structured_points', 'AirGrainInterface_N',AirGrainInterface_N_Gray);
%% Choice of Air grain interface 
%AirGrain_Interface=AirGrain_Interface;
AirGrain_Interface=AirGrain_Interface_N;
AirGrain_Interface_Gray=OriginalImage.*double(AirGrain_Interface);
vtkwrite('\AirGrain_Interface.vtk','structured_points', 'AirGrain_Interface',AirGrain_Interface_Gray);
WaterWithoutAirGrain_Interface=WaterAll-AirGrain_Interface;
AirGrainInterface_Gray=OriginalImage.*double(AirGrain_Interface)+OriginalImage.*double(AirOnly)+OriginalImage.*double(GrainOnly);
vtkwrite('\AirGrainInterface.vtk','structured_points', 'AirGrainInterface',AirGrainInterface_Gray);
%WaterWithoutAirGrainInterface=WaterAll-AirGrainInterface;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Water and 2 other interfaces
%% Extract 2 other interfaces (WA,WG) and WAG from water
se=strel('sphere',2);
AirOnly_Dilate=imdilate(AirOnly,se);
se=strel('sphere',2);
GrainOnly_Dilate=imdilate(GrainOnly,se);
AirWater_Interface=and(AirOnly_Dilate,WaterWithoutAirGrain_Interface);
GrainWater_Interface=and(GrainOnly_Dilate,WaterWithoutAirGrain_Interface);
WaterOnly = WaterWithoutAirGrain_Interface - AirWater_Interface - GrainWater_Interface;
%% %%%%%%%%%%%%%%%Re-determine water
figure,Histogram3(OriginalImage,WaterOnly)
%% Strict water zone
S1=1.5*10^4;
S2=1.6*10^4;
se_e=1;
se_d=1;
a=and(OriginalImage.*double(WaterOnly)>S1,OriginalImage.*double(WaterOnly)<S2);
se=strel('sphere',se_e);
b=imerode(a,se);
se=strel('sphere',se_d);
c=imdilate(b,se);
%% Final water zone
Coeff=1;
%%%%%Moyen Gray Calculation
OriginalImage_ma=[OriginalImage OriginalImage OriginalImage];
ma=[a b c];
ma=OriginalImage_ma.*double(ma);
[m n1 n]=size(OriginalImage);
[m0 n10 n0]=size(ma);
No=n10/n1;
MoyenGray_ma=Moyen_Calculation3(No,m,n1,n,ma)
StandardDeviaion_ma=StandardDeviation_Calculation3(No,m,n1,n,ma)
%% b_2,c_3
FinalWater=b; 
figure,Histogram3(OriginalImage,FinalWater)
Water_Moyen=MoyenGray_ma(2);
Water_StandardDeviaion=StandardDeviaion_ma(2);
WaterOnly=WaterOnly-FinalWater;
W=and(OriginalImage.*double(WaterOnly)>Water_Moyen-Coeff*Water_StandardDeviaion,OriginalImage.*double(WaterOnly)<Water_Moyen+Coeff*Water_StandardDeviaion);
FinalWater=FinalWater+W;
figure,Histogram3(OriginalImage,FinalWater)
FinalWater_Gray=OriginalImage.*double(FinalWater);
vtkwrite('\FinalWater.vtk','structured_points', 'FinalWater',FinalWater_Gray);
%% %%%%%%%%%%%%%%%Re-determine AW,GW interfaces
WaterOnly=WaterOnly-FinalWater;
Reste=OriginalImage.*double(WaterOnly);
%
Addition_AirWater_Interface=and(Reste<Water_Moyen,Reste>0);
AirWater_Interface=AirWater_Interface+Addition_AirWater_Interface;
Addition_GrainWater_Interface=Reste>Water_Moyen;
GrainWater_Interface=GrainWater_Interface+Addition_GrainWater_Interface;
%
AirWater_Interface_Gray=OriginalImage.*double(AirWater_Interface);
vtkwrite('\AirWater_Interface.vtk','structured_points', 'AirWater_Interface',AirWater_Interface_Gray);
GrainWater_Interface_Gray=OriginalImage.*double(GrainWater_Interface);
vtkwrite('\GrainWater_Interface.vtk','structured_points', 'GrainWater_Interface',GrainWater_Interface_Gray);
AirWaterInterface_Gray=OriginalImage.*double(AirOnly+FinalWater+AirWater_Interface);
vtkwrite('\AirWaterInterface.vtk','structured_points', 'AirWaterInterface',AirWaterInterface_Gray);
GrainWaterInterface_Gray=OriginalImage.*double(GrainOnly+FinalWater+GrainWater_Interface);
vtkwrite('\GrainWaterInterface.vtk','structured_points', 'GrainWaterInterface',GrainWaterInterface_Gray);
%% %%%%%%%%%%%%%%%%%%%%%%Accumulation
Component=[AirOnly GrainOnly AirGrain_Interface AirWater_Interface GrainWater_Interface FinalWater] ;
OriginalImage_Gray=[OriginalImage OriginalImage OriginalImage OriginalImage OriginalImage OriginalImage];
MoyenGray_Calculation=OriginalImage_Gray.*double(Component);
[m0 n10 n0]=size(Component);
[m n1 n]=size(OriginalImage);
No=n10/n1;
%%%%%%%%%% Calculate propotion of each phase and interfaces
%%
Percent=Percentage_Calculation3(No,m,n1,n,Component)
MoyenGray=Moyen_Calculation3(No,m,n1,n, MoyenGray_Calculation)
StandardDeviaion=StandardDeviation_Calculation3(No,m,n1,n, MoyenGray_Calculation)
%% Redistribute: AirGrain_Interface AirWater_Interface GrainWater_Interface AirGrainWater_Interface
syms x y
[x12,x21]=solve([x+y==1, MoyenGray(1)*x+MoyenGray(2)*y==MoyenGray(3)], [x, y]);
[x13,x31]=solve([x+y==1, MoyenGray(1)*x+MoyenGray(6)*y==MoyenGray(4)], [x, y]);
[x23,x32]=solve([x+y==1, MoyenGray(2)*x+MoyenGray(6)*y==MoyenGray(5)], [x, y]);
Air=vpa(Percent(1)+x12*Percent(3)+x13*Percent(4),2);
Grain=vpa(Percent(2)+x21*Percent(3)+x23*Percent(5),2);
Water=vpa(Percent(6)+x31*Percent(4)+x32*Percent(5),2);
Porosity=vpa((Air+Water)/(Air+Water+Grain),3)
Saturation=vpa(Water/(Air+Water)*100,3)
%% 2D Final Water 
[m n1 n]=size(OriginalImage);
for k=1:n
for i=1:m
    for j=1:n1
    FinalWater_2D{k}(i,j) = FinalWater(i,j,k);     
    end
end 
WithoutFinalWater{k} = I{1,k}-I{1,k}.*uint16(FinalWater_2D{k}); 
Directory='FinalWater\';
imwrite(WithoutFinalWater{k},sprintf('%s%03d.tif', Directory, k))
end