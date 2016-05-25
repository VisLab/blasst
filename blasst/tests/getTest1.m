function s = getTest1(t, harmonic)
% Basic steady state harmonic
    baseFrequency = 2*pi*harmonic;
    s = sin(baseFrequency.*t);
end
