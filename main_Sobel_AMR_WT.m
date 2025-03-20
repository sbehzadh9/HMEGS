%Please cite the paper "Tao Lei, Xiaohong Jia,Tongliang Liu,Shigang Liu,Hongying Meng,and Asoke K. Nandi, 
%Adaptive Morphological Reconstruction for Seeded Image Segmentation,2019"
%The code was written by Tao Lei and Xiaohong Jia in 2018.

clear all
close all
addpath('.\code\');
f_ori=imread('2018.jpg'); 


% Note that you can repeat the program for several times to obtain the best
% segmentation result for image '12003.jpg'
%% you can choose a simple filter, e.g., a gaussian filter.
%sigma=1.0;gausFilter=fspecial('gaussian',[5 5],sigma);g=imfilter(f_ori,gausFilter,'replicate');
%% compute gradient image
gg=rgb2lab(f_ori); 
tic
a1=sgrad_edge(normalized(gg(:,:,1))).^2;
b1=sgrad_edge(abs(normalized(gg(:,:,2)))).^2;
c1=sgrad_edge(normalized(gg(:,:,3))).^2;
ngrad_f1=sqrt(a1+b1+c1);
%% image segmentation using AMR-WT
r_g=w_recons_adaptive(ngrad_f1,3); % AMR
behzad=EdgeMarkFillPlus(f_ori,3,100,r_g);
% secondRecons=w_recons_adaptive(behzad,1);
% three=r_g+(behzad(:,:)>0);

L=watershed(behzad);
toc
L_seg=Label_image_fast(f_ori,L,2,[255,0,0]);
figure,imshow(L_seg);

L2=watershed(r_g);
L_seg2=Label_image_fast(f_ori,L2,2,[255,0,0]);
figure,imshow(L_seg2); 