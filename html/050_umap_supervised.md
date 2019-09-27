---
author: "Satoshi Kato"
title: "supervised UMAP with uwot"
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

train.label  <- mnist.sample[1:7000,  1]
train.matrix <- mnist.sample[1:7000, -1] %>% as.matrix

test.label  <- mnist.sample[-c(1:7000),  1]
test.matrix <- mnist.sample[-c(1:7000), -1] %>% as.matrix

train.matrix %>% str(0)
 int [1:7000, 1:784] 0 0 0 0 0 0 0 0 0 0 ...
 - attr(*, "dimnames")=List of 2
test.matrix %>% str(0)
 int [1:3000, 1:784] 0 0 0 0 0 0 0 0 0 0 ...
 - attr(*, "dimnames")=List of 2
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
01:32:04 Read 7000 rows and found 784 numeric columns
01:32:04 Using Annoy for neighbor search, n_neighbors = 15
01:32:04 Building Annoy index with metric = euclidean, n_trees = 50
0%   10   20   30   40   50   60   70   80   90   100%
[----|----|----|----|----|----|----|----|----|----|
**************************************************|
01:32:06 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c883204f16
01:32:06 Searching Annoy index using 4 threads, search_k = 1500
01:32:10 Annoy recall = 100%
01:32:10 Commencing smooth kNN distance calibration using 4 threads
01:32:11 Initializing from normalized Laplacian + noise
01:32:11 Commencing optimization for 500 epochs, with 141880 positive edges
01:32:26 Optimization finished
```


```r
ggp.umap <- res.umap %>% 
  plot.umap(
    label = as.factor(train.label),
    title = "UMAP (with TRUE labels)" )
Adding missing grouping variables: `label`
# ggp.umap$plot

ggsave(ggp.umap$plot, filename =  "./output/050_umap_with_label.png",
       height = 4, width = 4)
```

![](output/050_umap_with_label.png)

# Supervised Embedding

https://jlmelville.github.io/uwot/metric-learning.html


```r
res.sumap <- train.matrix %>% 
  uwot::umap(verbose = TRUE, y = train.label)
01:32:29 Read 7000 rows and found 784 numeric columns
01:32:29 Using Annoy for neighbor search, n_neighbors = 15
01:32:29 Building Annoy index with metric = euclidean, n_trees = 50
0%   10   20   30   40   50   60   70   80   90   100%
[----|----|----|----|----|----|----|----|----|----|
**************************************************|
01:32:32 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c88262d5712
01:32:32 Searching Annoy index using 4 threads, search_k = 1500
01:32:35 Annoy recall = 100%
01:32:35 Commencing smooth kNN distance calibration using 4 threads
01:32:36 Processing y data
01:32:36 Using Annoy for neighbor search, n_neighbors = 15
01:32:36 Building Annoy index with metric = euclidean, n_trees = 50
0%   10   20   30   40   50   60   70   80   90   100%
[----|----|----|----|----|----|----|----|----|----|
**************************************************|
01:32:37 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c88132e1fb8
01:32:37 Searching Annoy index using 4 threads, search_k = 1500
01:32:38 Annoy recall = 2.143%
01:32:38 Commencing smooth kNN distance calibration using 4 threads
01:32:38 7000 smooth knn distance failures
01:32:38 Intersecting X and Y sets with target weight = 0.5
01:32:39 Initializing from normalized Laplacian + noise
01:32:39 Commencing optimization for 500 epochs, with 141902 positive edges
01:33:01 Optimization finished

ggp.sumap <- res.sumap %>% 
  plot.umap(
    label = as.factor(train.label),
    title = "supervised UMAP (with TRUE labels)" )
Adding missing grouping variables: `label`
# 
ggsave(ggp.sumap$plot, filename =  "./output/050_umap_supervised_embed.png",
       height = 4, width = 4)
```

![](output/050_umap_supervised_embed.png)



# Metric Learning

https://jlmelville.github.io/uwot/metric-learning.html


```r
res.sumap.train <- train.matrix %>% 
  uwot::umap(verbose = TRUE, y = train.label, ret_model = TRUE)
01:33:04 Read 7000 rows and found 784 numeric columns
01:33:04 Using Annoy for neighbor search, n_neighbors = 15
01:33:04 Building Annoy index with metric = euclidean, n_trees = 50
0%   10   20   30   40   50   60   70   80   90   100%
[----|----|----|----|----|----|----|----|----|----|
**************************************************|
01:33:07 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c888b96d85
01:33:07 Searching Annoy index using 4 threads, search_k = 1500
01:33:11 Annoy recall = 100%
01:33:11 Commencing smooth kNN distance calibration using 4 threads
01:33:12 Processing y data
01:33:12 Using Annoy for neighbor search, n_neighbors = 15
01:33:12 Building Annoy index with metric = euclidean, n_trees = 50
0%   10   20   30   40   50   60   70   80   90   100%
[----|----|----|----|----|----|----|----|----|----|
**************************************************|
01:33:13 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c8852591144
01:33:13 Searching Annoy index using 4 threads, search_k = 1500
01:33:14 Annoy recall = 2.143%
01:33:14 Commencing smooth kNN distance calibration using 4 threads
01:33:14 7000 smooth knn distance failures
01:33:14 Intersecting X and Y sets with target weight = 0.5
01:33:14 Initializing from normalized Laplacian + noise
01:33:14 Commencing optimization for 500 epochs, with 141902 positive edges
01:33:37 Optimization finished
res.sumap.train %>% str(2)
List of 18
 $ embedding           : num [1:7000, 1:2] 3.59 4.16 -0.57 -7.5 5.03 ...
  ..- attr(*, "scaled:center")= num [1:2] 0.509 0.161
 $ scale_info          : NULL
 $ n_neighbors         : num 15
 $ search_k            : num 1500
 $ local_connectivity  : num 1
 $ n_epochs            : num 500
 $ alpha               : num 1
 $ negative_sample_rate: num 5
 $ method              : chr "umap"
 $ a                   : Named num 1.9
  ..- attr(*, "names")= chr "a"
 $ b                   : Named num 0.801
  ..- attr(*, "names")= chr "b"
 $ gamma               : num 1
 $ approx_pow          : logi FALSE
 $ metric              :List of 1
  ..$ euclidean: NULL
 $ norig_col           : int 784
 $ pcg_rand            : logi TRUE
 $ nn_index            :Reference class 'Rcpp_AnnoyEuclidean' [package "RcppAnnoy"] with 0 fields
 list()
  ..and 30 methods, of which 16 are  possibly relevant:
  ..  addItem, build, finalize, getDistance, getItemsVector, getNItems,
  ..  getNNsByItem, getNNsByItemList, getNNsByVector, getNNsByVectorList,
  ..  initialize, load, save, setSeed, setVerbose, unload
 $ pca_models          : list()

res.sumap.test <- umap_transform(test.matrix, model = res.sumap.train, verbose = TRUE)
01:33:37 Read 3000 rows and found 784 numeric columns
01:33:37 Processing block 1 of 1
01:33:37 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c884607367
01:33:37 Searching Annoy index using 4 threads, search_k = 1500
01:33:39 Commencing smooth kNN distance calibration using 4 threads
01:33:39 Initializing by weighted average of neighbor coordinates using 4 threads
01:33:39 Commencing optimization for 167 epochs, with 45000 positive edges
01:33:42 Finished
res.sumap.test %>% str(2)
 num [1:3000, 1:2] 2.606 -0.526 5.695 3.583 -2.49 ...
```



```r
  ggp.sumap <- res.sumap.test %>% 
  plot.umap(
    label = as.factor(test.label),
    title = "supervised UMAP (New Points)" )
Adding missing grouping variables: `label`
# 
ggsave(ggp.sumap$plot, filename =  "./output/050_umap_metric_learn_predict_test.png",
       height = 4, width = 4)
```


![](output/050_umap_metric_learn_predict_test.png)

