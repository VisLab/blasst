%% Test scripts
signalSeconds = 10000;
srate = 512;
nPoints = srate*signalSeconds;
baseAmplitude = 5.0.* random('normal', 0, 1, [1, nPoints]);
t = (0:(nPoints - 1))./srate;
harmonic = 60;
noiseAmplitude = 1;

%% Test 1
lineNoise1 = getTest1(t, harmonic);
signal1 = baseAmplitude + noiseAmplitude*lineNoise1;

%% Call blasst
tic
signalBlasst = blasst(signal1, 60, 0.25, 512);
toc

%%
figure
hold on
plot(t, signal1, 'k-')
plot(t, baseAmplitude, 'g-')
plot(t, signalBlasst, '-r')
legend('Noisy', 'Base', 'Blassted')
xlabel('Seconds')
hold off

%%
figure
hold on
plot(t, baseAmplitude, 'g-')
plot(signalBlasst, '-r')
legend('Base', 'Blassted')
xlabel('Seconds')
hold off

%%
%% Display the signal spectrum
theTitle = ['Base 5.0 amp  + ' num2str(noiseAmplitude) ' line noise'];
showSpectrum(signal1, srate, {'noisy'}, theTitle);

% Display the signals
theTitle = ['Base 5.0 amp  + ' num2str(noiseAmplitude) ' line noise'];
showSpectrum(signalBlasst, srate, {'blasst'}, theTitle);