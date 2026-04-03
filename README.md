# RNA-seq Analysis of SARS-CoV-2 Infection

## Overview
This project presents a bulk RNA-seq differential expression analysis of SARS-CoV-2 infection using a publicly available dataset. The aim was to identify genes significantly associated with infection status and to investigate the biological pathways underlying the host transcriptional response.

## Dataset
The dataset used in this study is publicly available from the Gene Expression Omnibus (GEO).

- **Accession:** GSE152418
- **Source:** https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE152418

## Methods
The analysis was performed in R using a standard bulk RNA-seq workflow:

- Differential expression analysis with **DESeq2**
- Log2 fold-change shrinkage with **apeglm**
- Visualisation using **ggplot2** and **pheatmap**
- Functional enrichment analysis using **clusterProfiler**
- Gene annotation using **org.Hs.eg.db** and **AnnotationDbi**

## Key Findings
Using an adjusted p-value threshold of **0.05** and an absolute log2 fold change threshold of **1**, a total of **3879** genes were identified as significantly differentially expressed, including **3688 upregulated** and **191 downregulated** genes in infected samples.

The main findings were:

- Clear separation between infected and control samples in PCA
- Strong upregulation of immune-related pathways, including **B cell-mediated immunity** and **immunoglobulin-mediated immune response**
- Increased expression of cell cycle-associated genes, including **TK1, RRM2, PLK1, UBE2C,** and **CCNA2**

These results suggest that SARS-CoV-2 infection is associated with a coordinated host transcriptional response involving both immune activation and proliferation-related transcriptional programmes.

## Selected Visualisations

### PCA
![PCA](results/pca.png)

### Volcano Plot
![Volcano](results/volcano.png)

### Heatmap of Top Differentially Expressed Genes
![Heatmap](results/heatmap_top_genes.png)

## Limitations
This analysis has several limitations that should be considered:

- Sample conditions were inferred from sample names due to lack of explicit metadata, which may introduce classification bias
- Bulk RNA-seq does not resolve cell-type-specific effects
- Potential technical or biological confounders could not be fully modelled
- Functional enrichment analysis depends on existing annotation databases and should be interpreted cautiously

## Technical Skills Demonstrated
- Bulk RNA-seq differential expression analysis
- Statistical modelling of count data with DESeq2
- Effect-size shrinkage with apeglm
- Transcriptomic data visualisation
- Functional enrichment analysis
- Gene annotation and identifier mapping
- Critical evaluation of methodological limitations in bulk RNA-seq studies

## Reproducibility
To reproduce this analysis:

1. Download the raw count dataset from GEO accession **GSE152418**
2. Place the count file in the appropriate project directory
3. Open and knit `rna_seq_analysis.Rmd`
4. Generated outputs will be written to the relevant results folders/files in the repository

## Files
- `rna_seq_analysis.Rmd` — main analysis workflow
- `rna_seq_analysis.pdf` — rendered project report
- `results/` — figures and output files
- `data/` — processed tables and supporting files

## Future Directions
Possible next steps include:

- Single-cell RNA-seq analysis to resolve cell-type-specific responses
- Integration with proteomics or metabolomics data
- Experimental validation of key differentially expressed genes
- Predictive modelling or biomarker discovery using machine learning

## Author
James Hughes
