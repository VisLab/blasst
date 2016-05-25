%% Test scripts
signalSeconds = 100;
srate = 512;
nPoints = srate*signalSeconds;
baseAmplitude = 5.0.* random('normal', 0, 1, [1, nPoints]);
t = (0:(nPoints - 1))./srate;
harmonic = 60;
noiseAmplitude = 20;

%% Test 1
%lineNoise1 = getTest4(t, harmonic, 0.05);
lineNoise1 = getTest1(t, harmonic);
signal1 = baseAmplitude + noiseAmplitude*lineNoise1;

%% Notch filter design
p = 0.9;
w = 2*60/srate;
b = [1, -2*cos(pi*w), 1];
a = [1, -2*p*cos(pi*w), p*p];

[y1, zf1] = filter(b, a, signal1);

%% Use the MATLAB notch filter
wo = 60/(srate/2);  bw = wo/35;
[bm,am] = iirnotch(wo,bw);
y2 = filter(bm, am, signal1);

%%

[y3,varargout] = alnf(signal1,srate,60,2);

%% Show spectrum for notch filter
theTitle = ['Base 5.0 amp  + ' num2str(noiseAmplitude) ' line noise'];
showSpectrum(signal1, srate, {'signal'}, theTitle);
showSpectrum(y1, srate, {'notched'}, theTitle);
showSpectrum(y2, srate, {'math-notched'}, theTitle);
showSpectrum(y3, srate, {'notched-adapt'}, theTitle);
% 
% %% Narrow band notch filter
% alpha = 20;
% bN = [1, -2*cos(pi*w), 1];
% aN = [1, -2*(alpha + p)*cos(pi*w)/(1 + alpha), (p*p + alpha)/(1 + alpha)];
% yN = filter(bN, aN, signal1);
% showSpectrum(yN, srate, {'feedback notched'}, theTitle);
% 
% 
%%
figure
hold on
plot(baseAmplitude, 'k')
plot(y1, 'b')
plot(y2, 'g')
plot(y3, 'r')

legend('orig', 'narrow', 'm-notch', 'adapt')
hold off
