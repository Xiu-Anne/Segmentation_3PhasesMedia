function Std=StandardDeviation_3(Component,Original_Image)
Image=Original_Image.*uint16(Component);
MoyenGray=sum(sum(sum(Image)))/nnz(Image);
Std=sqrt(sum(sum(sum(uint64(Image).^2)))/nnz(Image) - MoyenGray^2);
end