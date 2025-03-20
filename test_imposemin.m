clc; clear; close all;

% Step 1: Create a 20x20 Binary Image with a Central Object
bw = zeros(20,20);
bw(6:15, 6:15) = 1; % A square object in the middle

% Step 2: Compute the Euclidean Distance Transform (EDT)
distTransform = bwdist(bw);

% Step 3: Compute the Complement of EDT
compDistTransform = max(distTransform(:)) - distTransform;

% Step 4: Define Markers (placing inside the object)
marker = zeros(20,20);
marker([7, 8, 9, 12, 13, 14], [7, 9, 12, 8, 13, 14]) = 1; % Placing 6 markers

% Step 5: Apply imimposemin
imposedImage = imimposemin(compDistTransform, marker);

% Step 6: Handle -inf values for compatibility
imposedImage(imposedImage == -inf) = min(compDistTransform(:));

% Step 7: Display Results with Pixel Numbering
figure;

% Function to plot images with pixel numbers
plotImageWithNumbers(bw, 'Original Binary Image', 1);
plotImageWithNumbers(compDistTransform, 'Complement of EDT', 2);
plotImageWithNumbers(marker, 'Marker Positions', 3);
plotImageWithNumbers(imposedImage, 'Imposed Image (Fixed -inf)', 4);

% Custom function to display image with numbers
function plotImageWithNumbers(img, titleText, subplotIndex)
    subplot(1,4,subplotIndex); 
    imshow(img, []); title(titleText); hold on;
    
    % Loop through each pixel and display its value
    for x = 1:size(img, 1)
        for y = 1:size(img, 2)
            text(y, x, num2str(img(x, y), '%.1f'), 'Color', 'red', ...
                 'FontSize', 7, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        end
    end
    hold off;
end
