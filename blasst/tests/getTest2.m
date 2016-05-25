function s = getTest2(t, harmonic)
% Test signal with oscillating amplitude
    baseFrequency = 2*pi*harmonic;
    amplitudeFrequency = pi/8;
    s = (1.5 - sin(amplitudeFrequency.*t)).*sin(baseFrequency.*t);
end
