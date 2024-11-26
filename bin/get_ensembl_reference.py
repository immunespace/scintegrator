#!/usr/bin/env python

from pyensembl import EnsemblRelease
from pyensembl import Genome
import os
import argparse
import pandas as pd

os.environ['CACHE_DIRECTORY'] = '.'

parser = argparse.ArgumentParser(description='Get Ensembl reference data.')
parser.add_argument('--species', type=str, default='human', help='Species name')
parser.add_argument('--release', type=str, default='111', help='Ensembl release number')
args = parser.parse_args()

ensembl_species = args.species
ensembl_release = args.release

data = EnsemblRelease(release=ensembl_release, species=ensembl_species)
data.download()
data.index()
gene_ids = data.gene_ids()
genes = [data.gene_by_id(gene_id) for gene_id in gene_ids]
tr_ig_genes = [gene for gene in genes if gene.biotype in ["TR_C_gene", "TR_D_gene","TR_J_gene",
                                                        "TR_J_pseudogene","TR_V_gene", "TR_V_pseudogene","IG_C_gene", "IG_C_pseudogene","IG_D_gene",
                                                        "IG_D_pseudogene","IG_J_gene", "IG_LV_gene", "IG_pseudogene","IG_V_gene","IG_V_pseudogene"]]

lst1 = [tr_ig_genes[i].gene_id for i in range(len(tr_ig_genes))]
lst2 = [tr_ig_genes[i].gene_name for i in range(len(tr_ig_genes))]
feature=pd.DataFrame(
    {'ensemble_id':lst1,
    'gene_name':lst2
    }
)

feature.to_csv('tr_ig_genes_ensembl_v'+ensembl_release+'_'+ensembl_species+'.csv', index=False)
