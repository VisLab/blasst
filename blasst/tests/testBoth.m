load('veptest.mat');

%%
lineNoiseIn = struct();
lineNoiseIn.lineFrequencies = [60, 120, 180, 212, 240];
lineNoiseIn.lineNoiseChannels = 1:70;

%% EEG  Cleanline
tic
[EEGFiltClean, lineNoiseOut] = cleanLineNoise(EEGFilt, lineNoiseIn);
toc


%%
tic
EEGFiltBlast = blasst(EEGFilt.data, lineNoiseIn.lineFrequencies, 0.25, 512);
toc


%% 
channelsPerBlock = 10;
numberBlocks = ceil(length(lineNoiseIn.lineNoiseChannels)/channelsPerBlock);
startBlock = 1;
for k = 1:numberBlocks
    endBlock = min(k*numberBlocks - 1, size(EEGFiltBlast.data, 2));
    signals = EEGFiltBlast.data;
end