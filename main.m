% Author: Navin Ipe
% License: MIT
% This is the main file for running Differential Evolution

clc;clear all;close all;
images = {'lena_gray.png', 'barbara_gray.bmp'};
imgName = char(images(1));
infor = imfinfo(imgName);
disp(infor);
[I, colormap] = imread(imgName);
if isempty(colormap), I = rgb2gray(I); else I = ind2gray(I, colormap);end

I = im2uint8(I);
searchSpace = imhist(I);

%-----Control panel
thresh = 8;%the number of thresholds
population = 30;%the number of vectors
masterBeta = 2.0;%beta is real number belongs to [0 -> 2]
cr = 0.3;%crossover probability range [0 -> 1]
generations = 200;
numTrials = 1;

if population < 4, disp('Population should be more than 3');return;end
minThresh = 1; maxThresh = numel(searchSpace);
figNum = 1;
figure(figNum);clf;figNum=figNum+1;imshow(I);title('Original image');
%figure(figNum);clf;figNum=figNum+1;imhist(I);title(strcat('histogram of : ',imgName));
%OtsuThreshold = graythresh(I);II = im2bw(I);imshow(II);title('Otsu thresholded image');

runtime = [];
fitStore = [];
bestThresholdAmongTrials = [];
bestFitnessAmongTrials = 0;
tempBestFitnessAmongTrials = 0;
fastestGenerationForBestFitness = 0;

for aTrial = 1:numTrials    
tic;
tempFitStore = [];
vBeta = masterBeta;%variable beta
fprintf('Trial: %d\n', aTrial);
X = floor(minThresh + (maxThresh - minThresh) * rand(thresh, population));
U = X;

generationAtBestFit = [0 0];%stores generation and best fitness
spaceSize = size(searchSpace, 1);
totalPixels = sum(searchSpace);
normProba = searchSpace ./ totalPixels;%normalized probabilities
if thresh < 1 || thresh > spaceSize, disp('Thresholds should be in a range of 1 to 256');return;end

%-----Get an initial Fitness
[fitnessX, X] = OtsuFitness(X, spaceSize, totalPixels, normProba);
[val, fittest] = max(fitnessX);

for gen = 1:generations
    %-----Mutation and crossover
    for p = 1:population
        %don't mutate or crossover the one with best fitness
        if fittest == p, U(:, p) = X(:, p);continue;end
        %Select three vectors for mutation
        randX = linspace(1, population, population);randX(fittest)=[];
        px1 = ceil(rand(1,1)*numel(randX));x1 = randX(px1);randX(px1)=[];
        px2 = ceil(rand(1,1)*numel(randX));x2 = randX(px2);randX(px2)=[];
        px3 = ceil(rand(1,1)*numel(randX));x3 = randX(px3);   
        mutant = X(:, x1) + round(vBeta.*(X(:, x2) - X(:, x3)));
        %---Crossover (will always happen if threshold is 1)
        chk = rand(thresh, 1);
        chk(ceil(rand(1) * thresh)) = 0;%one compulsory crossover        
        bothSame = 0;
        if mutant == X(:, p), bothSame = 1; end
        for cross = 1:thresh
            %if vectors end up being exactly similar, re-generate randomly
            if bothSame==1, mutant(cross, 1) = floor(minThresh + (maxThresh - minThresh) * rand(1));continue;end
            if chk(cross) <= cr && thresh ~= 1,mutant(cross, 1) = X(cross, p);end            
        end
        %Bring thresholds within range by regeneration instead of clamping
        mutant(mutant > maxThresh | mutant < minThresh) = floor(minThresh + (maxThresh - minThresh) * rand(1));        
        U(:, p) = mutant(:);
    end    
   
    %-----Selection
    [fitnessU, U] = OtsuFitness(U, spaceSize, totalPixels, normProba);
    
    for p = 1:population
        if fitnessU(p) > fitnessX(p),
            X(:, p) = U(:, p);
            fitnessX(p) = fitnessU(p);
        end
    end
   
    [val, fittest] = max(fitnessX);    
    tempFitStore = [tempFitStore fitnessX(fittest)];
    
    %=======PSO hybrid attempt (does not work well enough)
    %if gen > 5,
    %    %get three X vectors that are closest in fitness to the best X
    %    tempX = X; tFitnessX = fitnessX;
    %    tempX(:,fittest) = []; tFitnessX(fittest) = [];
    %    [v, f] = max(tFitnessX);x1 = tempX(:, f);fitX1=v;tempX(:,f) = [];tFitnessX(f) = [];
    %    [v, f] = max(tFitnessX);x2 = tempX(:, f);fitX2=v;tempX(:,f) = [];tFitnessX(f) = [];        
    %    [v, f] = max(tFitnessX);x3 = tempX(:, f);fitX3=v;tempX(:,f) = [];tFitnessX(f) = [];        
    %    [xBest, fitXBest] = exploitWithPSO(X(:,fittest), x1, x2, x3, val, fitX1, fitX2, fitX3, spaceSize, totalPixels, normProba, maxThresh, minThresh);
    %    if fitXBest > fitnessX(fittest),
    %        X(:,fittest) = xBest;            
    %        fitnessX(fittest) = fitXBest;
    %    end
    %end
    %=====end of PSO
    
    %---Store the generation at which best fitness was achieved
    if fitnessX(fittest) > generationAtBestFit(2),
        generationAtBestFit(1) = gen;
        generationAtBestFit(2) = fitnessX(fittest);
    end
    if generationAtBestFit(1) > fastestGenerationForBestFitness,
        fastestGenerationForBestFitness = generationAtBestFit(1);
    end
    
    %fprintf('Image %d is max fit. fitness %f. Achived at gen %d\n', fittest, fitnessX(fittest), generationAtBestFit(1));        
    
    if fitnessX(fittest) > bestFitnessAmongTrials, 
        bestFitnessAmongTrials = fitnessX(fittest);
        bestThresholdAmongTrials = X(:,fittest);
    end
    
    %---decrease beta to lower exploration and favour exploitation
    if vBeta > 1/40, vBeta = vBeta - 1/40;end
    %if vBeta > 1/(thresh*4), vBeta = vBeta - 1/(4*thresh);end    
    
