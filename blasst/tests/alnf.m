function [x,varargout] = alnf(insamples,sR,f0,bW,varargin)
% adaptive lattice notch filter:
% INPUT:
% insamplses (n,N) signals: n-channels, length N
% sR: sampling rate
% f0: initial frequency estimate (usually 60 Hz).
% bW: bandwidth of notch filter... for [59,61] Hz, input bW = 2...
% varargin{1}: mu, the adaptive filter step size. Default = .023;
%

% OUTPUT:
% x: the filtered signal:
% varargout{1}: the removed noise (ie, this is the 60 Hz sinuosoidal if removing line noise)
% varargout{2}: frequency estimate over time.


iter = size(insamples,2);
x = zeros(size(insamples));
n = size(insamples,1);
freqEst = zeros(size(insamples));
mu = .023;
if ~isempty(varargin)
  mu = varargin{1};
end

for cc = 1:n

  % initialize adaptive filter parameters
  %
  xst = zeros(2,1); % state of adaptive filter.
  temp = zeros(2,1); % intermediate signals.
  pihalf = 0.5*pi; % pi/2.
  theta = f0/sR; % initial value for notch frequency parameter.
  sth = sin(theta);
  cth = cos(theta);
  bw = bW/sR;%0.20*pi; % bandwidth parameter for notch filter.
  sth2 = sin(bw);
  cth2 = cos(bw);
  %
  % Run adaptive lattice notch filter:
  % This is a straight fixed-step-size algorithm: No  tricks, no funny stuff.
  %
  freqest = zeros(1,iter+1);
  freqest(1) = f0/sR;%0.25; %initial notch frequency
  for kk=1:iter
    insig = insamples(kk);
    temp = [cth2 -sth2;sth2 cth2]*[insig; xst(2)];
    error = mu*(insig + temp(2)); %notch filter output times step size.
    theta = theta - error*xst(1); %coefficient update.
    freqnew = 0.5*acos(cos(theta+pihalf))/pi; %instantaneous freq. estimate.
    freqest(kk+1) = freqnew;
    sth = sin(theta);
    cth = cos(theta);
    xst = [cth -sth;sth cth] * [temp(1);xst(1)];
    x(cc,kk) = insig + temp(2);
  end
  freqEst(cc,:) = freqest(1:(end-1));

end
  
  varargout{1} = insamples - x;
  varargout{2} = freqEst*sR;

end