#!/bin/bash

# load the environment
source /global/common/software/desi/users/adematti/cosmodesi_environment.sh main
# load the LSS standard scripts
export LSSCODE=${HOME}/
PYTHONPATH=$PYTHONPATH:$LSSCODE/LSS/py
export OMP_NUM_THREADS=64
catas=('realistic' 'failures')

MOCKNUM=0
fn=${SCRATCH}/test/altmtl${MOCKNUM}/mock${MOCKNUM}/LSScats

# standard 2pcf
outputs=${fn}/smu/xipoles_ELG_LOPnotqso_GCcomb_1.1_1.6_default_FKP_lin10_njack0_nran18_split20_thetacut0.05.txt
if [ ! -f "${outputs}" ]; then
    echo "calculate clustering ${outputs}"
    srun -N 1 -C gpu -t 04:00:00 --gpus 4 --qos interactive --account desi_g python xirunpc.py --gpu --tracer ELG_LOPnotqso --region NGC SGC --corr_type smu --weight_type default_FKP --njack 0 --nran 18 --basedir ${fn}  --outdir ${fn} --thetacut 0.05
fi
# 2pcf without 1.31<z<1.33
outputs=${fn}/smu/xipoles_ELG_LOPnotqso_GCcomb_1.1_1.6elgzcatas_default_FKP_lin10_njack0_nran18_split20_thetacut0.05.txt
if [ ! -f "${outputs}" ]; then
    echo "calculate clustering ${outputs}"
    srun -N 1 -C gpu -t 04:00:00 --gpus 4 --qos interactive --account desi_g python xirunpc.py --gpu --tracer ELG_LOPnotqso --region NGC SGC --corr_type smu --weight_type default_FKP --njack 0 --nran 18 --basedir ${fn}  --outdir ${fn} --thetacut 0.05 --option elgzcatas
fi
# standard pk
outputs=${fn}/pk/pkpoles_ELG_LOPnotqso_GCcomb_1.1_1.6_default_FKP_lin_thetacut0.05.npy
if [ ! -f "${outputs}" ]; then
    if [ ${MOCKNUM} == "0" ]; then
        echo "calculate with window clustering ${outputs}"
        srun -N 1 -n 64 -C cpu -t 04:00:00 --qos interactive --account desi python pkrun.py --tracer ELG_LOPnotqso --region NGC SGC --weight_type default_FKP --rebinning y --nran 18 --basedir ${fn} --outdir ${fn} --thetacut 0.05  --calc_win y
    else
        echo "calculate without window clustering ${outputs}"
        srun -N 1 -n 64 -C cpu -t 04:00:00 --qos interactive --account desi python pkrun.py --tracer ELG_LOPnotqso --region NGC SGC --weight_type default_FKP --rebinning y --nran 18 --basedir ${fn} --outdir ${fn} --thetacut 0.05        
    fi
fi
# pk without 1.31<z<1.33
outputs=${fn}/pk/pkpoles_ELG_LOPnotqso_GCcomb_1.1_1.6elgzcatas_default_FKP_lin_thetacut0.05.npy
if [ ! -f "${outputs}" ]; then
    if [ ${MOCKNUM} == "0" ]; then
        echo "calculate with window clustering ${outputs}"
        srun -N 1 -n 64 -C cpu -t 04:00:00 --qos interactive --account desi python pkrun.py --tracer ELG_LOPnotqso --region NGC SGC --weight_type default_FKP --rebinning y --nran 18 --basedir ${fn} --outdir ${fn} --thetacut 0.05 --option elgzcatas  --calc_win y
    else
        echo "calculate without window clustering ${outputs}"
        srun -N 1 -n 64 -C cpu -t 04:00:00 --qos interactive --account desi python pkrun.py --tracer ELG_LOPnotqso --region NGC SGC --weight_type default_FKP --rebinning y --nran 18 --basedir ${fn} --outdir ${fn} --thetacut 0.05 --option elgzcatas        
    fi
fi
# catastrophics 2pt
for j in `seq 0 1`; do
    outputs=${fn}/smu/xipoles_ELG_LOPnotqso_GCcomb_1.1_1.6_default_FKP_lin10_njack0_nran18_split20_${catas[$j]}_thetacut0.05.txt
    if [ ! -f "${outputs}" ]; then 
        echo "calculate clustering ${outputs}"
        srun -N 1 -C gpu -t 04:00:00 --gpus 4 --qos interactive --account desi_g python xirunpc.py --gpu --tracer ELG_LOPnotqso --region NGC SGC --corr_type smu --weight_type default_FKP --njack 0 --nran 18 --basedir ${fn}  --outdir ${fn} --catas_type ${catas[$j]} --thetacut 0.05
    fi
    outputs=${fn}/pk/pkpoles_ELG_LOPnotqso_GCcomb_1.1_1.6_default_FKP_lin_${catas[$j]}_thetacut0.05.npy
    if [ ! -f "${outputs}" ]; then 
        if [ ${MOCKNUM} == "0" ]; then
            echo "calculate with window clustering ${outputs}"
            srun -N 1 -n 64 -C cpu -t 04:00:00 --qos interactive --account desi python pkrun.py --tracer ELG_LOPnotqso --region NGC SGC --weight_type default_FKP --rebinning y --nran 18 --basedir ${fn}  --outdir ${fn} --catas_type ${catas[$j]} --thetacut 0.05 --calc_win y
        else
            echo "calculate without window clustering ${outputs}"
            srun -N 1 -n 64 -C cpu -t 04:00:00 --qos interactive --account desi python pkrun.py --tracer ELG_LOPnotqso --region NGC SGC --weight_type default_FKP --rebinning y --nran 18 --basedir ${fn}  --outdir ${fn} --catas_type ${catas[$j]} --thetacut 0.05
        fi
    fi
done 
