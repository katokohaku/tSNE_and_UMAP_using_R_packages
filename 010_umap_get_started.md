---
author: "Satoshi Kato"
title: "get started: UMAP with uwot"
date: "2019/09/17"
output:
  html_document:
    fig_caption: yes
    pandoc_args:
      - --from
      - markdown+autolink_bare_uris+tex_math_single_backslash-implicit_figures
    keep_md: yes
    toc: yes
  word_document:
    toc: yes
    toc_depth: 3
  pdf_document:
    toc: yes
    toc_depth: 3
editor_options: 
  chunk_output_type: inline
---




```r
install.packages("Rtsne", dependencies = TRUE)
install.packages("uwot", dependencies = TRUE)
install.packages("ggdendro", dependencies = TRUE)
install.packages("ggrepel", dependencies = TRUE)

```


```r
require(tidyverse)
require(magrittr)
require(xgboost)

require(Rtsne)
require(uwot)
library(ggdendro)
require(ggrepel)
```

# Preparation 

Optical Recognition of Handwritten Digits Data Set

https://archive.ics.uci.edu/ml/datasets/Optical+Recognition+of+Handwritten+Digits


```r
optdigits.tra  <- read.table("./input/optdigits.tra.csv", sep = ",", header = FALSE)

train.label  <- optdigits.tra[, 65]
train.matrix <- optdigits.tra[, -65] %>% as.matrix
```

## dimension reduction using UMAP

according to :
https://rdrr.io/cran/uwot/man/umap.html


# With no option


```r
plot.umap <- function(.umap, label = NULL, title = "") {
  
  mapping.umap <- data.frame(
    id     = 1:NROW(.umap),
    dim1  = .umap[, 1],
    dim2  = .umap[, 2])
  
  ggp.umap <- mapping.umap %>% 
    ggplot(aes(x = dim1, y = dim2, colour = label)) + 
    geom_point(alpha = 0.3) + 
    theme_bw() +
    guides(colour = FALSE) +
    labs(title = title)
  
  if(!is.null(label)){
    mapping.umap$label = label
    
    labels.cent <- mapping.umap %>% 
      dplyr::group_by(label) %>%
      select(dim1, dim2) %>% 
      summarize_all(mean)
    
    ggp.umap <- ggp.umap +
      ggrepel::geom_label_repel(data = labels.cent,
                                aes(label = label),
                                label.size = 0.1)
  }
  
  invisible(
    list(
      plot = ggp.umap,
      mapping = mapping.umap
    )
  )
}
```


```r
optdigits.umap <- train.matrix %>% 
  uwot::umap()

ggp.umap <- optdigits.umap %>% 
  plot.umap(
    label = as.factor(train.label),
    title = "non-supervised UMAP (with TRUE labels)" )
Adding missing grouping variables: `label`
# 
ggsave(ggp.umap$plot, filename =  "./output/010_umap_unsupervised_with_label.png",
       height = 4, width = 4)
```

![](output/010_umap_unsupervised_with_label.png)

### supervised dimension reduction


```r
optdigits.sumap <- train.matrix %>% 
  uwot::umap(y = train.label)

ggp.sumap <- optdigits.sumap %>% 
  plot.umap(
    label = as.factor(train.label),
    title = "supervised UMAP (with TRUE labels)" )
Adding missing grouping variables: `label`
# 
ggsave(ggp.sumap$plot, filename =  "./output/010_umap_supervised_with_label.png",
       height = 4, width = 4)
```

![](output/010_umap_supervised_with_label.png)
