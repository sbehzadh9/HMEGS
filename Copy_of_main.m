%Please cite the paper "Tao Lei, Xiaohong Jia,Tongliang Liu,Shigang Liu,Hongying Meng,and Asoke K. Nandi, 
%Adaptive Morphological Reconstruction for Seeded Image Segmentation,2019"
%The code was written by Tao Lei and Xiaohong Jia in 2018.

clear all;
close all;
addpath('.\code\');

% f_ori=imread('.\all\*.jpg'); 
imgDir = '.\images';
imgTruSegDir = '.\groundTruth';


% images = dir(fullfile(imgDir,'*.jpg'));
images = dir(fullfile(imgDir,'3096.jpg'));
trueSeg = dir(fullfile(imgTruSegDir,'3096.mat'));

%  makedSeg=dir(fullfile('.\myresult','*.mat'));

for i=1: numel(images)
    
f_ori = imread(fullfile(imgDir, strcat(images(i).name(1:end-4), '.jpg')));
f_ori_groundTrue = fullfile(fullfile(imgTruSegDir, strcat(trueSeg(i).name(1:end-4), '.mat')));
groundTruth = load(f_ori_groundTrue, 'groundTruth');
groundTruth = groundTruth.groundTruth;
groundTruth = groundTruth(1);
groundTruthGray=mat2gray(groundTruth{1, 1}.Segmentation);

% Note that you can repeat the program for several times to obtain the best
% segmentation result for image '12003.jpg'
%% you can choose a simple filter, e.g., a gaussian filter.
% sigma=1.0;gausFilter=fspecial('gaussian',[5 5],sigma);gg=imfilter(f_ori,gausFilter,'replicate');
%% compute gradient image
gg=rgb2lab(f_ori); 
% subplot(2,3,1);
% imshow(f_ori);
% title('source image Rbg');
% 
% 
% subplot(2,3,2);
% imshow(gg);
% title('source image L*A*B');
% 
% 
% subplot(2,3,3);
% imshow(gg(:,:,1));
% title('gg(:,:,1)= L* for the lightness from black (0) to white (100)');
% 
% 
% subplot(2,3,4);
% imshow(gg(:,:,2));
% title('gg(:,:,2)= a* from green (?) to red (+)');
% 
% 
% subplot(2,3,5);
% imshow(gg(:,:,3));
% title('gg(:,:,3)= b* from blue (?) to yellow (+)');
% 
% 
% 
% 
% 
% 
% figure;
% subplot(2,3,1);
% imshow(f_ori);
% title('source image');
% tic
 a1=sgrad_edge(normalized(gg(:,:,1))).^2; 
% subplot(2,3,2);
% imshow(a1);
% title('a1');
% b1=sgrad_edge(abs(normalized(gg(:,:,2)))).^2;
% subplot(2,3,3);
% imshow(b1);
% title('b1');
% 
% c1=sgrad_edge(normalized(gg(:,:,3))).^2;
% subplot(2,3,4);
% imshow(c1);
% title('c1');

ngrad_f1=sqrt(a1+b1+c1);

subplot(2,3,5);
imshow(ngrad_f1);
title('ngrad_f1(gradian image)');


%% image segmentation using AMR-WT
r_g=w_recons_adaptive(ngrad_f1,3); % AMR

originAmr=r_g;
index=find(ngrad_f1 >((max(max(ngrad_f1))+ mean(mean(ngrad_f1)))/4));
r_g(index)=ngrad_f1(index);

AmrSeeds=imregionalmin(r_g);

behzadW1=EdgeMarkFillPlusv1(f_ori,3,100,r_g,AmrSeeds);
behzadW2=EdgeMarkFillPlusv2(f_ori,3,100,r_g,AmrSeeds);

Emf=EdgeMarkFillPlus(f_ori,3,100,r_g);

figure,imshow(f_ori);
title('SourceImage');

L5=watershed(behzadW1);
toc
L_seg5=Label_image_fast(f_ori,L5,2,[255,0,0]);
figure,imshow(L_seg5);
title('MySolution1 Segmentation');

L=watershed(behzadW2);
toc
L_seg=Label_image_fast(f_ori,L,2,[255,0,0]);
figure,imshow(L_seg);
title('MySolution2 Segmentation');

L3=watershed(Emf);
L_seg3=Label_image_fast(f_ori,L3,2,[255,0,0]);
figure,imshow(L_seg3);
title('Emf+ Segmentation');

L2=watershed(originAmr);
L_seg2=Label_image_fast(f_ori,L2,2,[255,0,0]);
figure,imshow(L_seg2); 
title('Amr Segmentation');

figure;
imshow(groundTruthGray);
title('Ground Truth Segmentation');


L=rgb2gray(L_seg);
labeled=L;

segs=cell(1,1);
segs{1}=labeled;


segoutstor=strcat('.\myresult\',images(i).name(1:end-4),'.mat');
save(segoutstor,'segs');
end
%imwrite(label2rgb(result),filename);
%save('.\myresult\a.mat','t');
