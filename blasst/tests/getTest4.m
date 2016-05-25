function s = getTest4(t, harmonic, phaseAmplitude)
% Harmonic with oscillating phase
    s = zeros(size(t));
    baseFrequency = 2*pi*harmonic;
    phaseFrequency = pi/8;
    amplitudeFrequency = pi/(8*sqrt(2));
    sTotal = 0;
    for k = 1:length(t)
        sTotal = sTotal + sin(phaseFrequency*k);
        s(k) = sTotal;
    end
    s = (1.5 - sin(amplitudeFrequency*t)).*sin(baseFrequency.*t + phaseAmplitude.*s);
end
