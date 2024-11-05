# Table of Contents
- [Introduction](#introduction)
- [Implementing Spectroscopic Systematics in Boxes](#implement-spectroscopic-systematics-in-boxes)
- [Implementing Spectroscopic Systematics in Lightcones](#implement-spectroscopic-systematics-in-lightcones)
- [References](#references)

# Introduction

This repository provides tools for implementing spectroscopic systematics in galaxy mocks that are uncontaminated (free from systematic effects). Spectroscopic systematics here include redshift uncertainties and catastrophic errors that cannot be corrected on an element-wise basis. The galaxy mocks can be provided either in boxes (Z-axis as the line-of-sight) or in a lightcone format, and the cosmology is flat-$\Lambda$CDM. 


# Implement Spectroscopic Systematics in Boxes
For implementing spectroscopic systematics in boxes, a tutorial Jupyter notebook is provided for reference:
```spectroscopic_systematics.ipynb```

# Implement Spectroscopic Systematics in Lightcones
This section explains how to apply spectroscopic systematics in DESI mocks (which use the same data format as observations) and compute the two-point correlation function and power spectra (2-point statistics). The recommended cluster for this computation is NERSC.

## Installation
If you use the code for the first time, start by create a new environment and load the DESI environment on NERSC:

```bash
source /global/common/software/desi/users/adematti/cosmodesi_environment.sh main
conda create -n spec_sys 
source activate spec_sys
```

Then install the DESI large-scale structure (LSS) code under the ```catastrophics``` branch and configure the environment:

```bash
export LSSCODE=${HOME}/codes
if [ ! -e "${LSSCODE}" ]; then
    mkdir -p ${LSSCODE}
fi

cd ${LSSCODE}
git clone git@github.com:Jiaxi-Yu/LSS.git
cd ${LSSCODE}/LSS
git pull
git checkout catastrophics

source LSS_path.sh ${LSSCODE}
python setup.py develop --user
```
## Usage
After the first installation, apply spectroscopic systematics to the lightcone mocks and produce their LSS catalogues:
```bash
source activate spec_sys
export LSSCODE=${HOME}/codes
source ${LSSCODE}/LSS/scripts/LSS_path.sh ${LSSCODE}
bash ${LSSCODE}/LSS/scripts/spec_sys_make_LSS.sh 
``` 

Finally, compute the 2-point statistics:

```bash
export LSSCODE=${HOME}/codes
source ${LSSCODE}/LSS/scripts/LSS_path.sh ${LSSCODE}
bash ${LSSCODE}/LSS/scripts/spec_sys_compute_2pt.sh
``` 

# References
* SDSS redshift uncertainties ([Yu et al. 2022](https://ui.adsabs.harvard.edu/abs/2022MNRAS.516...57Y/abstract)) 
* DESI redshift uncertainties from Early Data Release (EDR) ([Yu et al. 2024a](https://ui.adsabs.harvard.edu/abs/2024MNRAS.527.6950Y/abstract)) 
* DESI ELG catastrophics from Data Release 1 (DR1) ([Yu et al. 2024b](https://arxiv.org/abs/2405.16657))
