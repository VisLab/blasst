### BLASST: Band Limited Atomic Sampling with Spectral Tuning
BLASST is a method for identifying and removing non-stationary utility line noise from biomedical signals. The algorithm uses three strategies:

1. Finds best-fit Gabor atoms at predetermined time points.
2. Self modulates the fit by leveraging information from neighboring frequencies.
3. Terminates when energy in surround frequencies is comparable.

### Reference
Details of the BLASST algorithm can be found in:
> BLASST: Band Limited Atomic Sampling with Spectral Tuning
> by Kenneth R. Ball, W. David Hairston, Piotr J. Franaszczuk, and Kay A. Robbins
> IEEE Transactions on Biomedical Engineerating (to appear)

### Requirements
BLASST is a MATLAB toolbox that runs as a standalone function or as an EEGLAB plugin. You should have EEGLAB in your path in order to take advantage of the full functionality of BLASST.  To run as an EEGLAB plugin, download the blasst directory into your EEGLAB/plugins directory and run EEGLAB.

### Running BLASST
