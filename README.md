Project: (A)nalysis (S)Simulation (R)Reconstruction Software Package (working title)

ASR is an integrated system for ANALYSIS of pnCCD scattering detector data, a small SIMULATION toolbox for doped ellipsoidal samples, combined with a RECONSTRUCTION framework applying iterative phasing algorithms in combination with fits and simulations.
Start the Software by running the 'startPhasing.m' file, in which you can include your source paths or directly run 'gui\pnccdGUI.m' if you have set up your 'getXfelPaths.m' path file (highly recommended):
Put your source, data (pnccd), databases (db), reconstructed data (recon) and image saving (img) directories into the file 'dataPipeline\getXfelPaths.m'.

I would like to thank and give credit to all the nice people whos code uploads I used in this project.

nan_rscan (modified version of rscan) -  Narupon Chattrapiban (2020). Radial Scan (https://www.mathworks.com/matlabcentral/fileexchange/18102-radial-scan), MATLAB Central File Exchange. Retrieved September 18, 2020. 
str2num_fast - Copyright © Yair Altman - Undocumented Matlab. All rights reserved.
iseven,isodd - Copyright (c) 2012, Dan K

Author:
    Anatoli Ulmer