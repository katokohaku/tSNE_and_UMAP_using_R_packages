require(rmarkdown)
getwd()

files_to_report <- c(
  "001_tSNE_get_started.Rmd",
  "010_tSNE_iterations.Rmd",
  "030_umap_get_started.Rmd",
  "040_umap_tuneParam.Rmd",
  "050_umap_supervised.Rmd",
  "020_tSNE_search_perplexity.Rmd"
)


for( fn in files_to_report) {
  cat("rending: ", fn)
  render(input =fn, output_dir = "./html/",
         output_format = "html_document")
  cat("\t\tDone.\n")
}




