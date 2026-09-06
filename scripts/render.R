# Run from any working directory; never overwrite a previous run.
raw_args <- commandArgs(FALSE)
script <- sub("^--file=", "", raw_args[grepl("^--file=", raw_args)][1])
root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
args <- commandArgs(TRUE)
preflight <- "--preflight" %in% args
args <- args[args != "--preflight"]
source(file.path(root, "R/runtime.R"))
configure_project(root)
if (length(args)) stop("Usage: Rscript --vanilla scripts/render.R [--preflight]")
mode <- "bulk"
input <- "analysis/bulk_analysis.Rmd"
params <- NULL
repo_inputs <- c(input, paste0("R/", list.files(file.path(root, "R"), pattern = "\\.R$")),
  "scripts/render.R", "scripts/refresh_geo_metadata.py", "data/metadata/geo_samples.csv",
  "provenance/dataset.json", "provenance/geo_source.json", "provenance/package_versions.csv")
repo_inputs <- c(repo_inputs, "GSE152418_p20047_Study1_RawCounts.txt", "data/sample_metadata.csv", "provenance/GSE152418_series_matrix.txt.gz")
manifest_files <- file.path(root, repo_inputs)
manifest_paths <- repo_inputs
manifest_scope <- rep("repository", length(repo_inputs))
setwd(root)
versions <- check_project_environment(root)
if (any(!file.exists(manifest_files))) stop("Missing input: ", paste(manifest_files[!file.exists(manifest_files)], collapse = ", "))
if (preflight) {
  cat("PASS: render preflight for", mode, "; no analysis executed and no outputs changed.\n")
  quit(status = 0L)
}
run_dir <- file.path(root, "outputs", mode)
require_new_run(run_dir)
dir.create(file.path(run_dir, "report"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(run_dir, "intermediates"), recursive = TRUE, showWarnings = FALSE)
manifest <- data.frame(scope = manifest_scope, path = manifest_paths,
  sha256 = vapply(manifest_files, function(f) digest::digest(file = f, algo = "sha256"), character(1)))
write.csv(manifest, file.path(run_dir, "input_manifest.csv"), row.names = FALSE)
write.csv(versions, file.path(run_dir, "package_versions.csv"), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(run_dir, "session_before.txt"))
writeLines("running", file.path(run_dir, "run_status.txt"))
tryCatch({
  rmarkdown::render(input, output_format = "html_document",
    output_dir = file.path(run_dir, "report"), intermediates_dir = file.path(run_dir, "intermediates"),
    knit_root_dir = root, params = params, envir = new.env(parent = globalenv()), clean = TRUE)
}, error = function(e) {
  writeLines(c("failed", conditionMessage(e)), file.path(run_dir, "run_status.txt"))
  stop(e)
})
writeLines(capture.output(sessionInfo()), file.path(run_dir, "session_after.txt"))
writeLines("complete", file.path(run_dir, "run_status.txt"))
out_files <- list.files(run_dir, recursive = TRUE, full.names = TRUE)
out_files <- out_files[basename(out_files) != "output_manifest.csv"]
write.csv(data.frame(path = substring(out_files, nchar(root) + 2),
  sha256 = vapply(out_files, function(f) digest::digest(file = f, algo = "sha256"), character(1))),
  file.path(run_dir, "output_manifest.csv"), row.names = FALSE)
cat("Rendered", mode, "with input/output hashes.\n")
