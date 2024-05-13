#!/bin/bash

# load the environment
source /global/common/software/desi/users/adematti/cosmodesi_environment.sh main
# get the desihub/LSS scripts
cd ~
git clone https://github.com/desihub/LSS.git
cd ~/LSS
export LSSCODE=${HOME}/
PYTHONPATH=$PYTHONPATH:$LSSCODE/LSS/py
export OMP_NUM_THREADS=64

# get the SecondGen ELG AbacusSummit mocks
MOCKNUM=0
fn=${SCRATCH}/test/altmtl${MOCKNUM}/mock${MOCKNUM}/LSScats
if [ ! -d "${fn}" ]; then
    echo "home directory ${fn} do not exists, creating it..."
    mkdir ${SCRATCH}/test/
    mkdir ${SCRATCH}/test/altmtl${MOCKNUM}
    mkdir ${SCRATCH}/test/altmtl${MOCKNUM}/mock${MOCKNUM}
    mkdir ${fn}
    cp /global/cfs/cdirs/desi/survey/catalogs/Y1/mocks/SecondGenMocks/AbacusSummit_v4_1/altmtl${MOCKNUM}/mock${MOCKNUM}/LSScats/ELG_LOPnotqso_*full_HPmapcut.*.fits ${fn}
    cp /global/cfs/cdirs/desi/survey/catalogs/Y1/mocks/SecondGenMocks/AbacusSummit_v4_1/altmtl${MOCKNUM}/mock${MOCKNUM}/LSScats/ELG_LOPnotqso_frac_tlobs.fits ${fn}
else
    echo "home directory ${fn} exists, continue to check the clustering catalogues..."
fi

# get the LSS catalogues for ELG AbacusSummit mocks
## implement the catastrophics in this step
outputs=${fn}/ELG_LOPnotqso_SGC_17_clustering.ran.fits
if [ ! -f "${outputs}" ]; then
    echo "clustering ${outputs} are not complete, making the clustering*fits files"
    srun -N 1 -n 1 -c 64 -C cpu -t 04:00:00 --qos interactive --account desi python mkCat_SecondGen_amtl.py --base_output ${SCRATCH}/test/altmtl${MOCKNUM} --mockver ab_secondgen --mocknum ${MOCKNUM}  --survey Y1 --add_gtl y --specdata iron --tracer ELG_LOP --notqso y --minr 0 --maxr 18 --fulld n --fullr n --apply_veto n --use_map_veto _HPmapcut --mkclusran y  --nz y --mkclusdat y --splitGC y --targDir /dvs_ro/cfs/cdirs/desi/survey/catalogs/Y1/mocks/SecondGenMocks/AbacusSummit_v4_1 --outmd 'notscratch' 
else
    echo "clustering ${outputs} are complete, continue to the next mock"
fi

# update the WEIGHT_FKP in the LSS catalogues 
srun -N 1 -n 1 -c 64 -C cpu -t 04:00:00 --qos interactive --account desi python catas_FKP.py ${SCRATCH}/test/altmtl${}/mock${}/LSScats/




