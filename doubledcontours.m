function y = doubledcontours(x,conn);
% function y = doubledcontours(x,conn);
% Extract contour map from segmentation. 'conn' specify the connexity (can
% be 4 or 8). Contour is 2-pixel large. If any zeros in the map, they are
% not counted for contour extraction (0-region is background).
%
if nargin == 1,
    conn = 8;
end

t = padarray(x,[1 1],0,'both');

t1 = (x-t(1:end-2,2:end-1)) ~= 0 & x ~= 0 & t(1:end-2,2:end-1) ~= 0; %N
t1 = t1 | ((x-t(2:end-1,1:end-2)) ~= 0 & x ~= 0 & t(2:end-1,1:end-2) ~= 0); %W
t1 = t1 | ((x-t(3:end,2:end-1)) ~= 0 & x ~= 0 & t(3:end,2:end-1) ~= 0); %S
t1 = t1 | ((x-t(2:end-1,3:end)) ~= 0 & x ~= 0 & t(2:end-1,3:end) ~= 0); %E

if conn==8,
    t1 = t1 | (x-t(1:end-2,1:end-2)) ~= 0 & x ~= 0 & t(1:end-2,1:end-2) ~= 0; %NW
    t1 = t1 | ((x-t(1:end-2,3:end)) ~= 0 & x ~= 0 & t(1:end-2,3:end) ~= 0); %NE
    t1 = t1 | ((x-t(3:end,1:end-2)) ~= 0 & x ~= 0 & t(3:end,1:end-2) ~= 0); %SW
    t1 = t1 | ((x-t(3:end,3:end)) ~= 0 & x ~= 0 & t(3:end,3:end) ~= 0); %SE
end

y = double(t1>0);
