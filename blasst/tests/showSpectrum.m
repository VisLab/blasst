function [fref, sref] = showSpectrum(data, srate, labels, theTitle)
% Calculate spectra for channels and display if the labels are provided
%
% Parameters:
%    data             Data as channels x time
%    srate            Sampling rate in Hz
%    labels           (optional) Names of individual channels for plotting
%                     If labels
%
%  Written by: Kay Robbins, UTSA, 2015
%
%  Uses calculateSpectrum -- adapted from EEGLAB
%
    channels = size(data, 1);
    fftwinfac = 4;
    sref = cell(channels, 1);
    fref = cell(channels, 1);
    windowSize = round(fftwinfac*srate);
    fftLength = 2^(nextpow2(windowSize))*fftwinfac;
    for k = 1:length(channels)
       [sref{k}, fref{k}] = pwelch(data(k, :), windowSize, [], fftLength, srate);
    end   
        
    showChannels();    
    
    function [] = showChannels()
        if isempty(labels)
            return;
        end
        colors = jet(channels);
        figure('Name', theTitle, 'Color', [1, 1, 1])
        hold on
        legends = cell(1, channels);
        for c = 1:channels
            s = sref{c}';
            s = 10*log10(s.*s);
            plot(fref{c}', s, 'Color', colors(c, :))
            legends{c} = [num2str(c) ' (' labels{c} ')'];
        end
        hold off
        xlabel('Frequency (Hz)')
        ylabel('Power 10*log(\muV^2/Hz)')
        legend(legends)
        title(theTitle, 'Interpreter', 'none')
        box on
        drawnow
    end
end
        