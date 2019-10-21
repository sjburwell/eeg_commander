# eeg_commander
This is a MATLAB pipeline for easy-to-program automated pre-processing of electroencephalogram (EEG) data using independent component analysis (ICA) and statistically-robust detection of artifacts. It is intended to work similar to a plug-in for the EEGLAB (https://sccn.ucsd.edu/eeglab/index.php) software suite, but it additionally contains low-level functions that work on simpler data arrays (e.g., 2- or 3-dimensional matrices) that may be useful for commandline artifact detection and removal. Generally, the EEG pipeline is designed to successively prune EEG artifacts identified in 1) one-second contiguous segments in the continuous data, in 2) grossly bad data channels, in 3) spatiotemporal stereotyped ICA artifacts, and in 4) channel/time-segments (e.g., trial epochs). _It is strongly recommended that EEGLAB *version 14.1.1b*  or above is in the user's MATLAB path._

# Citation:
Burwell, S. J., Malone, S. M., Bernat, E. M., & Iacono, W. G. (2014). Does electroencephalogram phase variability account for reduced P3 brain potential in externalizing disorders?. Clinical Neurophysiology, 125(10), 2007-2015.

# Notable features of the EEG pipeline include:
* Removal of independent components that match spatial and temporal criterion (e.g., blinks, saccades)
* Robust statistical approaches for identification of artifacts, including
    * statistical thresholding using the normalized median absolute deviation (cf. Rousseeuw & Croux, 1993)
    * artifact detection through joint use of multiple features (cf. Mognon et al., 2010), vs. a single feature alone
* Identification and interpolation of channel or channel/time-segment artifacts (e.g., Nolan et al., 2010; Junghofer et al., 2000)
* Easy-to-program modular automation via proc_commander(), a tool that takes arguments similar to SPM's spm_jobman() (cf. https://en.wikibooks.org/wiki/SPM/Batch)

# Additional useful low-level functions:
* Identification of salt-bridge artifacts based on the electrical distance (Tenke et al., 2001), see get_elecdists()
* Removal of muscle-artifacts (i.e., white-noise signals) based on canonical correlation or independent components (De Clercq et al., 2006), see bsscca_correct_emg() and bssica_correct_emg(), respectively
* Easy-to-implement Current Source Density transformation (http://psychophysiology.cpmc.columbia.edu/Software/CSDtoolbox/), see proc_CSD()

# How to use:
1. Add MATLAB path to local copy of EEGLAB (strongly recommended to use version 14.1.1b or above, issues with pop_resample) 
```julia
eeglab; %keeping EEGLAB GUI open is optional, to close, simply type "close;"
```julia
2. Add MATLAB path to local copy of eeg_commander directory
```julia
eeg_commander_startup;
help eeg_commander;
```julia
 
