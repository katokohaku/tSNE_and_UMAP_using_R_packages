---
author: "Satoshi Kato"
title: "get started: UMAP with uwot"
date: "2019/09/27"
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
install.packages("dbscan", dependencies = TRUE)

```


```r
require(tidyverse)
require(magrittr)
require(dbscan)

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
#>   int [1:10000, 1:784] 0 0 0 0 0 0 0 0 0 0 ...
#>   - attr(*, "dimnames")=List of 2
```

# dimension reduction using UMAP

according to :
https://rdrr.io/cran/uwot/man/umap.html


## With no tune


```r
plot.umap <- function(.umap, label = NULL, title = "") {
  
  mapping.umap <- data.frame(
    id     = 1:NROW(.umap),
    dim1  = .umap[, 1],
    dim2  = .umap[, 2])
  
  ggp.umap <- mapping.umap %>% 
    ggplot(aes(x = dim1, y = dim2, colour = label)) + 
    geom_point(alpha = 0.5, size = 0.2) + 
    theme_bw() +
    guides(colour = FALSE) +
    labs(title = title)
  
  if(!is.null(label)){
    mapping.umap$label = as.factor(label)
    
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
res.umap <- train.matrix %>% 
  uwot::umap(verbose = TRUE)
#>  01:13:44 Read 10000 rows and found 784 numeric columns
#>  01:13:44 Using Annoy for neighbor search, n_neighbors = 15
#>  01:13:45 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:13:49 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c88137574dc
#>  01:13:49 Searching Annoy index using 4 threads, search_k = 1500
#>  01:13:53 Annoy recall = 100%
#>  01:13:53 Commencing smooth kNN distance calibration using 4 threads
#>  01:13:54 Initializing from normalized Laplacian + noise
#>  01:13:54 Commencing optimization for 500 epochs, with 203566 positive edges
#>  01:14:16 Optimization finished
```


```r
res.umap <- train.matrix %>% 
  uwot::umap(verbose = TRUE, n_threads = 1)
#>  01:14:16 Read 10000 rows and found 784 numeric columns
#>  01:14:16 Using Annoy for neighbor search, n_neighbors = 15
#>  01:14:16 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:14:20 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c8830e01abb
#>  01:14:20 Searching Annoy index using 1 thread, search_k = 1500
#>  01:14:33 Annoy recall = 100%
#>  01:14:34 Commencing smooth kNN distance calibration using 1 thread
#>  01:14:34 Initializing from normalized Laplacian + noise
#>  01:14:34 Commencing optimization for 500 epochs, with 203566 positive edges
#>  01:14:57 Optimization finished
```


```r
ggp.umap <- res.umap %>% 
  plot.umap(
    label = as.factor(train.label),
    title = "UMAP (with TRUE labels)" )
#>  Adding missing grouping variables: `label`
# ggp.umap$plot

ggsave(ggp.umap$plot, filename =  "./output/030_umap_unsupervised_with_label.png",
       height = 4, width = 4)
```

![](output/030_umap_unsupervised_with_label.png)



```r
res.umap.pca <- train.matrix %>% 
  uwot::umap(verbose = TRUE, pca = 50)
#>  01:14:58 Read 10000 rows and found 784 numeric columns
#>  01:14:58 Reducing X column dimension to 50 via PCA
#>  01:15:01 PCA: 50 components explained 82.62% variance
#>  01:15:01 Using Annoy for neighbor search, n_neighbors = 15
#>  01:15:01 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:15:02 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c8829a74276
#>  01:15:02 Searching Annoy index using 4 threads, search_k = 1500
#>  01:15:03 Annoy recall = 100%
#>  01:15:03 Commencing smooth kNN distance calibration using 4 threads
#>  01:15:04 Initializing from normalized Laplacian + noise
#>  01:15:04 Commencing optimization for 500 epochs, with 196328 positive edges
#>  01:15:25 Optimization finished
```


```r
ggp.umap.pca <- res.umap.pca %>% 
  plot.umap(
    label = as.factor(train.label),
    title = "PCA + UMAP (with TRUE labels)" )
#>  Adding missing grouping variables: `label`
# ggp.umap$plot

ggsave(ggp.umap.pca$plot, filename =  "./output/030_umap_unsupervised_with_pca.png",
       height = 4, width = 4)
```

![](output/030_umap_unsupervised_with_pca.png)



```r
res.umap.cosine <- train.matrix %>% 
  uwot::umap(verbose = TRUE, metric = "cosine")
#>  01:15:27 Read 10000 rows and found 784 numeric columns
#>  01:15:27 Using Annoy for neighbor search, n_neighbors = 15
#>  01:15:27 Building Annoy index with metric = cosine, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:15:31 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c88538455a2
#>  01:15:31 Searching Annoy index using 4 threads, search_k = 1500
#>  01:15:36 Annoy recall = 100%
#>  01:15:36 Commencing smooth kNN distance calibration using 4 threads
#>  01:15:37 Initializing from normalized Laplacian + noise
#>  01:15:37 Commencing optimization for 500 epochs, with 212782 positive edges
#>  01:16:01 Optimization finished
```


```r
ggp.umap.cosine <- res.umap.cosine %>% 
  plot.umap(
    label = as.factor(train.label),
    title = "UMAP with cosine distance (with TRUE labels)" )
#>  Adding missing grouping variables: `label`
# ggp.umap$plot

ggsave(ggp.umap.cosine$plot, filename =  "./output/030_umap_unsupervised_with_cosine.png",
       height = 4, width = 4)
```

![](output/030_umap_unsupervised_with_cosine.png)

# Hierarchical clustering


```r
mapping.umap.hc <- ggp.umap$mapping %>% 
  select(-id) %>% 
  as.matrix() %>% 
  dist() %>% 
  hclust()
mapping.umap.hc
#>  
#>  Call:
#>  hclust(d = .)
#>  
#>  Cluster method   : complete 
#>  Distance         : euclidean 
#>  Number of objects: 10000
```

## explore cut.off for cutree


```r
library(ggdendro)

cut.off = 7

ggdend.umap.hc <- ggdendrogram(mapping.umap.hc, rotate = TRUE, size = 2) +
  geom_hline(yintercept = cut.off, color = "red")

ggsave(ggdend.umap.hc, filename =  "./output/030_umap_hclust.png",
       height = 4, width = 4)
```

![](./output/030_umap_hclust.png)


```r
require(ggrepel)

group.by.hclust <- mapping.umap.hc %>%
  cutree(h = cut.off)

ggp.umap.hc <- res.umap %>% 
  plot.umap(
    label = as.factor(LETTERS[group.by.hclust]),
    title = "umap (group by hclast)")
#>  Adding missing grouping variables: `label`

# ggp.umap.hc$plot
ggsave(ggp.umap.hc$plot, 
       filename =  "./output/030_umap_clustering_by_hclust.png",
       height = 4, width = 4)
```

![](./output/030_umap_clustering_by_hclust.png)

## Hierarchical Density-based spatial clustering of applications with noise (HDBSCAN)

Reference:

https://hdbscan.readthedocs.io/en/latest/how_hdbscan_works.html

according to:

https://cran.r-project.org/web/packages/dbscan/vignettes/hdbscan.html


```r
# install.packages("dbscan", dependencies = TRUE)
require(dbscan)
```

`minPts` not only acts as a minimum cluster size to detect, but also as a "smoothing" factor of the density estimates implicitly computed from HDBSCAN.


```r
# res.umap %>% str
cl.hdbscan <- ggp.umap$mapping %>% 
  select(dim1, dim2) %>% 
  dbscan::hdbscan(minPts = 22)
cl.hdbscan
#>  HDBSCAN clustering for 10000 objects.
#>  Parameters: minPts = 22
#>  The clustering contains 7 cluster(s) and 29 noise points.
#>  
#>     0    1    2    3    4    5    6    7 
#>    29 1235  913 1022 1008 2861 1081 1851 
#>  
#>  Available fields: cluster, minPts, cluster_scores,
#>                    membership_prob, outlier_scores, hc

plot(cl.hdbscan, show_flat = TRUE)
```

![](C:/R/dimensionality_reduction_with_tSNE_UMAP_using_R/tSNE_and_UMAP_using_R_packages/html/030_umap_get_started_files/figure-html/unnamed-chunk-14-1.png)<!-- -->


```r
# install.packages("ggrepel", dependencies = TRUE)
require(ggrepel)

ggp.umap$mapping$hdbscan <- factor(cl.hdbscan$cluster)

hdbscan.cent <- ggp.umap$mapping %>% 
  filter(hdbscan != 0) %>% 
  dplyr::group_by(hdbscan) %>%
  select(dim1, dim2) %>% 
  summarize_all(mean)
#>  Adding missing grouping variables: `hdbscan`

ggp.umap.hdbscan <- ggp.umap$mapping %>% 
  ggplot(aes(x = dim1, y = dim2, colour = hdbscan)) + 
  geom_point(alpha = 0.5, size = 0.2) + 
  theme_bw() +
  ggrepel::geom_label_repel(data = hdbscan.cent, 
                            aes(label = LETTERS[hdbscan]),
                            label.size = 0.1) + 
  guides(colour = FALSE) + 
  labs(title = "UMAP + HDBSCAN") 

ggp.umap.hdbscan
```

![](C:/R/dimensionality_reduction_with_tSNE_UMAP_using_R/tSNE_and_UMAP_using_R_packages/html/030_umap_get_started_files/figure-html/unnamed-chunk-15-1.png)<!-- -->

```r
ggsave(ggp.umap.hdbscan, 
       filename =  "./output/030_umap_clustering_by_hdbscan.png",
       height = 4, width = 4)
```

![](output/030_umap_clustering_by_hdbscan.png)

