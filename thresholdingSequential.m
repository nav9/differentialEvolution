% Author: Navin Ipe
% License: MIT
% This is a standalone piece of code. You can run it directly

clc;clear all;
imgName = 'lena_gray.png';
%imgName = 'peppers.png';
infor = imfinfo(imgName);
disp(infor);
[I, colormap] = imread(imgName);
if isempty(colormap)
    I = rgb2gray(I);    
else
    %I = ind2rgb(I, colormap);
    I = ind2gray(I, colormap);
    I = im2uint8(I);
end

figNum = 1;
searchSpace = imhist(I);
fitStore = [];
OtsuThreshold = graythresh(I);
OtsuThreshold
runtime = [];

figure(figNum);clf;figNum=figNum+1;imshow(I);title('Original image');
highestFitness = 0;
bestThreshold = [];
spaceSize = size(searchSpace, 1);
totalPixels = sum(searchSpace);
normProba = searchSpace ./ totalPixels;%normalized probabilities

%-----One threshold
% tic
% for i = 1:size(searchSpace, 1)
%     X = [i];
%     [fitnessX, sortedThresh] = OtsuFitness(X, spaceSize, totalPixels, normProba);
%     if fitnessX > highestFitness,
%         highestFitness = fitnessX;
%         bestThreshold = [i];
%     end
% end
% toc
%==========================================================================
%-----Two thresholds
tic
for i = 1:size(searchSpace, 1)
for j = 1:size(searchSpace, 1)    
    X = [i;j];
   [fitnessX, sortedThresh] = OtsuFitness(X, spaceSize, totalPixels, normProba);
    if fitnessX > highestFitness,
        highestFitness = fitnessX;
        bestThreshold = [i j];
    end
end    
end
toc
%==========================================================================
% %-----Three thresholds
% tic
% for i = 1:size(searchSpace, 1)
% for j = 1:size(searchSpace, 1)    
% for k = 1:size(searchSpace, 1)        
%     X = [i;j;k];
%    [fitnessX, sortedThresh] = OtsuFitness(X, spaceSize, totalPixels, normProba);
%     if fitnessX > highestFitness,
%         highestFitness = fitnessX;
%         bestThreshold = [i j k];
%     end
% end    
% end
% end
% toc
%==========================================================================
% %-----manual trials
% X = [71 91;155 155;171 255];
% [fitnessX, sortedThresh] = OtsuFitness(searchSpace, X);
% highestFitness = fitnessX;
% bestThreshold = sortedThresh;
%==========================================================================

fprintf('Highest fitness = %f. Best threshold = ', highestFitness);
disp(bestThreshold);


% %-----Display multithresholded images of each vector
% minThresh = 1; maxThresh = numel(searchSpace);
% population = size(X, 2);
% thresh = size(X, 1);
% disp('Thresholds being drawn (not just the best threshold)');
% X
% figure(figNum);clf;figNum=figNum+1;
% title('populations generated');
% subplotRows = ceil(population / 5);
% subplotColumns = 5;
% for i = 1:population
%     T = I;
%     subplot(subplotRows,subplotColumns,i);
%     for j = 1:thresh+1
%         if j == 1,%first bunch
%             T(I < X(j,i)) = minThresh-1;%0
%         else
%             if j > thresh,%last bunch
%                 T(I >= X(j-1,i)) = maxThresh-1;%255
%             else%everything else
%                 T(I >= X(j-1,i) & I < X(j,i)) = X(j-1,i);
%             end
%         end
%     end
%     imshow(T);   
% end   
