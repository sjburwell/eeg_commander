
JH identified an error in trigger assignment that was caused by pop_resample from the eeglab13_4_4b toolbox.
The eeglab13_4_4b version of pop_resample rounds the latency values, which causes problems with eeg_unepoch.
If two triggers (e.g., 4 and 'proc' [-1]) have the same latency, eeg_unepoch will displace triggers after that
point in the file, which will lead to segments of EEG having the incorrect trigger assignment.

Using the pop_resample from eeglab9_0_2_3b does not lead to this problem, because this version of pop_resample
does not round latencies. Thus, I have placed a copy of the eeglab9_0_2_3b pop_resample in functions/format/plugin_eeglab.
The startup.m file still loads eeglab13_4_4b, but will use the pop_resample from eeglab9_0_2_3b.

 - JH 11.23.16
