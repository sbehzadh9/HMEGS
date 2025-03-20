%Please cite the paper "Tao Lei, Xiaohong Jia,Tongliang Liu,Shigang Liu,Hongying Meng,and Asoke K. Nandi, 
%Adaptive Morphological Reconstruction for Seeded Image Segmentation,2019"
%The code was written by Tao Lei and Xiaohong Jia in 2018.
clc ;
clear all;
close all;
addpath('.\code\');
f_ori=imread('.\all\12003.jpg'); 
% Note that you can repeat the program for several times to obtain the best
% segmentation result for image '12003.jpg'
g=load('.\SE_grad\12003.mat');
tic
%% image segmentation using AMR-WT
r_g=w_recons_adaptive(g.E,2); 
% AMR
behzad=EdgeMarkFillPlus(f_ori,3,100,r_g);

% secondRecons=w_recons_adaptive(behzad,3);
three=r_g+behzad;

L=watershed(behzad);
toc
L_seg=Label_image_fast(f_ori,L,2,[255,0,0]);
figure,imshow(L_seg);  

L2=watershed(r_g);
L_seg2=Label_image_fast(f_ori,L2,2,[255,0,0]);
figure,imshow(L_seg2);  