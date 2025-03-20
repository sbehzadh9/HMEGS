%Please cite the paper "Tao Lei, Xiaohong Jia,Tongliang Liu,Shigang Liu,Hongying Meng,and Asoke K. Nandi, 
%Adaptive Morphological Reconstruction for Seeded Image Segmentation,2019"
%The code was written by Tao Lei and Xiaohong Jia in 2018.
clc ;
clear all;
close all;
addpath('.\code\');


imgDir = '.\images';
imgSESegDir = '.\SE_grad';


% images = dir(fullfile(imgDir,'*.jpg'));
images = dir(fullfile(imgDir,'*.jpg'));
SeSegmen = dir(fullfile(imgSESegDir,'*.mat'));

for i=1: numel(images)
    
f_ori=imread(fullfile(imgDir, strcat(images(i).name(1:end-4), '.jpg')));
% Note that you can repeat the program for several times to obtain the best
% segmentation result for image '12003.jpg'
f_ori_SeSeg = fullfile(fullfile(imgSESegDir, strcat(images(i).name(1:end-4), '.mat')));

g= load(f_ori_SeSeg);

tic
%% image segmentation using AMR-WT
r_g=w_recons_adaptive(g.segs{1, 1},2); 
% AMR

% AmrSeeds=imregionalmin(r_g);

% behzad=EdgeMarkFillPlusv1(f_ori,3,100,r_g,AmrSeeds);

% L=watershed(behzad);
% toc
% L_seg=Label_image_fast(f_ori,L,2,[255,0,0]);
% figure,imshow(L_seg);  



L2=watershed(r_g);
L_seg2=Label_image_fast(f_ori,L2,0,[255,0,0]);
% figure,imshow(L_seg2);  


L=rgb2gray(L_seg2);

%labeled=bwlabel(L);
labeled=L;

segs=cell(1,1);
segs{1}=L_seg2(:,:,1);


segoutstor=strcat('.\myresult\',images(i).name(1:end-4),'.mat');
save(segoutstor,'segs');

end;