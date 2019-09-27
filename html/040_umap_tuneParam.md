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
plot.umap <- function(.umap, label = NULL, .colour = label, title = "") {
  
  mapping.umap <- data.frame(
    id     = 1:NROW(.umap),
    dim1  = .umap[, 1],
    dim2  = .umap[, 2])
  
  ggp.umap <- mapping.umap %>% 
    ggplot(aes(x = dim1, y = dim2, colour = .colour)) + 
    geom_point(alpha = 0.3, size = 0.2) + 
    theme_bw() +
    guides(colour = FALSE) +
    labs(title = title)
  
  if(!is.null(label)){
    mapping.umap$label = as.factor(train.label)
    
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
pars <- expand.grid(min_dist = c(0.0125, 0.05, 0.2, 0.8),
                    n_neighbors = c(5, 20, 80, 320))
i = 1
res <- list(NULL)
for(i in 1:NROW(pars)) {
  title.txt <- sprintf("%s : %s",
                       as.character(pars$min_dist[i]), 
                       as.character(pars$n_neighbors[i]))
  cat(i, ": ", title.txt, "\n")
  res.umap <- train.matrix %>% 
    uwot::umap(verbose = TRUE, 
               n_threads = 7,
               min_dist = pars$min_dist[i],
               n_neighbors = pars$n_neighbors[i])

  ggp.umap <- res.umap %>% 
    plot.umap(title = title.txt, .colour = as.factor(train.label))
  
  res[[i]] <- ggp.umap$plot
}
#>  1 :  0.0125 : 5
#>  01:17:51 Read 10000 rows and found 784 numeric columns
#>  01:17:51 Using Annoy for neighbor search, n_neighbors = 5
#>  01:17:51 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:17:55 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c8866976fb5
#>  01:17:55 Searching Annoy index using 7 threads, search_k = 500
#>  01:17:58 Annoy recall = 100%
#>  01:17:58 Commencing smooth kNN distance calibration using 7 threads
#>  01:17:59 Initializing from normalized Laplacian + noise
#>  01:17:59 Commencing optimization for 500 epochs, with 60642 positive edges
#>  01:18:11 Optimization finished
#>  2 :  0.05 : 5
#>  01:18:11 Read 10000 rows and found 784 numeric columns
#>  01:18:11 Using Annoy for neighbor search, n_neighbors = 5
#>  01:18:11 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:18:15 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c88783c3403
#>  01:18:15 Searching Annoy index using 7 threads, search_k = 500
#>  01:18:18 Annoy recall = 100%
#>  01:18:18 Commencing smooth kNN distance calibration using 7 threads
#>  01:18:19 Initializing from normalized Laplacian + noise
#>  01:18:19 Commencing optimization for 500 epochs, with 60642 positive edges
#>  01:18:36 Optimization finished
#>  3 :  0.2 : 5
#>  01:18:36 Read 10000 rows and found 784 numeric columns
#>  01:18:36 Using Annoy for neighbor search, n_neighbors = 5
#>  01:18:36 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:18:42 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c882d671e09
#>  01:18:43 Searching Annoy index using 7 threads, search_k = 500
#>  01:18:48 Annoy recall = 100%
#>  01:18:49 Commencing smooth kNN distance calibration using 7 threads
#>  01:18:49 Initializing from normalized Laplacian + noise
#>  01:18:50 Commencing optimization for 500 epochs, with 60642 positive edges
#>  01:19:10 Optimization finished
#>  4 :  0.8 : 5
#>  01:19:10 Read 10000 rows and found 784 numeric columns
#>  01:19:10 Using Annoy for neighbor search, n_neighbors = 5
#>  01:19:10 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:19:16 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c8819c1346a
#>  01:19:16 Searching Annoy index using 7 threads, search_k = 500
#>  01:19:19 Annoy recall = 100%
#>  01:19:19 Commencing smooth kNN distance calibration using 7 threads
#>  01:19:20 Initializing from normalized Laplacian + noise
#>  01:19:20 Commencing optimization for 500 epochs, with 60642 positive edges
#>  01:19:31 Optimization finished
#>  5 :  0.0125 : 20
#>  01:19:32 Read 10000 rows and found 784 numeric columns
#>  01:19:32 Using Annoy for neighbor search, n_neighbors = 20
#>  01:19:32 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:19:35 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c884def6d8a
#>  01:19:35 Searching Annoy index using 7 threads, search_k = 2000
#>  01:19:40 Annoy recall = 100%
#>  01:19:40 Commencing smooth kNN distance calibration using 7 threads
#>  01:19:41 Initializing from normalized Laplacian + noise
#>  01:19:41 Commencing optimization for 500 epochs, with 274406 positive edges
#>  01:20:06 Optimization finished
#>  6 :  0.05 : 20
#>  01:20:06 Read 10000 rows and found 784 numeric columns
#>  01:20:06 Using Annoy for neighbor search, n_neighbors = 20
#>  01:20:06 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:20:09 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c885d0d23f0
#>  01:20:09 Searching Annoy index using 7 threads, search_k = 2000
#>  01:20:14 Annoy recall = 100%
#>  01:20:14 Commencing smooth kNN distance calibration using 7 threads
#>  01:20:15 Initializing from normalized Laplacian + noise
#>  01:20:15 Commencing optimization for 500 epochs, with 274406 positive edges
#>  01:20:40 Optimization finished
#>  7 :  0.2 : 20
#>  01:20:40 Read 10000 rows and found 784 numeric columns
#>  01:20:40 Using Annoy for neighbor search, n_neighbors = 20
#>  01:20:40 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:20:43 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c887b0c5e48
#>  01:20:43 Searching Annoy index using 7 threads, search_k = 2000
#>  01:20:48 Annoy recall = 100%
#>  01:20:48 Commencing smooth kNN distance calibration using 7 threads
#>  01:20:49 Initializing from normalized Laplacian + noise
#>  01:20:49 Commencing optimization for 500 epochs, with 274406 positive edges
#>  01:21:14 Optimization finished
#>  8 :  0.8 : 20
#>  01:21:14 Read 10000 rows and found 784 numeric columns
#>  01:21:14 Using Annoy for neighbor search, n_neighbors = 20
#>  01:21:14 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:21:17 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c8862f710d3
#>  01:21:18 Searching Annoy index using 7 threads, search_k = 2000
#>  01:21:23 Annoy recall = 100%
#>  01:21:23 Commencing smooth kNN distance calibration using 7 threads
#>  01:21:24 Initializing from normalized Laplacian + noise
#>  01:21:24 Commencing optimization for 500 epochs, with 274406 positive edges
#>  01:21:49 Optimization finished
#>  9 :  0.0125 : 80
#>  01:21:49 Read 10000 rows and found 784 numeric columns
#>  01:21:49 Using Annoy for neighbor search, n_neighbors = 80
#>  01:21:49 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:21:53 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c886c6c6b0f
#>  01:21:53 Searching Annoy index using 7 threads, search_k = 8000
#>  01:22:01 Annoy recall = 100%
#>  01:22:01 Commencing smooth kNN distance calibration using 7 threads
#>  01:22:02 Initializing from normalized Laplacian + noise
#>  01:22:03 Commencing optimization for 500 epochs, with 1111196 positive edges
#>  01:22:44 Optimization finished
#>  10 :  0.05 : 80
#>  01:22:44 Read 10000 rows and found 784 numeric columns
#>  01:22:44 Using Annoy for neighbor search, n_neighbors = 80
#>  01:22:44 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:22:47 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c8831cc1bd5
#>  01:22:48 Searching Annoy index using 7 threads, search_k = 8000
#>  01:22:56 Annoy recall = 100%
#>  01:22:56 Commencing smooth kNN distance calibration using 7 threads
#>  01:22:57 Initializing from normalized Laplacian + noise
#>  01:22:58 Commencing optimization for 500 epochs, with 1111196 positive edges
#>  01:23:40 Optimization finished
#>  11 :  0.2 : 80
#>  01:23:40 Read 10000 rows and found 784 numeric columns
#>  01:23:40 Using Annoy for neighbor search, n_neighbors = 80
#>  01:23:40 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:23:43 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c8874e8746
#>  01:23:44 Searching Annoy index using 7 threads, search_k = 8000
#>  01:23:52 Annoy recall = 100%
#>  01:23:52 Commencing smooth kNN distance calibration using 7 threads
#>  01:23:53 Initializing from normalized Laplacian + noise
#>  01:23:54 Commencing optimization for 500 epochs, with 1111196 positive edges
#>  01:24:35 Optimization finished
#>  12 :  0.8 : 80
#>  01:24:35 Read 10000 rows and found 784 numeric columns
#>  01:24:35 Using Annoy for neighbor search, n_neighbors = 80
#>  01:24:35 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:24:39 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c881e4353c
#>  01:24:39 Searching Annoy index using 7 threads, search_k = 8000
#>  01:24:47 Annoy recall = 100%
#>  01:24:47 Commencing smooth kNN distance calibration using 7 threads
#>  01:24:48 Initializing from normalized Laplacian + noise
#>  01:24:49 Commencing optimization for 500 epochs, with 1111196 positive edges
#>  01:25:30 Optimization finished
#>  13 :  0.0125 : 320
#>  01:25:30 Read 10000 rows and found 784 numeric columns
#>  01:25:30 Using Annoy for neighbor search, n_neighbors = 320
#>  01:25:30 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:25:34 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c8853143417
#>  01:25:34 Searching Annoy index using 7 threads, search_k = 32000
#>  01:25:50 Annoy recall = 100%
#>  01:25:50 Commencing smooth kNN distance calibration using 7 threads
#>  01:25:54 Initializing from normalized Laplacian + noise
#>  01:25:57 Commencing optimization for 500 epochs, with 4129726 positive edges
#>  01:27:05 Optimization finished
#>  14 :  0.05 : 320
#>  01:27:05 Read 10000 rows and found 784 numeric columns
#>  01:27:05 Using Annoy for neighbor search, n_neighbors = 320
#>  01:27:05 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:27:09 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c8840b2b1e
#>  01:27:09 Searching Annoy index using 7 threads, search_k = 32000
#>  01:27:23 Annoy recall = 100%
#>  01:27:23 Commencing smooth kNN distance calibration using 7 threads
#>  01:27:27 Initializing from normalized Laplacian + noise
#>  01:27:30 Commencing optimization for 500 epochs, with 4129726 positive edges
#>  01:28:35 Optimization finished
#>  15 :  0.2 : 320
#>  01:28:35 Read 10000 rows and found 784 numeric columns
#>  01:28:35 Using Annoy for neighbor search, n_neighbors = 320
#>  01:28:35 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:28:39 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c88701470d1
#>  01:28:39 Searching Annoy index using 7 threads, search_k = 32000
#>  01:28:53 Annoy recall = 100%
#>  01:28:54 Commencing smooth kNN distance calibration using 7 threads
#>  01:28:58 Initializing from normalized Laplacian + noise
#>  01:29:00 Commencing optimization for 500 epochs, with 4129726 positive edges
#>  01:30:06 Optimization finished
#>  16 :  0.8 : 320
#>  01:30:06 Read 10000 rows and found 784 numeric columns
#>  01:30:06 Using Annoy for neighbor search, n_neighbors = 320
#>  01:30:06 Building Annoy index with metric = euclidean, n_trees = 50
#>  0%   10   20   30   40   50   60   70   80   90   100%
#>  [----|----|----|----|----|----|----|----|----|----|
#>  **************************************************|
#>  01:30:10 Writing NN index file to temp file C:\Users\kato\AppData\Local\Temp\RtmpC6GiEi\file2c884a817cdb
#>  01:30:10 Searching Annoy index using 7 threads, search_k = 32000
#>  01:30:25 Annoy recall = 100%
#>  01:30:25 Commencing smooth kNN distance calibration using 7 threads
#>  01:30:29 Initializing from normalized Laplacian + noise
#>  01:30:32 Commencing optimization for 500 epochs, with 4129726 positive edges
#>  01:31:38 Optimization finished
res[[1]]
```

![](C:/R/dimensionality_reduction_with_tSNE_UMAP_using_R/tSNE_and_UMAP_using_R_packages/html/040_umap_tuneParam_files/figure-html/unnamed-chunk-3-1.png)<!-- -->

```r
ggp.umap.compare <- gridExtra::arrangeGrob(
  grobs = res,
  ncol = 4
)
ggp.umap.compare
#>  TableGrob (4 x 4) "arrange": 16 grobs
#>      z     cells    name           grob
#>  1   1 (1-1,1-1) arrange gtable[layout]
#>  2   2 (1-1,2-2) arrange gtable[layout]
#>  3   3 (1-1,3-3) arrange gtable[layout]
#>  4   4 (1-1,4-4) arrange gtable[layout]
#>  5   5 (2-2,1-1) arrange gtable[layout]
#>  6   6 (2-2,2-2) arrange gtable[layout]
#>  7   7 (2-2,3-3) arrange gtable[layout]
#>  8   8 (2-2,4-4) arrange gtable[layout]
#>  9   9 (3-3,1-1) arrange gtable[layout]
#>  10 10 (3-3,2-2) arrange gtable[layout]
#>  11 11 (3-3,3-3) arrange gtable[layout]
#>  12 12 (3-3,4-4) arrange gtable[layout]
#>  13 13 (4-4,1-1) arrange gtable[layout]
#>  14 14 (4-4,2-2) arrange gtable[layout]
#>  15 15 (4-4,3-3) arrange gtable[layout]
#>  16 16 (4-4,4-4) arrange gtable[layout]
res %>% str(1)
#>  List of 16
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
#>   $ :List of 10
#>    ..- attr(*, "class")= chr [1:2] "gg" "ggplot"
ggsave(ggp.umap.compare, 
       filename =  "./output/040_umap_min_dist_vs_n_neighbors.png",
       height = 16, width = 16)

```

![](output/040_umap_min_dist_vs_n_neighbors.png)


