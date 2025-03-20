function [y, mns] = mapmeansv3(img,map);
% function y = mapmeansv3(img,map);
% Computes regional means and generates the means image
% Uses the multi-channel image 'img' and the segmentation 'map'
% Handles both binary images or segmentation maps.
% mns contain means for each region in a vector.
%
[R, C, B] = size(img);
y = zeros(R,C,B);

if nonzeroclass(map) == 1,
    for i=1:B,
        mns = regionprops(logical(map),img(:,:,i),'MeanIntensity');
        mns = [0; cat(1,mns.MeanIntensity)];
        y(:,:,i) = mns(bwlabel(map)+1);
    end
else
    for i=1:B,
        mns = regionprops(map,img(:,:,i),'MeanIntensity');
        if sum(map==0)>0,
            mns = [0; cat(1,mns.MeanIntensity)];
            y(:,:,i) = mns(map+1);
        else
            mns = cat(1,mns.MeanIntensity);
            y(:,:,i) = mns(map);
        end
    end
end
