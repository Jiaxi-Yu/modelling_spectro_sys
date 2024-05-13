import numpy as np
from astropy.table import Table
import fitsio
import sys

datadir = sys.argv[1]

fn_data = 'ELG_LOPnotqso_{}GC_clustering.dat.fits'
fn_rand = 'ELG_LOPnotqso_{}GC_{}_clustering.ran.fits'
P0       = 4000
par      = 'n'

def catasfun(par):
    catalog_fn,sourcedir = par[0],par[1]
    catalog=Table(fitsio.read(catalog_fn))
    if 'FKP_realistic' in catalog.colnames:
        print('catastrophics FKP ready:',catalog_fn)
    else:
        import time
        T0=time.time()
        for catas in ['realistic','failures']:
            catalog[f'FKP_{catas}'] = catalog['WEIGHT_FKP']*1
            # change WEIGHT_FKP of catastrophics
            # change WEIGHT_FKP accordingly
            nz        = np.loadtxt(sourcedir+'/ELG_LOPnotqso_nz.txt')
            ## find the nz of the true redshift
            ind_rawNZ = np.argmin(abs(catalog['Z']-nz[:,0][:,np.newaxis]),axis=0)
            ## caluclate the completeness rescaling of nz for FKP weight
            norm = catalog['NX']/nz[ind_rawNZ,3]
            dv   = (catalog[f'Z_{catas}']-catalog['Z'])/(1+catalog['Z'])*3e5
            dz   = (catalog[f'Z_{catas}']-catalog['Z'])
            # note that FKP changes are fewer than z changes, this is because
            ## 1. 1% of the extra catas has dv<1000km/s for z=1.32 catas(negligible)
            ## 2. 99% of the extra catas was not from 0.8<Z_RAW<1.6=> need to find the norm of the closest NX for FKP calculation as they had norm==0
            tmp      = np.argsort(catalog,order=['RA', 'DEC'])
            catalog  = catalog[tmp]
            norm     = norm[tmp]
            dv       = dv[tmp]
            NX       = catalog['NX']*1
            norm[norm==0] = np.nan
            print('there are {} samples to find new FKP'.format(np.sum((dv!=0)&(np.isnan(norm)))))
            for ID in np.where((dv!=0)&(np.isnan(norm)))[0]:
                if (2<ID)&(ID<len(catalog)-2):
                    norm[ID] = np.nanmedian(norm[[ID-2,ID-1,ID+1,ID+2]])
                elif ID<2:
                    norm[ID] = np.nanmedian(norm[[ID+1,ID+2]])
                elif ID>len(catalog)-2:
                    norm[ID] = np.nanmedian(norm[[ID-2,ID-1]])

                ## update NX for norm ==0
                ind_newNZ = np.argmin(abs(catalog[f'Z_{catas}'][ID]-nz[:,0]))
                NX[ID] = norm[ID]*nz[ind_newNZ,3]
            ## select all catastrophics
            sel = dv!=0
            ind_newNZ = np.argmin(abs(catalog[f'Z_{catas}'][sel]-nz[:,0][:,np.newaxis]),axis=0)
            ## update NX and WEIGHT_FKP columns for all catastrophics
            NX[sel]  = norm[sel]*nz[ind_newNZ,3]
            catalog[f'FKP_{catas}'][sel] = 1 / (NX[sel]*P0+1)
            catalog[f'FKP_{catas}'][np.isnan(catalog[f'FKP_{catas}'])] = 1
            # find the nz of the catastrophics redshift
            print('implement catastrophophics took time:{:.2f}s'.format(time.time()-T0))
        catalog.write(catalog_fn,overwrite=True)
        print('catastrophics FKP corrected')

#catalog_fns = [datadir.format(mockid,mockid)+fn_rand.format(GC,ranid) for GC in ['N','S'] for mockid in range(Nrand) for ranid in range(18)]+[datadir.format(mockid,mockid)+fn_data.format(GC) for GC in ['N','S'] for mockid in range(Nrand) ]
#sourcedirs  = [datadir.format(mockid,mockid) for GC in ['N','S'] for mockid in range(Nrand) for ranid in range(18)]+[datadir.format(mockid,mockid) for GC in ['N','S'] for mockid in range(Nrand)]
Nrand = 13
catalog_fns = [datadir.format(mockid,mockid)+fn_rand.format(GC,ranid) for GC in ['N','S'] for mockid in range(Nrand,25) for ranid in range(18)]+[datadir.format(mockid,mockid)+fn_data.format(GC) for GC in ['N','S'] for mockid in range(Nrand,25) ]
sourcedirs  = [datadir.format(mockid,mockid) for GC in ['N','S'] for mockid in range(Nrand,25) for ranid in range(18)]+[datadir.format(mockid,mockid) for GC in ['N','S'] for mockid in range(Nrand,25)]

if par == 'n':
    for catalog_fn,sourcedir in zip(catalog_fns,sourcedirs):
        catasfun([catalog_fn,sourcedir])
if par == 'y':
    from multiprocessing import Pool
    with Pool(processes = 64) as pool:
        pool.map(catasfun, zip(catalog_fns,sourcedirs))

