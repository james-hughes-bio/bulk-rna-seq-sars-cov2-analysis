# Engineering maintenance record

Date: 2026-09-06. Branch: `cleanup/bulk-only-refactor`. Main at start: `ae20644f1c6cc366fae286298dd221b00d06c165`.

## Incoming local state

All staged and unstaged diffs were inspected before modification. Large deleted CSVs and binary figures were compared byte-for-byte with reference copies. The deleted misplaced notebook and HTML were inspected as the prior cross-repository source/report. Complete binary patches, a per-file hash inventory and copies of all incoming source/reference files are preserved locally under `outputs/maintenance-20260906/`. No original loose workspace file or prior generated output was overwritten.

```text
 M .gitignore
 M README.md
D  data/.gitkeep
D  data/all_significant_DEGs.csv
D  data/gsea_results.csv
D  data/top_100_DEGs.csv
D  results/.gitkeep
D  results/gsea_dotplot.png
D  results/gsea_enrichment.png
D  results/heatmap_top_genes.png
D  results/ma_plot.png
D  results/pca.png
D  results/sample_distance_heatmap.png
D  results/volcano.png
D  scRNA_seq.Rmd
D  scRNA_seq.html
?? .gitattributes
?? R/validation.R
?? analysis/bulk_analysis.Rmd
?? data/metadata/geo_samples.csv
?? docs/AUDIT.md
?? provenance/GSE152418_series_matrix.txt.gz
?? provenance/dataset.json
?? provenance/geo_source.json
?? provenance/original_workspace_manifest.csv
?? provenance/package_versions.csv
?? provenance/reference_manifest.csv
?? provenance/workspace_disposition.csv
?? reference/figures/gsea_dotplot.png
?? reference/figures/gsea_enrichment.png
?? reference/figures/heatmap_top_genes.png
?? reference/figures/ma_plot.png
?? reference/figures/pca.png
?? reference/figures/sample_distance_heatmap.png
?? reference/figures/volcano.png
?? reference/remote_tables/all_significant_DEGs.csv
?? reference/remote_tables/gsea_results.csv
?? reference/remote_tables/top_100_DEGs.csv
?? reference/tables/all_DESeq2_results_with_symbols.csv
?? reference/tables/all_significant_DEGs.csv
?? reference/tables/gsea_results.csv
?? reference/tables/top_100_DEGs.csv
?? scripts/check_environment.R
?? scripts/refresh_geo_metadata.py
?? scripts/render.R
?? scripts/validate.R
?? scripts/verify_originals.py
?? tests/test_validation.R
```

## Engineering changes

- Added repository-local runtime initialization: local library precedence, local R-user cache location and Pandoc discovery without a user-specific path.
- Environment checks load all statically referenced and recorded dependencies and preserve the historical version record. Existing dependencies were reused; shared package installation was not modified.
- Corrected the bulk retrieval record's copied single-cell method description; retained its URL, retrieval date and snapshot hash.
- Specialized the metadata parser and render entry point to this dataset. Offline `--check` uses the saved GEO snapshot without changing it.
- Render inputs have relative paths with explicit scopes. New manifests include source helpers, metadata derivation inputs and historical dependency records. Existing/nonempty runs are refused to prevent stale output manifests; failed renders receive an explicit status.
- Added exact-byte reference/disposition checks, portable original-workspace arguments, run-manifest verification, output-preservation regression tests and a small rendering integration test.
- Kept the tracked count matrix unchanged and made its pre-existing CRLF checkout convention explicit for portable hashes.
- Protected data and historical reference bytes from line-ending conversion; kept generated outputs, local caches and local libraries ignored. Added missing validation documentation and corrected README commands. Removed only trailing whitespace from existing notebook lines.

The original audit is retained as prior context. Its cross-workspace inventory is intentional provenance, not an active dependency on another repository. See [VALIDATION.md](VALIDATION.md) for executed checks, numerical warnings and work that has not been reproduced.

## Exact file changes

### Files edited during this continuation

- `.gitattributes`
- `.gitignore`
- `README.md`
- `analysis/bulk_analysis.Rmd`
- `docs/AUDIT.md`
- `provenance/geo_source.json`
- `scripts/check_environment.R`
- `scripts/refresh_geo_metadata.py`
- `scripts/render.R`
- `scripts/validate.R`
- `scripts/verify_originals.py`

### Files added during this continuation

- `R/runtime.R`
- `docs/MAINTENANCE.md`
- `docs/VALIDATION.md`
- `scripts/validate_repository.py`
- `scripts/verify_run.py`
- `tests/test_render.R`
- `tests/test_runtime.R`

### Complete cleanup change set relative to the incoming branch commit

This includes the previously uncommitted cleanup, which was preserved. `R100` denotes a byte-identical relocation.

```text
A	.gitattributes
M	.gitignore
A	R/runtime.R
A	R/validation.R
M	README.md
A	analysis/bulk_analysis.Rmd
D	data/.gitkeep
A	data/metadata/geo_samples.csv
A	docs/AUDIT.md
A	docs/MAINTENANCE.md
A	docs/VALIDATION.md
A	provenance/GSE152418_series_matrix.txt.gz
A	provenance/dataset.json
A	provenance/geo_source.json
A	provenance/original_workspace_manifest.csv
A	provenance/package_versions.csv
A	provenance/reference_manifest.csv
A	provenance/workspace_disposition.csv
R100	results/gsea_dotplot.png	reference/figures/gsea_dotplot.png
R100	results/gsea_enrichment.png	reference/figures/gsea_enrichment.png
R100	results/heatmap_top_genes.png	reference/figures/heatmap_top_genes.png
R100	results/ma_plot.png	reference/figures/ma_plot.png
R100	results/pca.png	reference/figures/pca.png
R100	results/sample_distance_heatmap.png	reference/figures/sample_distance_heatmap.png
R100	results/volcano.png	reference/figures/volcano.png
R100	data/all_significant_DEGs.csv	reference/remote_tables/all_significant_DEGs.csv
R100	data/gsea_results.csv	reference/remote_tables/gsea_results.csv
R100	data/top_100_DEGs.csv	reference/remote_tables/top_100_DEGs.csv
A	reference/tables/all_DESeq2_results_with_symbols.csv
A	reference/tables/all_significant_DEGs.csv
A	reference/tables/gsea_results.csv
A	reference/tables/top_100_DEGs.csv
D	results/.gitkeep
D	scRNA_seq.Rmd
D	scRNA_seq.html
A	scripts/check_environment.R
A	scripts/refresh_geo_metadata.py
A	scripts/render.R
A	scripts/validate.R
A	scripts/validate_repository.py
A	scripts/verify_originals.py
A	scripts/verify_run.py
A	tests/test_render.R
A	tests/test_runtime.R
A	tests/test_validation.R
```
