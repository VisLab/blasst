%% Test scripts
signalSeconds = 100;
srate = 512;
nPoints = srate*signalSeconds;
baseAmplitude = 5.0.* random('normal', 0, 1, [1, nPoints]);
t = (0:(nPoints - 1))./srate;
harmonic = 60;
noiseAmplitude = 20;

%% Test 1
lineNoise1 = getTest1(t, harmonic);
signal1 = baseAmplitude + noiseAmplitude*lineNoise1;

lineNoise4 = getTest4(t, harmonic, 0.05);
signal4 = baseAmplitude + noiseAmplitude*lineNoise4;

%% Notch filter design
p = 0.9;
w = 2*harmonic/srate;
b = [1, -2*cos(pi*w), 1];
a = [1, -2*p*cos(pi*w), p*p];

yN1 = filter(b, a, signal1);
yN4 = filter(b, a, signal4);

%% Matlab iir notch filter
wo = harmonic/(srate/2);  bw = wo/35;
[bm, am] = iirnotch(wo, bw);
yM1 = filter(bm, am, signal1);
yM4 = filter(bm, am, signal4);

[bm4, am4] = iirnotch(wo, 15*bw);
yM44 = filter(bm4, am4, signal4);
%% Pei notch feedback filter
alpha = 20;
pn = 0.9;
wn = 2*harmonic/srate;
bn = [1, -2*cos(pi*wn), 1];
an = [1, -2*(alpha + pn)*cos(pi*wn)/(1 + alpha), (pn*pn + alpha)/(1 + alpha)];
yNN1 = filter(bn, an, signal1);
yNN4 = filter(bn, an, signal4);


%% Regalia's adaptive notch filter
bw = 0.10*pi; % bandwidth parameter for notch filter.
stepSize = 0.01; % adaptive filter step size.

[yA1, outFreq1] = adaptiveNotchKay(signal1, stepSize, bw);
yA1 = yA1';
[yA4, outFreq4] = adaptiveNotchKay(signal4, stepSize, bw);
yA4 = yA4';

%% Show spectrum for notch filter
theTitle = ['Signal1: Base 5.0 amp  + ' num2str(noiseAmplitude) ' line noise'];
showSpectrum(signal1, srate, {'orig'}, theTitle);
showSpectrum(yN1, srate, {'notch-iir'}, theTitle);
showSpectrum(yM1, srate, {'notch-mat'}, theTitle);
showSpectrum(yNN1, srate, {'notch-nar'}, theTitle);
showSpectrum(yA1, srate, {'notch-adapt'}, theTitle);

%%
figure('Name', 'Signal 1 filtered')
hold on
plot(baseAmplitude, 'k')
plot(yN1, 'b')
plot(yM1, 'g')
plot(yNN1, 'm')
plot(yA1, 'r')
legend('orig', 'notch-iir', 'notch-mat', 'notch-nar', 'notch-adapt')
hold off

%% Show spectrum for notch filter
theTitle4 = ['Signal4: Base 5.0 amp  + ' num2str(noiseAmplitude) ' phase varying'];
showSpectrum(signal4, srate, {'orig'}, theTitle4);
showSpectrum(yN4, srate, {'notch-iir'}, theTitle4);
showSpectrum(yM4, srate, {'notch-mat'}, theTitle4);
showSpectrum(yNN4, srate, {'notch-nar'}, theTitle4);
showSpectrum(yA4, srate, {'notch-adapt'}, theTitle4);
showSpectrum(yM44, srate, {'notch-matw'}, theTitle4);

%%
figure('Name', 'Signal 4 filtered')
hold on
plot(baseAmplitude, 'k')
plot(yN4, 'b')
plot(yM4, 'g')
plot(yNN4, 'm')
plot(yA4, 'r')
legend('orig', 'notch-iir', 'notch-mat', 'notch-nar', 'notch-adapt')
hold off

%%
figure('Name', 'Out frequency 1')
plot(outFreq1)
