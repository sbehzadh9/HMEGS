clear all;
close all;
clear;
addpath('.\code\');

% Define directories
imgDir = '.\images';
imgTruSegDir = '.\groundTruth';
outputFolder = '.\savedFigures\';
resultFolder = '.\myresult\';

% Create output folders if they do not exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
if ~exist(resultFolder, 'dir')
    mkdir(resultFolder);
end

%%%%%%% Get all image files in the images folder
% imageFiles = dir(fullfile(imgDir, '*.jpg'));

%%%%%%% Running the codes on one image
imageFiles(1).name = '384022.jpg';

% Loop through each image in the folder

for i = 1:numel(imageFiles)
    % Get image name without extension (e.g., "384022")
    [~, baseName, ~] = fileparts(imageFiles(i).name);
    fprintf('Processed image: %s\n', baseName);
    % Load the corresponding ground truth file (e.g., ".\groundTruth\384022.mat")
    gtFile = fullfile(imgTruSegDir, [baseName, '.mat']);
    if ~exist(gtFile, 'file')
        fprintf('Ground truth file for %s not found. Skipping...\n', baseName);
        continue; % Skip if the ground truth file doesn't exist
    end
    %{
    data = load(gtFile);
    gt = data.groundTruth;  % Extract ground truth cell array
    num_gt = numel(gt);     % Number of ground truth segmentations

    % Create and save a figure for ground truth segmentations
    hFigGT = figure;
    for j = 1:num_gt
        gt_entry = gt{j};           % Access each segmentation
        subplot(1, num_gt, j);       % Arrange in a row
        imshow(label2rgb(gt_entry.Segmentation));
        title(['Segmentation ', num2str(j)]);
    end
    sgtitle(['Ground Truth for ', baseName]);
    saveas(hFigGT, fullfile(outputFolder, [baseName, '_GroundTruthSegmentations.png']));
    close(hFigGT);
    %}

    % Read the original image
    f_ori = imread(fullfile(imgDir, imageFiles(i).name));
    
    %% Compute gradient image in LAB space
    gg = rgb2lab(f_ori); 
    a1 = sgrad_edge(normalized(gg(:,:,1))).^2; 
    b1 = sgrad_edge(abs(normalized(gg(:,:,2)))).^2;
    c1 = sgrad_edge(normalized(gg(:,:,3))).^2;
    ngrad_f1 = sqrt(a1 + b1 + c1);
    
    %% Image segmentation using AMR-WT
    r_g = w_recons_adaptive(ngrad_f1, 3); % AMR segmentation
    a_copy_R_G = r_g;
    
    L0 = watershed(r_g);
    L_seg = Label_image_fast(f_ori, L0, 2, [255,0,0]);
    
    originAmr = r_g;
    index = find(ngrad_f1 > ((max(max(ngrad_f1)) + mean(mean(ngrad_f1)))/4));
    r_g(index) = ngrad_f1(index);

    AmrSeeds = imregionalmin(r_g);

    % Additional segmentation methods
    EMF_plus = EdgeMarkFillPlus(f_ori, 3, 100,r_g);
    ProposedSoltion1 = solution1(f_ori, 3, 100, r_g, AmrSeeds);
    ProposedSoltion2 = solution2(f_ori, 3, 100, r_g, AmrSeeds);

    
    % Save Original Image figure
    hFig1 = figure;
    imshow(f_ori);
    title('Original Image');
    saveas(hFig1, fullfile(outputFolder, [baseName, '_Original.png']));
    %close(hFig1);
    
    % Save AMR Segmentation figure
    L0 = watershed(a_copy_R_G);
    L_seg0 = Label_image_fast(f_ori, L0, 2, [255,0,0]);
    hFig2 = figure;
    imshow(L_seg0);
    title('AMR Segmentation');
    saveas(hFig2, fullfile(outputFolder, [baseName, '_AMR.png']));
    %close(hFig2);
    
    % Save EMF+ Segmentation figure
    LE = watershed(EMF_plus);
    L_segE = Label_image_fast(f_ori, LE, 2, [255,0,0]);
    hFig3 = figure;
    imshow(L_segE);
    title('EMF+ Segmentation');
    saveas(hFig3, fullfile(outputFolder, [baseName, '_EMFPlus.png']));
    %close(hFig3);
    
    % Save MySolution1 Segmentation figure
    L = watershed(ProposedSoltion1);
    L_seg_sol1 = Label_image_fast(f_ori, L, 2, [255,0,0]);
    hFig4 = figure;
    imshow(L_seg_sol1);
    title('MySolution1 Segmentation');
    saveas(hFig4, fullfile(outputFolder, [baseName, '_MySolution1.png']));
    %close(hFig4);
    
    % Save MySolution2 Segmentation figure
    L2 = watershed(ProposedSoltion2);
    L_seg_sol2 = Label_image_fast(f_ori, L2, 2, [255,0,0]);
    hFig5 = figure;
    imshow(L_seg_sol2);
    title('MySolution2 Segmentation');
    saveas(hFig5, fullfile(outputFolder, [baseName, '_MySolution2.png']));
    %close(hFig5);
    
    % Save segmentation as a .mat file in the result folder
    L_gray = rgb2gray(L_seg_sol1);
    segs = {L_gray}; % Use cell array for consistency
    segOutStor = fullfile(resultFolder, [baseName, '.mat']);
    save(segOutStor, 'segs');
        
end
