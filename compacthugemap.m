function [y, corr] = compacthugemap(map,start);
%function y = compacthugemap(map,start);
% Compacts values of a label map into a full integer range
% start must be >= 0, lowest map value is labeled as 'start'.

if (min(min(map)) < 1),
    map = map + abs(min(min(map))) + 1; 
end
lbl = (-1)*ones(max(max(map)),1);
r = size(map,1); c = size(map,2);

lbl(min(map(:))) = start;
k = start;

for i=1:r
    for j=1:c
        if (lbl(map(i,j))==-1) 
            k = k+1;
            lbl(map(i,j)) = k;
        end
    end
end

y = zeros(r,c);

for i=1:r
    for j=1:c
        y(i,j) = lbl(map(i,j));
    end
end

if nargout == 2,
    corr = find(lbl>0);
end
