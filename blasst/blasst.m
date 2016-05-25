function [x, y] = blasst(x,lineFrequency, frequencyRange, samplingRate,varargin)
% blasst(): EEGLAB helper function for OCW line noise removal.
% Takes as input an array of signals x, along with relevant parameters, and
% performs BLASST filtering at specified frequencies. For each specified 
% frequency, blasst() iteratively calls blasstInternal() and tests for convergence based on the distributions of
% convolution coefficients in the target and surrounding frequency bands.
%
% INPUT:
% x                 signal array with n points.
% lineFrequency     target frequency (not normalized).
% frequenyRange     target frequency ranges.
% samplingRate      the sampling rate of the signal.
% varargin          optional 'key',value pairs:
%   'key'           
%           [default] purpose
%   'Scale'        
%           [2^(log2(samplingRate)+2)] Manually set the scale that 
%           indicates the spread of Gabor atoms.
%   'ContinuousEpochs'  
%           [0] If x is epoched, but epochs are temporally adjacent, 
%           setting to 1 will flatten x for processing. Otherwise, 
%           blasst is run on individual epochs.
%   'Verbose'
%           [1] When on, progress is printed on command line.
%   'Resolution'
%           [2] May be an integer value >= 1, sets 'resolution' in blasst.
%           Specificies density of Gabor atoms. May also be an array of
%           integer values of size(lineFrequencies).
%   'MaxIterations'
%           [50] Maximum number of external iterations of blasst run on
%           each frequency. May be either a scalar integer or array of
%           integers of size(lineFrequencies).
%   'ManualOffset'
%           [log2(scaleBases)+1] A scalar value that offsets the 
%           arrangement of Gabor atoms at each iteration of blasst.
%
% OUTPUT:
% x         the processed, or ``cleaned'' signal.
% y         the aggregate of the target signal feature removed, an 
%                   array of size(x).
%
% DEPENDENCIES:
% blasstInternal()         primary line noise removal algorithm.
%
% EXAMPLE:
%  Suppose we wish to remove line noise frequency at 60 and 120 Hz, and the
%  noise is mostly stationary at 120 Hz but non-stationary varying by about
%  2 Hz, around 60 Hz. Then we might call the method as:
% >> x = blasst(x,[60,120],[2,.25],<sampling rate>);
%
%  If we want to use more densely packed Gabor atoms, we could call:
% >> x = blasst(x,[60,120],[2,.25],<sampling rate>,'Resolution',4);
%
% AUTHOR: Kenneth Ball, 2015.
% 
% IF YOU FIND BLASST USEFUL IN YOUR WORK, PLEASE CITE:
%
% Ball, K. R., Hairston, W. D., Franaszczuk, P. J., Robbins, K. A., 
% BLASST: Band Limited Atomic Sampling with Spectral Tuning with 
% Applications to Utility Line Noise Filtering, [Under Review].
%
% Copyright 2015 Kenneth Ball, modified by Kay Robbins
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

% Set defaults:
x = x(:)';
frequencyResolution = 2;
maxIterations = 50; % Default is high so that the method generally will generally converge.

% Adjust for optional inputs
if (nargin> 1)
    if (nargin> 4 && rem(nargin,2) == 1)
        if length(varargin) == 1
            varargin = varargin{1};
        else
            fprintf('blasst(): Optional key and value pairs do not match.')
            return
        end
    end
    
    for ii = 1:2:length(varargin)
        key = varargin{ii};
        val = varargin{ii+1};
        switch key
            case 'SamplingRate'
                samplingRate = val;
            case 'Scale'
                scale = val;
            case 'Verbose'
                %verbose = val;
            case 'Resolution'
                frequencyResolution  = val;
            case 'MaxIterations'
                maxIterations = val;
            case 'ManualOffset'
                manualOffset = val;
        end
    end
end

if ~exist('samplingRate','var')
    error('No sampling rate specified.');
elseif isempty(samplingRate) || samplingRate == 0
    error('Null or zero sampling rate specified.');
end

if ~exist('scaleBases','var')
    scale = 2^(log2(samplingRate)+2);
end

if ~exist('manualOffset','var')
    manualOffset = log2(scale)+1;
end

[x, y] = blastInternal(x, lineFrequency, frequencyRange, samplingRate, ...
           scale, frequencyResolution, maxIterations, manualOffset);





