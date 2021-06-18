function a_WS=GrainCorrection3(a,v)
D = -bwdist(~a);
%figure,imshow(D,[])
mask = imextendedmin(D,v);% filter out tiny local minima (computes the extended-minima transform)
%figure,imshowpair(a,mask,'blend')
WS = imimposemin(D,mask); %modify the distance transform so that no minima occur at the filtered-out locations - "minima imposition"
WS = watershed(WS);
a(WS == 0) = 0;
a_WS=a;
%figure,imshow(a_WS), title('Corrected Grains')
end
