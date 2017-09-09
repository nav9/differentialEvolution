function [fitness,thresholds] = OtsuFitness(thresholds, spaceSize, totalPixels, p)
%Thresholds rows store the thresholds (value range: 2->255)
%Thresholds columns are populations.

ip = p .* linspace(1, spaceSize, spaceSize)';
if size(thresholds, 1) > 1, thresholds = sort(thresholds);end
omega = zeros(size(thresholds, 1) + 1, size(thresholds, 2));
mu = omega; sigmasq = omega;
invalidThresh = zeros(size(thresholds, 2));
threshStart = 0;
threshEnd = 0;

%-----Add up probabilities in different threshold regions
%Class occurance probability: omega
%Class mean probability: mu
for vec = 1:size(thresholds, 2)
    for thr = 1:size(thresholds, 1) + 1
        if thr == 1, threshStart = 0;end
        if thr == size(thresholds, 1)+1, threshEnd = spaceSize; else threshEnd = thresholds(thr, vec);end
        omega(thr, vec) = sum(p(threshStart + 1 : threshEnd));

        if omega(thr, vec) == 0,
            mu(thr, vec) = 0;
            invalidThresh(vec) = 1;
        else
            mu(thr, vec) = sum(ip(threshStart + 1 : threshEnd)) / omega(thr, vec);
        end       
        if thr <=size(thresholds, 1), threshStart = thresholds(thr, vec);end
    end
end
%-----Total mean
mu_total = sum(ip);

% %---Verify
% for vec = 1:size(thresholds, 2)
%     if round(sum(omega(:, vec))) ~= 1, disp('PROBLEM WITH OMEGA');end
% end

%-----Class variances: sigmasq
for vec = 1:size(thresholds, 2)
    lin = linspace(1, spaceSize, spaceSize)';
    for thr = 1:size(thresholds, 1)+1
        if thr == 1, threshStart = 0;end
        if thr == size(thresholds, 1)+1, threshEnd = spaceSize; else threshEnd = thresholds(thr, vec);end
        if omega(thr, vec) == 0, sigmasq(thr, vec) = 0; else
            sz = ones(threshEnd - threshStart, 1);
            pcv = (lin(threshStart + 1:threshEnd) - (mu(thr, vec).*sz)).^2;
            p_mul = p(threshStart + 1: threshEnd) ./ omega(thr, vec);
            sigmasq(thr, vec) = sum( pcv .* p_mul );
        end
        if thr <=size(thresholds, 1), threshStart = thresholds(thr, vec);end
    end    
end

fitness = [];
for vec = 1:size(thresholds, 2)
    if invalidThresh(vec) == 1, fitness = [fitness 0]; else
       %---fitness using between class variance
       fitness = [fitness sum(omega(:, vec) .* (mu(:, vec) - ones(size(thresholds, 1)+1, 1)*mu_total).^2)];
       %---fitness using within class variance
       %fitness = [fitness sum(omega(:, vec).*sigmasq(:, vec))];
       %---fitness using eta
       %fitness = [fitness betweenClass/withinClass];       
    end
end