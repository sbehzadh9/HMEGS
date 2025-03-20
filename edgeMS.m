function edges = edgeMS(ms)
% function edges = edgeMS(ms)
% Performs edge detection on multispectral images. Canny is used 
% with default parameters.
% - ms       : multispectral image
%
% For earlier Matlab versions than R2013a, replace 'canny_old' by 'canny'
%
dims = size(ms);
rows = dims(1); cols = dims(2); 
if numel(dims)==2 
    bands = 1;
else
    bands = dims(3);
end

edges_band = zeros(dims);
edges = zeros(rows, cols);
for b=1:bands
    edges_band(:,:,b) = edge(ms(:,:,b), 'canny_old');
    edges = or(edges, edges_band(:,:,b));
end
if bands > 1,
    edges = bwmorph(edges, 'thin', inf);

end
