# modelling_spectro_sys for DESI lightcones
The codes in this directory is for implementing ELG spectroscopic systematics on DESI-data-like catalogues and compute the two-point correlation function and power spectra. 

```bash
bash make_LSS.sh
``` 

to get the ```*full_HPmapcut.dat.fits``` catalogues from DESI data/mock directory, making our own large-scale structure catalogues for clustering measurements. These LSS ctalogues (LSS) has been contaminated by the catastrophics. 

```bash
bash compute_2pt.sh
``` 

after getting the LSS catalogues to compute the two-point correlation function and power spectra of uncontaminated galaxy mocks and catastrophics contaminated mocks. The default setting is with thetacut=0.05 for Y1 fibre collision effect and with window function computation for mock0. 