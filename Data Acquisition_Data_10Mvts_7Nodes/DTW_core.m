function [match]=DTW_core(s,t)
size_t=size(t,2);
size_s=size(s,2);
my_DTW=zeros(size_t,size_s);
for i=1:size_t
    for j=1:size_s
        dist=double(floor(norm(t(:,i)-s(:,j))^1));
        if (and((i==1),(j==1)))
            my_DTW=dist;
        elseif (i==1)
            my_DTW(i,j)=dist+my_DTW(i,j-1);
        elseif (j==1)
            my_DTW(i,j)=dist+my_DTW(i-1,j);
        else
            my_DTW(i,j)=dist+min([my_DTW(i,j-1),my_DTW(i-1,j),my_DTW(i-1,j-1)]);
        end
               
    end
end
match=my_DTW(size_t,size_s);