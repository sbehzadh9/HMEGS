function [y, mse] = regionalMSE(img,map);
% function [y, mse] = regionalMSE(img,map);
% Computes regional variances and generates the means image
% Uses the multi-channel image 'img' and the segmentation 'map'
% Handles both binary images or segmentation maps.
% If specified, mse contains the histogram of MSEs.
%
mns = mapmeansv3(img,map);
if nonzeroclass(map) == 1,
    tmpimg = zeros(size(img));
    for i=1:size(img,3),
        tmpimg(:,:,i) = double(img(:,:,i)) .* map;
    end
else
    tmpimg = double(img);
end
tmp = (mns - tmpimg).^2;
[tmpmse, mse] = mapmeansv3(tmp,map);
y = sum(tmpmse,3);
