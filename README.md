# differentialEvolution

An implementation of the famous Differential Evolution Computational Intelligence algorithm formulated by Storn and Price. This algorithm uses the Otsu criterion as the fitness function and can be used to threshold grayscale images using multiple thresholds. The solution you get is near-optimal, just as every computational intelligence algorithm is meant to work.

An (unsuccessful) attempt is also made to optimize the algorithm using a particle swarm optimization (PSO) algorithm. The PSO algorithm could be ignored for now.

More detailed explanation: The program is designed to generate a 0 to 255 level histogram of any grayscale image and then attempt to find thresholds at which the image could optimally be segregated into pixels belonging to the foreground of the image vs pixels belonging to the background of the image. This evaluation of the best threshold is done using the Otsu criterion, and the Otsu fitness of the threshold is returned as a "between class variance". The higher the value, the better the fitness.
The differential evoltion keeps generating threshold values within the range of 1 to 256 and evaluating the fitness of the threshold for the image. Using mutations and crossovers, more optimal thresholds are selected generation after generation. 
The user can choose to run multiple trials and the best thresholds among those trials are selected and the segmented image is shown along with the histogram and the location of the thresholds.

Explanation about the files:
----------------------------
* main.m: This file contains the main algorithm for Differential Evolution. This is where you start the run. 
* OtsuFitness.m: This function measures the fitness of the threshold(s) for the image.
* thresholdingSequential.m: This program shows you how much time it would take for you to do an exhaustive search of all possible threshold combinations instead of using Differential Evolution.
* exploitWithPSO.m: You can ignore this file. It is an attempt made at creating a DE-PSO hybrid. It couldn't improve the performance of the algorithm yet, but you could work on tweaking it and let Navin know.

Attribution:
------------
The famous Lena image is from here: https://www.ece.rice.edu/~wakin/images/
The Barbara image is from here: http://eeweb.poly.edu/~yao/EL5123/SampleData.html. There is a question pending an answer about who Barbara is: https://dsp.stackexchange.com/questions/18631/who-is-barbara-test-image. Perhaps you could write to the authors to find out. I wrote to one of them. No reply.
