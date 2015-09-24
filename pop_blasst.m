function [EEG,com] = pop_blasst(EEG,lineFrequencies,frequencyRanges,varargin)
% pop_blasst(): EEGLAB helper function for blasst filtering.
% Takes as input an EEGLAB EEG struct, along with relevant parameters, and
% calls blasst() for BLASST fitlering at specified frequencies. For each
% specified frequency, blasst() iteratively calls blasst_internal() and 
% then uses blasst_test() to test for convergence based on the 
% distributions of convolution coefficients in the target and surrounding 
% frequency bands.

com = '';

if nargin < 1
    help pop_blasst;
    return
end
if ~isfield(EEG,'data')
    error('Must specify signal(s) in EEG struct as: \n >>EEG.data = <signals>;')
elseif isempty(EEG.data)
    error('We can not BLASST nothing! EEG.data is empty.');
end

if isempty(lineFrequencies)
    error('BLASST requires input target frequencies.');
end

if isempty(frequencyRanges)
    error('BLASST requires input frequency ranges.');
end

if ~isfield(EEG,'srate')
    error('Must specify sampling rate in input EEG struct as: \n >>EEG.srate = <sampling rate>;')
elseif isempty(EEG.srate)
    error('BLASST must have a sampling rate! EEG.srate is empty.')
end

EEG.data = blasst(EEG.data,lineFrequencies,frequencyRanges,EEG.srate,varargin);
foo = [];
% Process varargin cell into string of name value pairs.
if ~isempty(varargin)
    if ~rem(length(varargin),2)
        foo = ',';
        if ischar(varargin{2})
            foo = [foo,'''',varargin{1}, ''', ''',varargin{2},''''];
        else
            foo = [foo,'''',varargin{1}, ''', ',num2str(varargin{2})];
        end
        for ii = 3:2:length(varargin);
            if ischar(varargin{ii+1})
                foo = [foo, ', ''', varargin{ii}, ''', ''', varargin{ii+1},''''];
            else
                foo = [foo, ', ''', varargin{ii}, ''', ', num2str(varargin{ii+1})];
            end
        end
%         foo = [foo,' }'];
    else
        error('Name value pairs do not match.')
    end
end

com = sprintf('%s = pop_blasst(%s,%s,%s%s);',inputname(1),inputname(1),mat2str(lineFrequencies),mat2str(frequencyRanges),foo);



end