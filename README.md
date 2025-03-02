(A)nalysis (S)imulation (R)econstruction Software Package
for Droplet Coherent Diffraction Imaging data
================================================================================

ASR is an integrated system for ANALYSIS of pnCCD scattering detector data, a 
before running the code for the first time, please make sure to change the
data, and output source paths in **'main.m'**. 

If you just want to try it out, just run **'main.m'** without any changes.


# Keyboard Shortcuts

NAVIGATION
--------------------------------------------------------------------------------
leftarrow   =   previous hit
rightarrow  =   next hit
s           =   save database
l           =   load file
c           =   clear command window and mouse pointer


DATA PREPARATION
--------------------------------------------------------------------------------
1           =   center image
2           =   find droplet shape


RECONSTRUCTION
--------------------------------------------------------------------------------
3           =   initialize iterative reconstruction with current data
r OR 0      =   reset iterative reconstruction
4           =   add current steps and loops to reconstruction plan using ER
5           =   add current steps and loops to reconstruction plan using DCDI
6           =   add current steps and loops to reconstruction plan using ntDCDI
7           =   add current steps and loops to reconstruction plan using ntHIO

enter       =   run reconstruction plan
escape      =   stop reconstruction process


SIMULATION & DECONVOLUTION
--------------------------------------------------------------------------------
x           =   start simulation window
d           =   run deconvolution on current image


AUTOMATIC RECONSTRUCTION SCRIPTS
--------------------------------------------------------------------------------
f11         =   scan for delta parameter
f12         =   scan for alpha parameter
k           =   run automated reconstruction for all consecutive hits & runs


Author:

    Anatoli Ulmer  
    anatoli.ulmer@gmail.com  
    Berlin, 2025 
