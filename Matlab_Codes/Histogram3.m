function Histogram3(OriginalImage,a)
h = histogram(OriginalImage.*uint16(a),'BinWidth',20)
[m n]=size(h.BinEdges);
for i=1:n-1
    R(i,1)=h.BinEdges(1,i);%
    R(i,2)=h.BinCounts(1,i);
end
[m_R n_R]=size(R);
maxy=0;
for i=2:m_R
    if R(i,2)>maxy
        maxy=R(i,2);
    end
end
Y_R=find(R(:,2));% find indice and values of non zero elements, first n indices...; even for other conditions; 
[m_Y_R n_Y_R]=size(Y_R);
x1_R=R(Y_R(2),1);
x2_R=R(Y_R(m_Y_R),1);
plot(R(:,1),R(:,2),'Color','black','LineWidth',2,'LineStyle','-')
xlabel('Gray level')
ylabel('Counts')
axis([x1_R x2_R 0 maxy])
gca.XAxis.LineWidth=3;
gca.YAxis.LineWidth=3;
end

