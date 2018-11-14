% -- CSD transformation
config(1).csd.montage      = '10-5-System_Mastoids_EGI129.csd'; % (default; CSD toolbox)
config(1).csd.lambda       =                           1.0e-5 ; % (default; smoothing constant)
config(1).csd.headrad      =                             10.0 ; % (default; head radius)
config(1).csd.spline_m     =                               4  ; % (default; spline flexibility)
config(1).csd.outdata      =                             'CSD'; % (default; other option 'SP')
config(1).csd.CSDparms     =          './61elec_CSDparams.mat'; % matfile to save/load G,H

