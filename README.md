# Bulk RNA-seq Analysis of SARS-CoV-2 Infection

This repository contains a bulk RNA-seq differential expression analysis of SARS-CoV-2 infection using a publicly available human transcriptomic dataset. The project combines statistical analysis, biological interpretation, and data visualisation in R, with outputs presented in both source (`.Rmd`) and report (`.pdf`) formats.

## Project Snapshot

| Item | Details |
| --- | --- |
| Dataset | GEO accession `GSE152418` |
| Analysis type | Bulk RNA-seq differential expression |
| Primary tool | `DESeq2` |
| Organism | Human |
| Conditions compared | `Infected` vs `Control` |
| Significant DEGs used in report | `3879` |
| Upregulated | `3688` |
| Downregulated | `191` |

## Why This Project Matters

This project was designed to investigate how SARS-CoV-2 infection reshapes host gene expression. It demonstrates an end-to-end transcriptomics workflow, from raw count data to biological interpretation, and highlights the kind of practical computational biology work used in real RNA-seq studies.

The analysis shows:

- clear separation between infected and control samples in PCA
- widespread transcriptional activation in infected samples
- strong enrichment of immune-associated pathways such as `immunoglobulin mediated immune response` and `B cell mediated immunity`
- prominent cell cycle-associated genes including `TK1`, `RRM2`, `PLK1`, `UBE2C`, and `CCNA2`

Together, these results suggest that SARS-CoV-2 infection is associated with a coordinated host response involving immune activation and proliferative transcriptional programmes.

## Methods Used

The workflow was implemented in R and includes:

- count-based differential expression analysis with `DESeq2`
- log2 fold-change shrinkage with `apeglm`
- gene annotation with `AnnotationDbi` and `org.Hs.eg.db`
- exploratory and differential expression visualisation with `ggplot2`, `ggrepel`, and `pheatmap`
- Gene Ontology enrichment analysis with `clusterProfiler`

## Repository Structure

```text
bulk-rna-seq-sars-cov2-analysis/
|-- README.md
|-- .gitignore
|-- GSE152418_p20047_Study1_RawCounts.txt
|-- rna_seq_analysis.Rmd
|-- rna_seq_analysis.pdf
|-- data/
|   |-- sample_metadata.csv
|   |-- all_significant_DEGs.csv
|   |-- top_100_DEGs.csv
|   `-- gsea_results.csv
`-- results/
    |-- pca.png
    |-- volcano.png
    |-- ma_plot.png
    |-- heatmap_top_genes.png
    |-- sample_distance_heatmap.png
    |-- gsea_dotplot.png
    `-- gsea_enrichment.png
```

## Key Files

- [`GSE152418_p20047_Study1_RawCounts.txt`](./GSE152418_p20047_Study1_RawCounts.txt): raw count matrix used as input for the analysis
- [`rna_seq_analysis.Rmd`](./rna_seq_analysis.Rmd): full analysis workflow and code
- [`rna_seq_analysis.pdf`](./rna_seq_analysis.pdf): rendered report
- [`data/top_100_DEGs.csv`](./data/top_100_DEGs.csv): top differentially expressed genes
- [`data/gsea_results.csv`](./data/gsea_results.csv): enriched biological pathways

## Selected Figures

### PCA
![PCA](./results/pca.png)

### Volcano Plot
![Volcano Plot](./results/volcano.png)

### Heatmap of Top Differentially Expressed Genes
![Heatmap](./results/heatmap_top_genes.png)

## Biological Interpretation

The transcriptomic signature observed here is consistent with a strong host response to viral infection. Immune-related enrichment supports activation of adaptive immune processes, while the strong cell cycle signal may reflect immune-cell proliferation, altered blood cell composition, or dysregulation of host cellular machinery during infection.

Because this is a bulk RNA-seq dataset, these results should be interpreted with appropriate caution. Bulk expression profiles cannot fully separate true within-cell transcriptional changes from shifts in cell-type composition.

## Technical Skills Demonstrated

- RNA-seq preprocessing and quality-aware filtering
- differential expression modelling with count data
- effect-size shrinkage and interpretation of log2 fold changes
- pathway enrichment analysis
- transcriptomic data visualisation
- biological interpretation of host-response signatures
- reproducible reporting with R Markdown

## Reproducibility

To reproduce the analysis:

1. Open [`rna_seq_analysis.Rmd`](./rna_seq_analysis.Rmd) in RStudio.
2. Ensure the required packages are installed:
   `DESeq2`, `apeglm`, `ggplot2`, `ggrepel`, `pheatmap`, `clusterProfiler`, `enrichplot`, `org.Hs.eg.db`, `AnnotationDbi`.
3. Knit the R Markdown document.
4. Review the generated report and exported result tables in `data/`.

## Dataset Source

- GEO: [GSE152418](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE152418)

## Author

James Hughes
