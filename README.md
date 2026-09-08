# Bulk RNA-seq analysis of SARS-CoV-2 PBMC samples

This repository contains a compact, reproducible bulk RNA-seq analysis of the GSE152418 PBMC dataset.

The analysis uses the original 34 libraries, with 17 controls and 17 libraries carrying the historical `Infected` label. That infected group contains 16 acute COVID-19 libraries and one convalescent library, and repeat-draw identifiers are present. The condition-only DESeq2 model is therefore treated as an exploratory reproduction rather than a donor-independent disease-effect analysis.

## Repository structure

- `data/` — gene-count matrix and GEO-derived sample metadata
- `analysis/` — the complete R Markdown workflow
- `outputs/` — selected result tables and figures
- `README.md` — project overview and reproduction instructions

## Analysis

The workflow performs:

- input and sample-ID validation
- low-count filtering
- DESeq2 differential expression
- apeglm log2-fold-change shrinkage
- PCA
- volcano and MA plots
- expression and sample-distance heatmaps
- GO Biological Process gene-set enrichment analysis
- export of differential-expression and enrichment results

The retained result snapshot contains 3,879 significant genes at adjusted p-value < 0.05 and |shrunken log2 fold change| > 1: 3,688 higher and 191 lower in the historical `Infected` group.

## Run

Use R 4.5.2 or a compatible recent R installation with these packages available:

`DESeq2`, `apeglm`, `ggplot2`, `ggrepel`, `pheatmap`, `clusterProfiler`, `enrichplot`, `org.Hs.eg.db`, `AnnotationDbi`, `dplyr`, `readr`, `tibble`, `tidyr`, `BiocParallel`, `rmarkdown`, and `knitr`.

From the repository root:

```sh
Rscript -e "rmarkdown::render('analysis/bulk_analysis.Rmd', output_dir='outputs')"
```

The notebook writes generated tables to `outputs/tables/`, figures to `outputs/figures/`, and the rendered HTML report to `outputs/`.

## Data

The count matrix is derived from GSE152418 and contains gene-level counts rather than FASTQ reads. Metadata are retained from GEO and matched exactly to normalized count-column identifiers before analysis.

GEO: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE152418

## Limitations

The cohort mixes acute infection and convalescence, and repeat-draw identifiers mean donor independence is unresolved. Severity, sex, timing, and other covariates are not modelled in this reproduction. Bulk PBMC expression also cannot distinguish changes in cell composition from within-cell transcriptional regulation. Results should therefore be interpreted as exploratory expression associations under the specified model, not causal or cell-intrinsic effects.

Author: James Hughes
