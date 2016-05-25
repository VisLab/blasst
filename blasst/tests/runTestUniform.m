%% Test scripts
signalSeconds = 10;
srate = 512;
nPoints = srate*signalSeconds;
baseAmplitude = 5.0.* random('normal', 0, 1, [1, nPoints]);
t = (0:(nPoints - 1))./srate;
harmonic = 60;
noiseAmplitude = 1;

%% Test 1
lineNoise1 = getTest1(t, harmonic);
signal1 = baseAmplitude + lineNoise1;

%% Show spectrum of base amplitude
theTitle = 'Normal noise - amp 5.0';
figure
plot(t, baseAmplitude)
xlabel('Seconds')
ylabel('us')
title(theTitle)
showSpectrum(baseAmplitude, srate, {'base'}, theTitle)

%% Show spectrum of base + line noise
theTitle = 'Normal noise - amp 5.0 + 0.5 line noise';
figure
plot(t, signal1)
xlabel('Seconds')
ylabel('us')
title(theTitle)
showSpectrum(signal1, srate, {'base+line'}, theTitle);

%% Show spectrum of line noise
theTitle = 'Line noise - amp 0.5';
figure
plot(t, signal1)
xlabel('Seconds')
ylabel('us')
title(theTitle)
showSpectrum(lineNoise1, srate, {'base'}, theTitle)


%% Test 2
lineNoise2 = getTest2(t, harmonic);
signal2 = baseAmplitude + lineNoise2;


%% Show spectrum of base + line noise with oscillating amplitude
theTitle = '0.5 line noise oscillating amplitude';
figure
plot(t, lineNoise2)
xlabel('Seconds')
ylabel('us')
title(theTitle)
showSpectrum(lineNoise2, srate, {'oscline'}, theTitle);

theTitle = 'Normal noise amp 5.0 + 0.5 line noise oscillating amplitude';
figure
plot(t, signal2)
xlabel('Seconds')
ylabel('us')
title(theTitle)
showSpectrum(signal2, srate, {'base+ oscamp'}, theTitle);


%% Test 3
phaseAmplitude = 0.1;
lineNoise3 = getTest3(t, harmonic, phaseAmplitude);
signal3 = baseAmplitude + lineNoise3;


%% Show spectrum of base + line noise with oscillating amplitude
theTitle = '0.5 line noise oscillating phase';
figure
plot(t, lineNoise3)
xlabel('Seconds')
ylabel('us')
title(theTitle)
showSpectrum(lineNoise3, srate, {'oscphase'}, theTitle);

theTitle = 'Normal noise amp 5.0 + 0.5 line noise oscillating phase';
figure
plot(t, signal3)
xlabel('Seconds')
ylabel('us')
title(theTitle)
showSpectrum(signal3, srate, {'base+ oscphase'}, theTitle);


%% Test 4
phaseAmplitude = 0.1;
lineNoise4 = getTest4(t, harmonic, phaseAmplitude);
signal4 = baseAmplitude + lineNoise4;


%% Show spectrum of base + line noise with oscillating amplitude
theTitle = '0.5 line noise oscillating phase';
figure
plot(t, lineNoise4)
xlabel('Seconds')
ylabel('us')
title(theTitle)
showSpectrum(lineNoise4, srate, {'oscphaseamp'}, theTitle);

theTitle = 'Normal noise amp 5.0 + 0.5 line noise oscillating phase/amp';
figure
plot(t, signal4)
xlabel('Seconds')
ylabel('us')
title(theTitle)
showSpectrum(signal4, srate, {'base+ oscphaseamp'}, theTitle);
