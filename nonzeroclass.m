function [n,c,numel] = nonzeroclass(map)

sz = size(map); r = sz(1); c = sz(2);

numel = zeros(1,max(max(map)));

for i=1:r
    for j=1:c
        if (map(i,j)>0) numel(map(i,j)) = numel(map(i,j))+ 1;
        end
    end
end

c = find(numel>0);
n = length(c);
