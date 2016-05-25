function s = getTest3(t, harmonic, phaseAmplitude)
% Harmonic with oscillating phase
    s = zeros(size(t));
    baseFrequency = 2*pi*harmonic;
    phaseFrequency = pi/8;
    sTotal = 0;
    for k = 1:length(t)
        sTotal = sTotal + sin(phaseFrequency*k);
        s(k) = sTotal;
    end
    s = sin(baseFrequency.*t + phaseAmplitude.*s);
end
