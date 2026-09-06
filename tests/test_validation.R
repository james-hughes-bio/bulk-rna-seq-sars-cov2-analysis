source("R/validation.R")
expect_error <- function(expr) {
  stopifnot(inherits(tryCatch({force(expr); NULL}, error = identity), "error"))
}
x <- matrix(c(1,2,3,4,5,6,7,8), nrow = 2,
            dimnames = list(c("g1","g2"), c("a-1","b.1","c","d")))
m <- data.frame(sample = c("d","c","b_1","a_1"),
                condition = c("Infected","Infected","Control","Control"))
z <- validate_bulk_inputs(x, m)
stopifnot(identical(z$metadata$sample, c("a_1","b_1","c","d")))
expect_error(validate_bulk_inputs(x, m[-1, ]))
m2 <- m; m2$sample[2] <- m2$sample[1]; expect_error(validate_bulk_inputs(x, m2))
x2 <- x; colnames(x2)[2] <- "a.1"; expect_error(validate_bulk_inputs(x2, m))
x2 <- x; x2[1,1] <- 0.5; expect_error(validate_bulk_inputs(x2, m))
m2 <- m; m2$condition[1] <- NA; expect_error(validate_bulk_inputs(x, m2))
expr <- read.delim("GSE152418_p20047_Study1_RawCounts.txt", row.names=1, check.names=FALSE)
meta <- read.csv("data/metadata/geo_samples.csv", check.names=FALSE)
z <- validate_bulk_inputs(expr, meta)
stopifnot(sum(z$metadata[["disease state"]] == "Convalescent") == 1L)
all <- read.csv("reference/tables/all_DESeq2_results_with_symbols.csv")
sig <- read.csv("reference/tables/all_significant_DEGs.csv")
selected <- all[!is.na(all$padj) & all$padj < .05 & abs(all$log2FoldChange) > 1, ]
stopifnot(setequal(selected$gene_id, sig$gene_id),
          !anyDuplicated(all$gene_id), nrow(sig) == 3879L,
          sum(sig$log2FoldChange > 0) == 3688L, sum(sig$log2FoldChange < 0) == 191L)
top <- read.csv("reference/tables/top_100_DEGs.csv")
stopifnot(identical(top$gene_id, sig$gene_id[order(sig$padj)][seq_len(nrow(top))]))
cat("PASS: metadata alignment, collisions, invalid counts, historical DEG membership and ranking.\n")
