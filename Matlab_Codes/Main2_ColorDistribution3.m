%Reference
yellow [1 1 0]
magenta [1 0 1]
cyan [0 1 1]
red [1 0 0]
green [0 1 0]
blue [0 0 1]
white [1 1 1]
black [0 0 0]
%%
[m n1 n]=size(OriginalImage);
for k=1:n
red{k}=zeros(m,n1);
green{k}=zeros(m,n1);
blue{k}=zeros(m,n1);
for i=1:m
    for j=1:n1      
        if AirOnly(i,j,k)~=0
            red{k}(i,j)=1;
            green{k}(i,j)=1;
            blue{k}(i,j)=1;
        elseif GrainOnly(i,j,k)~=0
            red{k}(i,j)=0;
            green{k}(i,j)=0;
            blue{k}(i,j)=0;
        elseif FinalWater(i,j,k)~=0
            red{k}(i,j)=1;
            green{k}(i,j)=0;
            blue{k}(i,j)=0;
        elseif AirGrain_Interface(i,j,k)~=0
            red{k}(i,j)=0;
            green{k}(i,j)=0;
            blue{k}(i,j)=1; 
        elseif AirWater_Interface(i,j,k)~=0
            red{k}(i,j)=0;
            green{k}(i,j)=1;
            blue{k}(i,j)=0; 
        elseif GrainWater_Interface(i,j,k)~=0
            red{k}(i,j)=1;
            green{k}(i,j)=1;
            blue{k}(i,j)=0;            
        end
    end
end
Color_image{k} = cat(3, red{k}, green{k}, blue{k});
Directory='';
imwrite(Color_image{k},sprintf('%s%03d.tif', Directory, k))
end