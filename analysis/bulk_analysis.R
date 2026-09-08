# Bulk RNA-seq analysis of SARS-CoV-2 PBMC samples
# Standalone R implementation of the workflow documented in bulk_analysis.Rmd.

set.seed(42)

suppressPackageStartupMessages({
  library(apeglm)
  library(ggplot2)
  library(ggrepel)
  library(pheatmap)
  library(DESeq2)
  library(enrichplot)
  library(clusterProfiler)
  library(org.Hs.eg.db)
  library(AnnotationDbi)
  library(dplyr)
  library(tibble)
})

BiocParallel::register(BiocParallel::SerialParam())

repo_root <- if (file.exists(file.path("data", "GSE152418_counts.txt"))) {
  normalizePath(".", mustWork = TRUE)
} else {
  normalizePath("..", mustWork = TRUE)
}

counts_path <- file.path(repo_root, "data", "GSE152418_counts.txt")
metadata_path <- file.path(repo_root, "data", "metadata.csv")
tables_dir <- file.path(repo_root, "outputs", "tables")
figures_dir <- file.path(repo_root, "outputs", "figures")

dir.create(tables_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

normalise_sample_ids <- function(x) gsub("[-.]", "_", trimws(x))

validate_bulk_inputs <- function(expr, meta) {
  expr <- as.matrix(expr)

  if (!is.numeric(expr) || any(!is.finite(expr)) || any(expr < 0) ||
      any(expr != floor(expr))) {
    stop("Counts must be finite nonnegative integers.")
  }

  ids <- normalise_sample_ids(colnames(expr))

  if (is.null(rownames(expr)) || anyNA(rownames(expr)) ||
      any(!nzchar(rownames(expr))) || anyDuplicated(rownames(expr))) {
    stop("Gene IDs must be present and unique.")
  }

  if (is.null(ids) || anyNA(ids) || any(!nzchar(ids)) || anyDuplicated(ids)) {
    stop("Sample IDs are missing or collide after normalization.")
  }

  if (!all(c("sample", "condition") %in% names(meta))) {
    stop("Metadata require sample and condition columns.")
  }

  meta$sample <- normalise_sample_ids(meta$sample)

  if (anyNA(meta$sample) || any(!nzchar(meta$sample)) ||
      anyDuplicated(meta$sample) || !setequal(ids, meta$sample)) {
    stop("Metadata and count samples must match exactly.")
  }

  meta <- meta[match(ids, meta$sample), , drop = FALSE]

  if (anyNA(meta$condition) ||
      any(!meta$condition %in% c("Control", "Infected"))) {
    stop("Unknown condition in metadata.")
  }

  meta$condition <- factor(meta$condition, levels = c("Control", "Infected"))

  if (any(table(meta$condition) < 2L)) {
    stop("At least two libraries per condition are required.")
  }

  if (any(colSums(expr) == 0)) stop("Empty count library.")

  rownames(meta) <- ids
  colnames(expr) <- ids

  list(counts = expr, metadata = meta)
}

# Load and validate data -----------------------------------------------------

expr <- read.delim(counts_path, row.names = 1, check.names = FALSE)
colnames(expr) <- normalise_sample_ids(colnames(expr))
meta <- read.csv(metadata_path, check.names = FALSE, stringsAsFactors = FALSE)

validated <- validate_bulk_inputs(expr, meta)
expr <- validated$counts
meta <- validated$metadata

# Differential expression ---------------------------------------------------

expr <- expr[, rownames(meta)]
expr <- expr[rowSums(expr) >= 10, ]

dds <- DESeqDataSetFromMatrix(
  countData = expr,
  colData = meta,
  design = ~ condition
)

dds <- DESeq(dds)
res <- lfcShrink(
  dds,
  coef = "condition_Infected_vs_Control",
  type = "apeglm"
)

res_df <- as.data.frame(res) |>
  tibble::rownames_to_column("gene_id") |>
  dplyr::mutate(ensembl_id = gsub("\\..*", "", gene_id))

symbol_candidates <- AnnotationDbi::mapIds(
  org.Hs.eg.db,
  keys = unique(res_df$ensembl_id),
  column = "SYMBOL",
  keytype = "ENSEMBL",
  multiVals = "list"
)

symbol_candidates <- lapply(
  symbol_candidates,
  function(x) sort(unique(x[!is.na(x)]))
)

res_df$symbol <- vapply(
  res_df$ensembl_id,
  function(id) {
    values <- symbol_candidates[[id]]
    if (length(values) == 1L) values else id
  },
  character(1)
)

res_df <- res_df |>
  dplyr::mutate(
    deg_class = dplyr::case_when(
      is.na(padj) ~ "Not tested",
      padj < 0.05 & log2FoldChange > 1 ~ "Up",
      padj < 0.05 & log2FoldChange < -1 ~ "Down",
      TRUE ~ "NS"
    ),
    significant = ifelse(
      !is.na(padj) & padj < 0.05 & abs(log2FoldChange) > 1,
      "Significant",
      "NS"
    )
  )

sig <- res_df |>
  dplyr::filter(!is.na(padj), padj < 0.05, abs(log2FoldChange) > 1)

# PCA ----------------------------------------------------------------------

vsd <- vst(dds, blind = FALSE)
pca_plot <- plotPCA(vsd, intgroup = "condition") +
  labs(title = "PCA of Gene Expression")

ggsave(
  file.path(figures_dir, "pca.png"),
  pca_plot,
  width = 7,
  height = 5,
  dpi = 300
)

# Volcano plot --------------------------------------------------------------

top_genes <- res_df |>
  dplyr::filter(!is.na(padj)) |>
  dplyr::arrange(padj) |>
  dplyr::slice_head(n = 10) |>
  dplyr::pull(gene_id)

label_data <- res_df |>
  dplyr::filter(gene_id %in% top_genes)

volcano_plot <- ggplot(
  res_df,
  aes(
    x = log2FoldChange,
    y = -log10(pmax(padj, .Machine$double.xmin)),
    colour = deg_class
  )
) +
  geom_point(alpha = 0.5, size = 1) +
  geom_text_repel(
    data = label_data,
    aes(label = symbol),
    size = 3,
    max.overlaps = Inf,
    show.legend = FALSE
  ) +
  scale_colour_manual(
    values = c(
      "Down" = "navy",
      "Up" = "firebrick3",
      "NS" = "gray",
      "Not tested" = "grey80"
    )
  ) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed") +
  labs(
    title = "Volcano Plot of Differential Expression",
    x = "Shrunken log2 fold change",
    y = "-log10 adjusted p-value"
  ) +
  theme_minimal()

ggsave(
  file.path(figures_dir, "volcano.png"),
  volcano_plot,
  width = 7,
  height = 6,
  dpi = 300
)

# MA plot -------------------------------------------------------------------

ma_plot <- ggplot(
  res_df,
  aes(x = baseMean, y = log2FoldChange, colour = significant)
) +
  geom_point(alpha = 0.3, size = 0.9) +
  scale_x_log10() +
  scale_colour_manual(values = c("NS" = "grey", "Significant" = "red")) +
  geom_hline(yintercept = 0) +
  geom_hline(yintercept = c(-1, 1), linetype = "dashed") +
  labs(
    title = "MA Plot of Differential Expression",
    x = "Mean normalized count",
    y = "Shrunken log2 fold change"
  ) +
  theme_minimal()

ggsave(
  file.path(figures_dir, "ma_plot.png"),
  ma_plot,
  width = 7,
  height = 6,
  dpi = 300
)

# Heatmaps ------------------------------------------------------------------

top_genes_20 <- res_df |>
  dplyr::filter(!is.na(padj)) |>
  dplyr::arrange(padj) |>
  dplyr::slice_head(n = 20) |>
  dplyr::pull(gene_id)

gene_symbols <- res_df$symbol[match(top_genes_20, res_df$gene_id)]
heatmap_data <- assay(vsd)[top_genes_20, ]
rownames(heatmap_data) <- gene_symbols

annotation_col <- data.frame(condition = meta$condition)
rownames(annotation_col) <- rownames(meta)

png(file.path(figures_dir, "heatmap_top_genes.png"), width = 1800, height = 1500, res = 250)
pheatmap(
  heatmap_data,
  scale = "row",
  color = colorRampPalette(c("navy", "white", "firebrick3"))(50),
  annotation_col = annotation_col,
  show_colnames = FALSE,
  fontsize_row = 8
)
dev.off()

sample_dists <- dist(t(assay(vsd)))

png(file.path(figures_dir, "sample_distance_heatmap.png"), width = 1800, height = 1500, res = 250)
pheatmap(
  as.matrix(sample_dists),
  annotation_col = annotation_col,
  color = colorRampPalette(c("navy", "white", "firebrick3"))(50),
  show_colnames = FALSE,
  show_rownames = FALSE
)
dev.off()

# GO Biological Process GSEA -----------------------------------------------

rank_input <- res_df |>
  dplyr::filter(is.finite(log2FoldChange))

gene_df <- AnnotationDbi::select(
  org.Hs.eg.db,
  keys = unique(rank_input$ensembl_id),
  keytype = "ENSEMBL",
  columns = "ENTREZID"
) |>
  dplyr::distinct(ENSEMBL, ENTREZID) |>
  dplyr::group_by(ENSEMBL) |>
  dplyr::mutate(n_entrez = dplyr::n_distinct(ENTREZID, na.rm = TRUE)) |>
  dplyr::ungroup() |>
  dplyr::left_join(
    rank_input[, c("ensembl_id", "log2FoldChange")],
    by = c("ENSEMBL" = "ensembl_id")
  ) |>
  dplyr::arrange(ENTREZID, dplyr::desc(abs(log2FoldChange)), ENSEMBL) |>
  dplyr::group_by(ENTREZID) |>
  dplyr::mutate(
    selected = !is.na(ENTREZID) &
      n_entrez == 1L &
      cumsum(n_entrez == 1L) == 1L
  ) |>
  dplyr::ungroup()

ranked <- gene_df |>
  dplyr::filter(selected) |>
  dplyr::arrange(dplyr::desc(log2FoldChange), ENTREZID)

gene_list <- setNames(ranked$log2FoldChange, ranked$ENTREZID)
stopifnot(!anyDuplicated(names(gene_list)), all(is.finite(gene_list)))

set.seed(42)
ego_gsea <- gseGO(
  geneList = gene_list,
  OrgDb = org.Hs.eg.db,
  keyType = "ENTREZID",
  ont = "BP",
  seed = TRUE,
  BPPARAM = BiocParallel::SerialParam(),
  verbose = FALSE
)

if (nrow(as.data.frame(ego_gsea)) > 0) {
  gsea_dotplot <- dotplot(ego_gsea, showCategory = 8)

  ggsave(
    file.path(figures_dir, "gsea_dotplot.png"),
    gsea_dotplot,
    width = 7,
    height = 6,
    dpi = 300
  )

  png(file.path(figures_dir, "gsea_enrichment.png"), width = 1800, height = 1500, res = 250)
  print(gseaplot2(ego_gsea, geneSetID = 1))
  dev.off()
}

# Export --------------------------------------------------------------------

write.csv(
  res_df,
  file.path(tables_dir, "all_DESeq2_results_with_symbols.csv"),
  row.names = FALSE
)

write.csv(
  sig,
  file.path(tables_dir, "all_significant_DEGs.csv"),
  row.names = FALSE
)

write.csv(
  sig |> dplyr::arrange(padj) |> dplyr::slice_head(n = 100),
  file.path(tables_dir, "top_100_DEGs.csv"),
  row.names = FALSE
)

write.csv(
  as.data.frame(ego_gsea),
  file.path(tables_dir, "gsea_results.csv"),
  row.names = FALSE
)

write.csv(
  meta,
  file.path(tables_dir, "analysis_metadata.csv"),
  row.names = FALSE
)

write.csv(
  gene_df,
  file.path(tables_dir, "gsea_mapping_audit.csv"),
  row.names = FALSE
)

write.csv(
  ranked,
  file.path(tables_dir, "gsea_ranked_genes.csv"),
  row.names = FALSE
)

writeLines(
  capture.output(sessionInfo()),
  file.path(tables_dir, "session_info.txt")
)

message(
  "Completed bulk RNA-seq analysis: ",
  nrow(sig),
  " significant genes (",
  sum(sig$log2FoldChange > 0),
  " higher, ",
  sum(sig$log2FoldChange < 0),
  " lower in the historical Infected group)."
)
