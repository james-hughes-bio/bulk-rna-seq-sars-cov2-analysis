# Input validation shared within this repository; no package installation or data writes.
normalise_sample_ids <- function(x) gsub("[-.]", "_", trimws(x))

validate_bulk_inputs <- function(expr, meta) {
  expr <- as.matrix(expr)
  if (!is.numeric(expr) || any(!is.finite(expr)) || any(expr < 0) ||
      any(expr != floor(expr))) stop("Counts must be finite nonnegative integers.")
  ids <- normalise_sample_ids(colnames(expr))
  if (is.null(rownames(expr)) || anyNA(rownames(expr)) ||
      any(!nzchar(rownames(expr))) || anyDuplicated(rownames(expr)))
    stop("Gene IDs must be present and unique.")
  if (is.null(ids) || anyNA(ids) || any(!nzchar(ids)) || anyDuplicated(ids))
    stop("Sample IDs are missing or collide after normalization.")
  if (!all(c("sample", "condition") %in% names(meta)))
    stop("Metadata require sample and condition columns.")
  meta$sample <- normalise_sample_ids(meta$sample)
  if (anyNA(meta$sample) || any(!nzchar(meta$sample)) || anyDuplicated(meta$sample) ||
      !setequal(ids, meta$sample)) stop("Metadata and count samples must match exactly.")
  meta <- meta[match(ids, meta$sample), , drop = FALSE]
  if (anyNA(meta$condition) || any(!meta$condition %in% c("Control", "Infected")))
    stop("Unknown condition in metadata.")
  meta$condition <- factor(meta$condition, levels = c("Control", "Infected"))
  if (any(table(meta$condition) < 2L)) stop("At least two libraries per condition required.")
  if (any(colSums(expr) == 0)) stop("Empty count library.")
  rownames(meta) <- ids
  colnames(expr) <- ids
  list(counts = expr, metadata = meta)
}
