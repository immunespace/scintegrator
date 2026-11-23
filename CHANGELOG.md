## v2.0.0 - 2026-11-23

### Added
- Optional B cell summary step (`BCELL_SUMMARY`) that integrates the annotated scRNA-seq object with scBCR repertoire data (AIRR format) and renders an HTML report
  - `--scbcr`: run the summary after the main pipeline, using the `concat.h5ad` from clustering
  - `--scrna` with `--scbcr`: run only the summary, without a samplesheet
  - `--bcell_nb`: path to the B cell summary notebook (default `assets/bcell_summary.ipynb`)
- `subject_id` and `study_id` columns in the samplesheet
- Summary tables by study, subject, sample, B cell subtype and isotype: chain counts, isotype usage, clone size, mutation frequency, CDR3 length and V/J allele usage
- All summary tables saved in a single file, `D3_statistics.db` (SQLite; Excel optional), in `<outdir>/bcell_summary/statistics/`
- README documentation for running the B cell summary

### Changed
- Renamed the B cell options from `--bcelldb`, `--bcelldb_only`, `--bcelldb_adata`, `--bcelldb_scbcr` and `--bcelldb_nb` to `--scbcr`, `--scrna` and `--bcell_nb`. The `bcelldb_summary` module is now `bcell_summary`
- B cell summary results are published to `<outdir>/bcell_summary/`
