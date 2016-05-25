function [wavelets, testWavelets, targetFrequencies, testFrequencies] = getWavelets(f,r,sR,scale)

n2 = scale*2; % half-window length
win = (-n2):(n2);

% spec frequency ranges:
targetFrequencies = sR*(0:(1/(2*scale)):.5);
targetFrequencies = targetFrequencies(intersect(find(targetFrequencies >= (f-r)),find(targetFrequencies<=(f+r))));

wavelets = complexGabor1(targetFrequencies/sR, scale, 0, win); % wavelets is [length(fs),length(win)] = [length(fs),n];


testFrequencies = sR*(0:(1/(2*scale)):.5);
tfsl = testFrequencies(intersect(find(testFrequencies>=(f-3*r)),find(testFrequencies<=(f-2*r))));
tfsr = testFrequencies(intersect(find(testFrequencies>=(f+2*r)),find(testFrequencies<=(f+3*r))));
testFrequencies = [tfsl,tfsr];
testWavelets = complexGabor1(testFrequencies/sR,scale,0,win);

function gaborFun = complexGabor1(f,s,u,time)
% can output multiple gaborFuns: gaborFun is [p,n]
% time is [1,n]
% s,f are [1,p]
s = s'; % [p,1]
f = f'; % [p,1]
if ~isinf(s)
    g1 = bsxfun(@times,2^(1/4)/sqrt(s),exp(-pi/s^2*(time-u).^2));
    gaborFun = bsxfun(@times,g1,exp(1i*2*pi*f*(time-u)));
else
    gaborFun = exp(1i*2*pi*f*(time-u));
end

end
end