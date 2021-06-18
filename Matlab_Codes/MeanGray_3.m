function MoyenGray=MeanGray_3(Component,Original_Image)
Image=Original_Image.*uint16(Component);
MoyenGray=sum(sum(sum(Image)))/nnz(Image);
end