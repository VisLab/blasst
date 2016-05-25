function [xClipped, yClipped] = blastInternal(xClipped, lineFrequency, ...
                frequencyRange, samplingRate, ...
                scale, frequencyResolution, maxIterations, manualOffset)
% Initialize holders for fitted noise and cleaned signals.
    n2 = scale*2; % half-window length
    basePoints = -n2:n2;  % relative indices within a window
    n = 2*n2 + 1; % win length
    x = [zeros(1, 2*n), xClipped, zeros(1, 2*n)];
    y = zeros(size(x));
    
    R = -(frequencyResolution*10):(frequencyResolution*10);
    scalingFactor = 1./sum(exp(-R.^2/frequencyResolution.^2));
    
    % spec frequency ranges:
    fs = samplingRate*(0:(1/(2*scale)):.5);
    fs = fs(intersect(find(fs>=(lineFrequency-frequencyRange)),find(fs<=(lineFrequency+frequencyRange))));
      
    N = length(x) - 4*n;  % Interior points
    [centers, weights] = getWeights();
    numCenters = length(centers);
    numFrequencies = length(fs);
    centerIndex = zeros(numCenters, n);
    
%% Build the wavelet and the power modulators
    [wavelets, testWavelets, targetFrequencies, testFrequencies] = ...
        getWavelets(lineFrequency, frequencyRange,samplingRate, scale);
    
    for jk = 1:numCenters
        centerIndex(jk, :) = basePoints + centers(jk);
    end
    [D, DCompare, histCenters] = getDCompareInternal();
    PM = getPowerModulator(x, D, scale, frequencyResolution, manualOffset, ...
        targetFrequencies, testFrequencies);

%% Perform the iteration
    BDist = -1;
    xTemp = x;
    yTemp = y;
    for mm = 1:maxIterations
        y = y + yTemp;
        x = xTemp;
        %showSpectrum(x, samplingRate, {'blasst4'}, ['Iteration ' num2str(mm)]);
        [xTemp, yTemp, BDist1, maxFlag] = blasst4_internalA(xTemp, ...
                               wavelets, PM, DCompare, histCenters);
        fprintf('BDist = %g, BDist1 = %g, maxFlag = %d\n', BDist, BDist1, maxFlag);
        if BDist > 0 && BDist1 >= BDist && maxFlag ~= 1
            break;
        end
        BDist = BDist1;
    end

%% Extract the unpadded signal
xClipped = x((2*n+1):(end-2*n));
yClipped = y((2*n+1):(end-2*n));


    function [xTemp, yTemp, BDist, maxFlag] = blasst4_internalA(xTemp,  ...
            wavelets, PM, DCompare, histCenters)
               
        yTemp = zeros(size(xTemp));
  
        %% Now try it an alternative way
        tWavelets = wavelets.';
        amplitudes = zeros(numCenters, 1);
        frequencies = zeros(numCenters, 1);
        PM1 = PM';
        thisWavelet = zeros(size(wavelets));
        thisBlock = zeros(size(wavelets));
        C = zeros(numFrequencies, size(xTemp, 2));
        for jj = 1:numCenters
            thisX = xTemp(centerIndex(jj, :));
            thisPhase = exp(-1i*angle(thisX*tWavelets));
            for k = 1:numFrequencies
                thisWavelet(k, :) = real(thisPhase(k)*wavelets(k, :));
                thisBlock(k, :) = thisX.*thisWavelet(k, :);
            end
            C(:, centerIndex(jj, :)) = C(:, centerIndex(jj, :)) + ...
                weights(jj)*thisBlock;
            [amplitudes(jj), frequencies(jj)] = max(sum(thisBlock, 2) - PM1(:, jj));
            thisOne =  max(0, amplitudes(jj))*weights(jj)*thisWavelet(frequencies(jj), :);
            yTemp(centerIndex(jj, :)) = yTemp(centerIndex(jj, :)) + thisOne;
        end
        xTemp = xTemp - yTemp;
        C = abs(C); % Now C and D are real and same size: [
        
        CHists = hist(2*log(C)', histCenters);
        CHists = CHists/N;
        CCompare = mean(CHists, 2);
        [~,CMaxInd] = max(CCompare);
        if CMaxInd == length(histCenters) % Presumably, CCompare distribution is somewhat skewed to the right and we are nowhere near convergence.
            maxFlag = 1;
        else
            maxFlag = 0;
        end
%         figure('Name', 'Plot comparison')
%         hold on
%         plot(histCenters, DCompare, 'k-');
%         plot(histCenters, CCompare, 'r-');
%         hold off
%         xlabel('Power')
%         ylabel('Probability')
%         legend('Predicted', 'Current')
%         
        BDist = -log(sum(sqrt(DCompare.*CCompare))+1e-8);
       
    end

    function [D, DCompare, histCenters] = getDCompareInternal( )
        
        M = size(x, 2);
        fs = samplingRate*(0:(1/(2*scale)):.5);
        fs = fs(intersect(find(fs >= (lineFrequency-frequencyRange)), ...
                          find(fs<=(lineFrequency+frequencyRange))));
        tfs = samplingRate*(0:(1/(2*scale)):.5);
        tfsl = tfs(intersect(find(tfs>=(lineFrequency-3*frequencyRange)), ...
                             find(tfs<=(lineFrequency-2*frequencyRange))));
        tfsr = tfs(intersect(find(tfs>=(lineFrequency+2*frequencyRange)), ...
                             find(tfs<=(lineFrequency+3*frequencyRange))));
        tfs = [tfsl,tfsr];
   
        testWeights = zeros(length(fs),length(tfs)); %[targetFrequencies,testFrequencies]
        for kk = 1:length(fs)
            testWeights(kk,:) = fs(kk) - tfs;
        end
        testWeights = abs(1./testWeights);
        testWeights = bsxfun(@times,testWeights,1./sum(testWeights,2));
           
        
        %% Compute the estimates
        tWavelets = testWavelets.';
        thisWavelet = zeros(size(testWavelets));
        thisBlock = zeros(size(testWavelets));
        D = zeros(size(testWavelets, 1), size(x, 2));
        for jj = 1:numCenters
            thisX = x(centerIndex(jj, :));
            thisPhase = exp(-1i*angle(thisX*tWavelets));
            for k = 1:numFrequencies
                thisWavelet(k, :) = real(thisPhase(k)*testWavelets(k, :));
                thisBlock(k, :) = thisX.*thisWavelet(k, :);
            end
            D(:, centerIndex(jj, :)) = D(:, centerIndex(jj, :)) + ...
                                                   weights(jj)*thisBlock;
        end
        binCount = ceil(2*M^(1/3));
        [DHists, histCenters] = hist(2*log(abs(D))', binCount); %[binCount,lenegth(tfs)] vectors
        DHists = DHists/M;
        DCompare = mean(DHists*testWeights',2);
    end

    function [centers, weights] = getWeights()
        % timejump and estimate amplitude scaling for partition of unity of Gaussian functions:
        timeJump = scale/frequencyResolution/sqrt(pi);
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
        weights = scale/2*(erf(sqrt(pi)*(N-centers)/scale)-erf(sqrt(pi)*(1-centers)/scale))/scale;
        weights = weights( 2:(end-1) );
        weights = sqrt(2)*scalingFactor./weights;
        centers = centers( 2:(end-1) ) + 2*n;
    end
end
