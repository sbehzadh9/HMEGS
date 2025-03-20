function y = percentile(x,p)
%PERCENTILE computes the percentile of input data
%   y = percentile(x,p)
%   Computes the p percentile of x
%   It works if p is an array

if sum(p<0)
    error('The percentile must be >=0, while it is %1.2f\n',p);
end
if sum(p>100)
    error('The percentile must be <=100, while it is %1.2f\n',p);
end

data = sort(x(:));
index = floor(length(data)*p/100)+1;
index(index>length(data)) = length(data);
y = data(index);
