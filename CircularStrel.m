function y = CircularStrel(radius);
%function y = CircularStrel(radius);
% Generate a full circular structuring element using the Bresenham
% algorithm. 'radius' specify the circle radius in pixels.
%
radius = radius+1;

y = zeros(2*radius-1);

f = 1-radius;
ddF_i = 1;
ddF_j = -2 * radius;
i = 0;
j = radius-1;

y(radius,:) = 1;
y(:,radius) = 1;

while i < j,
    if f >= 0,
        j = j - 1;
        ddF_j = ddF_j + 2;
        f = f + ddF_j;
    end
    i = i + 1;
    ddF_i = ddF_i + 2;
    f = f + ddF_i;
    y(radius-i:radius+i,radius+j) = 1;
    y(radius-i:radius+i,radius-j) = 1;
    y(radius-j:radius+j,radius+i) = 1;
    y(radius-j:radius+j,radius-i) = 1;
end
