function markers = DilateSeeds(seed, dist)
% function markers = DilateSeeds(seed, dist)
% EMF auxiliary function for circle dilation of DEM minima (seeds).
% dist - distance of markers from edges.
%
markers = zeros(size(seed));

% Seed dilation
if max(seed(:)) > dist
    for i=dist:max(seed(:))
        es = CircularStrel(double(i)-dist);
        mask = seed == i;
        markers = or(markers, imdilate(mask,es));
    end
end
markers = or(markers, seed);
