# Validation record

Maintenance date: 2026-09-06. Scope: engineering only; the existing data, model, thresholds, classifications and interpretations were preserved. The bulk Rmd only had trailing whitespace removed; its parsed R expressions are unchanged.

## Results and rendering status

- Original R input tests and historical DEG/ranking checks: PASS.
- Saved GEO snapshot and all 34 metadata rows: PASS, unchanged.
- All 14 reference-file hashes and all 83 original-file hashes: PASS.
- All 17 required namespaces load; recorded direct versions match. Pandoc 3.6.3 is available after local discovery.
- Updated render preflight and R Markdown integration render: PASS.
- The existing 2026-09-05 run in `outputs/bulk/` was preserved. Its five input hashes matched the incoming working tree before maintenance; all 22 output hashes matched. The incoming source snapshot is retained locally in `outputs/maintenance-20260906/baseline/`.
- Browser QA: report opens, all seven embedded figures load, no rendered error blocks, seven warning blocks. Title, text and figure overview inspected. This checks technical rendering, not numerical validity.

```sh
Rscript --vanilla scripts/render.R --preflight
python scripts/verify_run.py outputs/bulk --source-root outputs/maintenance-20260906/baseline
```

The existing full render was not repeated: its source/input lineage already verified and the request was to preserve prior work. The updated runner is covered by preflight, overwrite-guard and integration tests; a fresh full end-to-end analysis run using the updated runner is not claimed. Running the full command against the existing output directory refuses it without altering the prior run. For later runs, `python scripts/verify_run.py outputs/bulk` uses current sources by default; keep the relevant source checkout for older runs.

## Unresolved warnings

The preserved report contains two `nbinomGLM` line-search warnings; a volcano warning dropping 3,598 rows with missing/out-of-scale values; and fgsea warnings concerning 178 pathways with unbalanced statistics, possible overestimated p-values and values below the estimation floor. The report also contains its explicit exploratory-design warning. Changing the model, permutation settings, effect ranks or thresholds to address these is outside this maintenance task.

The top-gene and pathway display tables round very small p-values to zero with `digits = 3`; use the full-precision CSV values. This existing presentation limitation remains documented rather than silently modifying the preserved report. Scientific notation can be addressed in a separately reviewed presentation update.

PDF rendering was not attempted; the existing runner explicitly selects HTML. Shared-environment isolation, full transitive package locking and independent-checkout numerical reproduction remain unverified.

## Executed validation commands

From the repository root, using the installed R 4.5.2 executable for `Rscript`:

```sh
Rscript --vanilla scripts/validate.R
python scripts/validate_repository.py
python scripts/refresh_geo_metadata.py --check
python scripts/verify_originals.py
Rscript --vanilla scripts/check_environment.R
Rscript --vanilla tests/test_render.R
```

The R suite includes the original tests, R/Rmd parsing, chunk-label checks, and a regression test protecting prior run directories. The integration test generates a small HTML report with evaluated inline R and an embedded plot beneath ignored `outputs/validation/`. It does not execute the biological analysis. The Python suite checks manifests, offline metadata derivation, syntax, local documentation links, source paths and ignore rules. Commands were also tested with the caller outside the repository.
## Runtime and dependencies

`Rscript` must select R 4.5.2. Python scripts require Python 3.11 or newer because hashing uses `hashlib.file_digest`; no third-party Python dependencies are needed. If it is not on PATH, invoke the installed executable by its discovered path; no global PATH or package changes are required. Pandoc 3.6.3 was discovered in the standard RStudio installation. Runners check `RSTUDIO_PANDOC`, PATH, and that standard installation in order. Other installations can supply `RSTUDIO_PANDOC` for the child process.

The historical `provenance/package_versions.csv` is never rewritten by environment checks. Current direct dependency versions are printed; a completed future run records them under its output directory. Version drift is reported. This is a local overlay on shared libraries, not a fully isolated or transitively pinned environment. An independent-machine restoration has not been established.

If a dependency needs repair, install only the selected, verified package archive into this repository's `.r-library/`, using `install.packages(archive, repos = NULL, lib = file.path(repo_root, ".r-library"), type = "win.binary")` for a compatible Windows binary. Create that local directory first. Source archives require a suitable compiler and `type = "source"`. Do not run a broad package upgrade. Re-run `scripts/check_environment.R` in a fresh R process afterward. No installer was run during this maintenance.

`R_USER_CACHE_DIR` is set only in the R process to this repository's ignored `.cache/`; no shared cache is moved or modified. Runners load local packages before dependent namespaces. R startup emitted four warnings because the inherited `C.UTF-8` locale is unsupported on this Windows installation. Global locale settings were not changed.

## Provenance and Git checks

Offline GEO checks reproduce CSV serialization from the existing compressed snapshots, including blank fields for characteristics absent in individual samples. No metadata or input values were changed. The reference manifest must cover every reference file exactly; original and disposition manifests must agree. Historical CSV/data bytes are protected from Git line-ending conversion through `.gitattributes`. Source code and Markdown use LF. The pre-existing bulk count-file checkout uses explicit CRLF so a fresh checkout reproduces its recorded input hash; its Git blob and values are unchanged.

The original workspace manifest deliberately covers both original loose datasets and the out-of-scope document. It is historical lineage, not a dependency on the other Git checkout. `python scripts/verify_originals.py path/to/original-workspace` verifies the entire original inventory; its default is the checkout's parent directory. An independent checkout need not have that historical workspace to run its own analysis.

`outputs/`, `.r-library/`, `.cache/`, raw inputs, session objects and local environment files are ignored. Prior tracked bulk exports remain recoverable through Git history and their exact reference copies. Both main refs and all remote refs were left unchanged; no push or merge was performed.

## Checkout validation

A disposable export of the staged Git index reproduced every working source, metadata and reference file byte-for-byte (43 files in the bulk checkout, 59 in the single-cell checkout). The original R test suites and offline metadata checks also passed from that export, invoked from the workspace parent. This validates checkout portability of the tracked artifacts, not a fresh dependency installation or full analytical reproduction. The export remains under ignored `outputs/maintenance-20260906/`.
