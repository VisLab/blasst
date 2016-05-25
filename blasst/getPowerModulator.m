function PM = getPowerModulator(x, D, scale, resolution, manualOffset, targetFreqs, testFreqs)
% Power modulator with 2*window length padding
n2 = scale*2;
n = 2*n2+1; % win length
N = length(x) - 4*n;  % Interior points
%x = [zeros(1,2*n), x, zeros(1,2*n)];
% timejump and estimate amplitude scaling for partition of unity of Gaussian functions:
timeJump = scale/resolution/sqrt(pi);
CmodWeights = zeros(length(targetFreqs),length(testFreqs));

for kk = 1:length(targetFreqs)
    CmodWeights(kk,:) = targetFreqs(kk)-testFreqs;
end
CmodWeights = abs(1./CmodWeights);
CmodWeights = bsxfun(@times,CmodWeights,1./sum(CmodWeights,2));

modulator = sqrt(exp( CmodWeights*log(abs(D).^2) ));

% Build the windowed signal array:
centers = (1+manualOffset):timeJump:N; % Interior centers.
leftCenters = centers(1);
centers = centers(2:end);
while round(leftCenters(1)) > -n2+1
    leftCenters = cat(2,leftCenters(1)-timeJump,leftCenters);
end
while round(leftCenters(end)) < n2
    leftCenters = cat(2,leftCenters,leftCenters(end)+timeJump);
    centers = centers(2:end);
end
rightCenters = centers(end);
centers = centers(1:end-1);
while round(rightCenters(end)) < N+n2
    rightCenters = cat(2,rightCenters,rightCenters(end)+timeJump);
end
while round(rightCenters(1)) > N-n2
    rightCenters = cat(2,rightCenters(1)-timeJump,rightCenters);
    centers = centers(1:end-1);
end
centers = round([leftCenters,centers,rightCenters]);
centers = centers(2:(end-1) );
centers = centers + 4*n2 + 2; % Adjust "centers" index to account for the padding by n

PM = zeros(length(centers), size(modulator,1)); % the power modulator

for jj = 1:length(centers)
    PM(jj,:) = mean(modulator(:,round( ((-scale/(2*resolution)):(scale/(2*resolution)))+centers(jj))),2)';
end