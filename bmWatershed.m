function y = bmWatershed( x, mark, conn )
% function y = bmWatershed( x, mark, conn )
% Performs the watershed transform using the connected component approach
% as presented in [1]. 'x' is the DEM, must be double and with no '+/-inf'
% values. 'mark' is the optional marker map (default []). 'conn' specifies
% watershed connectivity (default 8, alternative 4).
%
% [1] Bieniek, A., & Moga, A. (2000). An efficient watershed algorithm 
% based on connected components. Pattern Recognition, 33(6), 907–916.
% http://www.sciencedirect.com/science/article/pii/S0031320399001545
%