end %end of generation loop
runtime = [runtime toc];
if bestFitnessAmongTrials > tempBestFitnessAmongTrials,
    tempBestFitnessAmongTrials = bestFitnessAmongTrials;
    fitStore = tempFitStore;
end
end %end of trial loop

%---DE completed. Now display data
fprintf('mean: ');
mean(runtime)
fprintf('standard deviation: ');
std(runtime)
fprintf('fastestGenerationForBestFitness=%d\n', fastestGenerationForBestFitness);
fprintf('Best fitness achieved until now=%f with thresholds ', bestFitnessAmongTrials);
disp(bestThresholdAmongTrials');

%-----Display multithresholded images of each vector
figure(figNum);clf;figNum=figNum+1;
T = I;
for j = 1:thresh+1
    if j == 1,%first bunch
        T(I < bestThresholdAmongTrials(j)) = minThresh-1;%0
    else
        if j > thresh,%last bunch
            T(I >= bestThresholdAmongTrials(j-1)) = maxThresh-1;%255
        else%everything else
            T(I >= bestThresholdAmongTrials(j-1) & I < bestThresholdAmongTrials(j)) = bestThresholdAmongTrials(j-1);
        end
    end
end
imshow(T);   
title('Best thresholded image');    

%-----Display fitness graph
figure(figNum);clf;figNum=figNum+1;
plot(linspace(1, gen, gen), fitStore);
xlabel('Generation');ylabel('Fitness');title('Fitness over time');

%-----Display histogram with thresholds
figure(figNum);clf;figNum=figNum+1;
plot(linspace(1,maxThresh,maxThresh)', searchSpace(:));
xlabel('Grayscale pixel intensities');ylabel('Cardinality of pixels of various intensities');
title('Histogram and thresholds of best candidate');
y = max(searchSpace) - 170;%to prevent threshold number display overlap
for i = 1:size(bestThresholdAmongTrials, 1)
    hold on;
    plot([bestThresholdAmongTrials(i) bestThresholdAmongTrials(i)], [0 max(searchSpace)], 'r:');
    text(bestThresholdAmongTrials(i), y, num2str(bestThresholdAmongTrials(i)));
    if y >= 170, y = y - 130;end
end
