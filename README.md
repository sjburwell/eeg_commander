# eeg_commander

This is a MATLAB pipeline for easy-to-program automated pre-processing of electroencephalogram (EEG) data using independent component analysis (ICA) and robust artifact thresholding. It is intended to work similar to a plug-in for the EEGLAB (https://sccn.ucsd.edu/eeglab/index.php) software suite, but it additionally contains low-level functions that work on simpler data arrays (e.g., 2- or 3-dimensional matrices) that may be useful to users. Generally, the EEG pipeline is designed to successively prune EEG artifacts identified in 1) one-second contiguous segments in the continuous data, in 2) grossly bad data channels, in 3) spatiotemporal stereotyped ICA artifacts, and in 4) channel/time-segments (e.g., trial epochs). 

Notable features of the EEG pipeline include: 
* Independent component analysis spatiotemporal artifact identification and removal
* Robust statistical approaches for identification of artifacts, including
    * joint statistical threshold identification of artifacts (e.g., Mognon et al., 2010)
    * statistical thresholding using the normalized median absolute deviation (cf. Rousseeuw & Croux, 1993)
* Identification and interpolation of channel or channel/time-segment artifacts (e.g., Nolan et al., 2010; Junghofer et al., 2000)
* Easy-to-program modular automation via proc_commander(), a tool that takes arguments similar to SPM's spm_jobman() (cf. https://en.wikibooks.org/wiki/SPM/Batch)

Additional useful low-level functions:
* Identification of salt-bridge artifacts based on the electrical distance (Tenke et al., 2001), see get_elecdists()
* Removal of muscle-artifacts (i.e., white-noise signals) based on canonical correlation (De Clercq et al., 2006), see bsscca_correct_emg()
* Easy-to-implement Current Source Density transformation (http://psychophysiology.cpmc.columbia.edu/Software/CSDtoolbox/), see proc_CSD()

Citation:
Burwell, S. J., Malone, S. M., Bernat, E. M., & Iacono, W. G. (2014). Does electroencephalogram phase variability account for reduced P3 brain potential in externalizing disorders?. Clinical Neurophysiology, 125(10), 2007-2015. 

