# RNA-seq Analysis of SARS-CoV-2 Infection

## Overview
This project performs differential gene expression analysis of SARS-CoV-2 infection using bulk RNA-seq data. The aim was to identify significantly altered genes and associated biological pathways.

## Dataset
Publicly available RNA-seq dataset (GEO: GSE152418).

## Methods
- Differential expression analysis: DESeq2
- Log fold change shrinkage: apeglm
- Visualisation: PCA, volcano plot, MA plot, heatmap
- Functional enrichment: Gene Set Enrichment Analysis (GSEA) using clusterProfiler

## Key Results
- 6393 genes upregulated and 2869 downregulated (padj < 0.05)
- Strong separation between infected and control samples in PCA
- Enrichment of immune-related pathways (B cell, humoral response)
- Upregulation of cell cycle-associated genes (e.g., TK1, PLK1, CCNA2)

## Key Findings
SARS-CoV-2 infection induces a coordinated transcriptional response characterised by:
- Immune system activation
- Increased expression of cell cycle-related genes

## Limitations
Sample conditions were inferred from sample names due to lack of explicit metadata, which may introduce classification bias.

## Future Work
- Single-cell RNA-seq analysis to resolve cell-type-specific effects
- Integration with proteomics or metabolomics data
- Machine learning approaches for biomarker discovery

## Author
James Hughes
