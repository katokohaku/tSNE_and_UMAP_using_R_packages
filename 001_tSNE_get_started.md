---
author: "Satoshi Kato"
title: "get started: tSNE with Rtsne"
date: "2019/09/20"
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

require(Rtsne)
require(uwot)
library(ggdendro)
require(ggrepel)
```

# Preparation 


Using MNIST (test set) as csv fromat was downloaded from :

https://github.com/pjreddie/mnist-csv-png


```r
set.seed(1)

require(tidyverse)
require(Rtsne)
load("./input/mnist_sample.rda")

train.label  <- mnist.sample[,  1]
train.matrix <- mnist.sample[, -1] %>% as.matrix

n <- NROW(train.matrix)
train.matrix %>% str(0)
 int [1:10000, 1:784] 0 0 0 0 0 0 0 0 0 0 ...
 - attr(*, "dimnames")=List of 2
```

# dimension reduction using t-SNE

according to :
http://jmonlong.github.io/Hippocamplus/2017/12/02/tsne-and-clustering/


```r
zeros.col <- which(colSums(train.matrix) == 0)
map.pca <- prcomp(x = train.matrix[, -zeros.col], scale = TRUE)
ggp.pca <- data.frame(
  dim1  = map.pca$x[, 1],
  dim2  = map.pca$x[, 2],
  label = as.factor(train.label)) %>% 
  ggplot(aes(x = dim1, y = dim2, colour = label)) + 
  geom_point(alpha = 0.3) + 
  theme_bw() +
  guides(colour = FALSE) +
  labs(title = "PCA")

ggsave(ggp.pca, filename =  "./output/000_PCA.png",
       height = 4, width = 4)
```

![](output/000_PCA.png)



```r
plot.tsne <- function(.tsne, label = NULL, title = "") {
  
  mapping <- data.frame(
    id    = 1:NROW(.tsne$Y),
    dim1  = .tsne$Y[, 1],
    dim2  = .tsne$Y[, 2])
  
  ggp <- mapping %>% 
    ggplot(aes(x = dim1, y = dim2, colour = label)) + 
    geom_point(alpha = 0.3) + 
    theme_bw() +
    guides(colour = FALSE) +
    labs(title = title)
  
  if(!is.null(label)){
    mapping$label = label
    
    labels.cent <- mapping %>% 
      dplyr::group_by(label) %>%
      select(dim1, dim2) %>% 
      summarize_all(mean)
    
    ggp <- ggp +
      ggrepel::geom_label_repel(data = labels.cent,
                                aes(label = label),
                                label.size = 0.1)
  }
  
  invisible(
    list(
      plot = ggp,
      mapping = mapping
    )
  )
}
```


```r

mapping.tsne <- train.matrix %>% 
  Rtsne::Rtsne()

ggp.tsne <- mapping.tsne %>% 
  plot.tsne(
    label = as.factor(train.label),
    title = "tSNE (with TRUE labels)")
Adding missing grouping variables: `label`

ggsave(ggp.tsne$plot, filename =  "./output/000_tSNE.png",
       height = 4, width = 4)
```

![](output/000_tSNE.png)


```r
ggp.tsne.nolabel <- mapping.tsne %>% 
  plot.tsne(
    # label = as.factor(train.label),
    title = "tSNE (without labels)")
# mapping.tsne %>% str
# ggp.tsne.nolabel$plot

ggsave(ggp.tsne.nolabel$plot, filename =  "./output/000_tSNE_nolabel.png",
       height = 4, width = 4)
```

![](output/000_tSNE_nolabel.png)

# Hierarchical clustering


```r
mapping.tsne.hc <- ggp.tsne.nolabel$mapping %>% 
  select(-id) %>% 
  as.matrix() %>% 
  dist() %>% 
  hclust()
mapping.tsne.hc

Call:
hclust(d = .)

Cluster method   : complete 
Distance         : euclidean 
Number of objects: 10000 
```

## explore cut.off for cutree


```r
library(ggdendro)

cut.off = 27

ggdend.tsne.hc <- ggdendrogram(mapping.tsne.hc, rotate = TRUE, size = 2) +
  geom_hline(yintercept = cut.off, color = "red")

ggsave(ggdend.tsne.hc, filename =  "./output/000_tsne_hclust.png",
       height = 4, width = 4)
```

![](./output/000_tsne_hclust.png)


```r
require(ggrepel)

group.by.hclust <- mapping.tsne.hc %>%
  cutree(h = cut.off) %>%
  factor()

ggp.tsne.hc <- mapping.tsne %>% 
  plot.tsne(
    label = as.factor(LETTERS[group.by.hclust]),
    title = "tSNE (group by hclast)")
Adding missing grouping variables: `label`

# ggp.tsne.hc$plot
```


```r
ggp.tsne.compare <- gridExtra::arrangeGrob(
  grobs = list(
    ggp.tsne$plot, ggp.tsne.hc$plot
  ),
  ncol = 2
)

ggsave(ggp.tsne.compare, filename =  "./output/000_tSNE_compare.png",
       height = 4, width = 8)
```

![](output/000_tSNE_compare.png)
