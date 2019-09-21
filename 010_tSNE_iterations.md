---
author: "Satoshi Kato"
title: "Effect of t-SNE iteration"
date: "2019/09/21"
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



# reference

How to Use t-SNE Effectively

https://distill.pub/2016/misread-tsne/

Using MNIST (test set) as csv fromat was downloaded from :

https://github.com/pjreddie/mnist-csv-png


```r
set.seed(1)
load("./input/mnist_sample.rda")

train.label  <- mnist.sample[,  1]
train.matrix <- mnist.sample[, -1] %>% as.matrix

n <- NROW(train.matrix)
train.matrix %>% str(0)
#>   int [1:10000, 1:784] 0 0 0 0 0 0 0 0 0 0 ...
#>   - attr(*, "dimnames")=List of 2
```


```r
res <- list(NULL)

n.iter <- c(10, 50, 100, 150, 100*2:7, 1000, 1500, 2000, 4000)
add.iter <- n.iter - c(0, n.iter)[1:length(n.iter)]

res.tsne <- Rtsne::Rtsne(train.matrix, 
                  verbose = TRUE, 
                  num_threads = 5,
                  # theta=0.0, 
                  pca=FALSE, 
                  perplexity = 30, 
                  max_iter = n.iter[1])
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 5 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 62.48 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 10: error is 97.158529 (50 iterations in 0.18 seconds)
#>  Fitting performed in 0.18 seconds.

res[[1]] <- data.frame(iteration = n.iter[1],
                       Y1 = res.tsne$Y[,1],
                       Y2 = res.tsne$Y[,2],
                       label = train.label)
i = 2
for(i in 2:length(add.iter)){
  cat(sprintf("%i: %i\n", i, n.iter[i]))
  system.time(
    res.tsne <- Rtsne::Rtsne(train.matrix, 
                             verbose = TRUE, 
                             num_threads = 5,
                             # theta=0.0, 
                             pca = FALSE, 
                             perplexity = 30, 
                             max_iter = n.iter[i],
                             Y_init = res[[i - 1]]$Y)
    
  )

  res[[i]] <- data.frame(iteration = n.iter[i],
                         Y1 = res.tsne$Y[,1],
                         Y2 = res.tsne$Y[,2],
                         label = train.label)

}
#>  2: 50
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 5 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 63.55 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158529 (50 iterations in 0.89 seconds)
#>  Fitting performed in 0.89 seconds.
#>  3: 100
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 5 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 60.42 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158529 (50 iterations in 0.95 seconds)
#>  Iteration 100: error is 92.361327 (50 iterations in 1.10 seconds)
#>  Fitting performed in 2.04 seconds.
#>  4: 150
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 5 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 56.60 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158528 (50 iterations in 0.90 seconds)
#>  Iteration 100: error is 92.458719 (50 iterations in 1.23 seconds)
#>  Iteration 150: error is 87.648740 (50 iterations in 1.02 seconds)
#>  Fitting performed in 3.15 seconds.
#>  5: 200
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 5 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 62.19 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158527 (50 iterations in 0.89 seconds)
#>  Iteration 100: error is 90.739395 (50 iterations in 0.95 seconds)
#>  Iteration 150: error is 87.612293 (50 iterations in 0.87 seconds)
#>  Iteration 200: error is 87.418899 (50 iterations in 0.88 seconds)
#>  Fitting performed in 3.60 seconds.
#>  6: 300
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 5 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 66.03 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158528 (50 iterations in 0.83 seconds)
#>  Iteration 100: error is 91.896950 (50 iterations in 1.05 seconds)
#>  Iteration 150: error is 87.708908 (50 iterations in 0.95 seconds)
#>  Iteration 200: error is 87.452434 (50 iterations in 1.00 seconds)
#>  Iteration 250: error is 87.433579 (50 iterations in 0.97 seconds)
#>  Iteration 300: error is 3.173892 (50 iterations in 0.76 seconds)
#>  Fitting performed in 5.56 seconds.
#>  7: 400
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 5 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 67.39 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158527 (50 iterations in 0.84 seconds)
#>  Iteration 100: error is 90.851555 (50 iterations in 1.09 seconds)
#>  Iteration 150: error is 87.900592 (50 iterations in 1.02 seconds)
#>  Iteration 200: error is 87.511758 (50 iterations in 1.02 seconds)
#>  Iteration 250: error is 87.402949 (50 iterations in 0.99 seconds)
#>  Iteration 300: error is 3.180593 (50 iterations in 0.98 seconds)
#>  Iteration 350: error is 2.785007 (50 iterations in 0.85 seconds)
#>  Iteration 400: error is 2.569635 (50 iterations in 0.82 seconds)
#>  Fitting performed in 7.61 seconds.
#>  8: 500
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 5 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 69.40 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158528 (50 iterations in 0.82 seconds)
#>  Iteration 100: error is 91.545910 (50 iterations in 0.85 seconds)
#>  Iteration 150: error is 87.598050 (50 iterations in 0.88 seconds)
#>  Iteration 200: error is 87.231868 (50 iterations in 0.86 seconds)
#>  Iteration 250: error is 87.219594 (50 iterations in 0.85 seconds)
#>  Iteration 300: error is 3.135650 (50 iterations in 0.77 seconds)
#>  Iteration 350: error is 2.736189 (50 iterations in 0.76 seconds)
#>  Iteration 400: error is 2.526436 (50 iterations in 0.75 seconds)
#>  Iteration 450: error is 2.389239 (50 iterations in 0.77 seconds)
#>  Iteration 500: error is 2.291406 (50 iterations in 0.80 seconds)
#>  Fitting performed in 8.12 seconds.
#>  9: 600
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 5 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 67.19 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158526 (50 iterations in 0.82 seconds)
#>  Iteration 100: error is 90.492232 (50 iterations in 0.85 seconds)
#>  Iteration 150: error is 87.448215 (50 iterations in 0.79 seconds)
#>  Iteration 200: error is 87.197309 (50 iterations in 0.76 seconds)
#>  Iteration 250: error is 87.194268 (50 iterations in 0.77 seconds)
#>  Iteration 300: error is 3.136153 (50 iterations in 0.79 seconds)
#>  Iteration 350: error is 2.740777 (50 iterations in 0.79 seconds)
#>  Iteration 400: error is 2.530741 (50 iterations in 0.81 seconds)
#>  Iteration 450: error is 2.393169 (50 iterations in 0.82 seconds)
#>  Iteration 500: error is 2.294419 (50 iterations in 0.84 seconds)
#>  Iteration 550: error is 2.219708 (50 iterations in 0.85 seconds)
#>  Iteration 600: error is 2.161054 (50 iterations in 0.83 seconds)
#>  Fitting performed in 9.71 seconds.
#>  10: 700
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 5 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 68.58 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158528 (50 iterations in 0.84 seconds)
#>  Iteration 100: error is 91.250797 (50 iterations in 0.89 seconds)
#>  Iteration 150: error is 88.031858 (50 iterations in 0.90 seconds)
#>  Iteration 200: error is 87.802331 (50 iterations in 0.91 seconds)
#>  Iteration 250: error is 87.762455 (50 iterations in 0.86 seconds)
#>  Iteration 300: error is 3.164359 (50 iterations in 0.80 seconds)
#>  Iteration 350: error is 2.771151 (50 iterations in 0.78 seconds)
#>  Iteration 400: error is 2.559561 (50 iterations in 0.76 seconds)
#>  Iteration 450: error is 2.419533 (50 iterations in 0.80 seconds)
#>  Iteration 500: error is 2.318972 (50 iterations in 0.78 seconds)
#>  Iteration 550: error is 2.242077 (50 iterations in 0.78 seconds)
#>  Iteration 600: error is 2.183665 (50 iterations in 0.80 seconds)
#>  Iteration 650: error is 2.137564 (50 iterations in 0.83 seconds)
#>  Iteration 700: error is 2.100897 (50 iterations in 0.84 seconds)
#>  Fitting performed in 11.57 seconds.
#>  11: 1000
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 5 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 66.73 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158527 (50 iterations in 0.92 seconds)
#>  Iteration 100: error is 90.854726 (50 iterations in 1.61 seconds)
#>  Iteration 150: error is 87.691913 (50 iterations in 0.99 seconds)
#>  Iteration 200: error is 87.370442 (50 iterations in 0.93 seconds)
#>  Iteration 250: error is 87.343758 (50 iterations in 0.91 seconds)
#>  Iteration 300: error is 3.141968 (50 iterations in 0.81 seconds)
#>  Iteration 350: error is 2.754031 (50 iterations in 0.78 seconds)
#>  Iteration 400: error is 2.545476 (50 iterations in 0.80 seconds)
#>  Iteration 450: error is 2.408360 (50 iterations in 0.79 seconds)
#>  Iteration 500: error is 2.310488 (50 iterations in 0.81 seconds)
#>  Iteration 550: error is 2.236917 (50 iterations in 0.80 seconds)
#>  Iteration 600: error is 2.179018 (50 iterations in 0.80 seconds)
#>  Iteration 650: error is 2.132963 (50 iterations in 0.83 seconds)
#>  Iteration 700: error is 2.096669 (50 iterations in 0.84 seconds)
#>  Iteration 750: error is 2.067037 (50 iterations in 0.82 seconds)
#>  Iteration 800: error is 2.043984 (50 iterations in 0.84 seconds)
#>  Iteration 850: error is 2.026025 (50 iterations in 0.82 seconds)
#>  Iteration 900: error is 2.012232 (50 iterations in 0.86 seconds)
#>  Iteration 950: error is 2.001311 (50 iterations in 0.88 seconds)
#>  Iteration 1000: error is 1.992429 (50 iterations in 0.88 seconds)
#>  Fitting performed in 17.72 seconds.
#>  12: 1500
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 5 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 58.51 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158528 (50 iterations in 0.84 seconds)
#>  Iteration 100: error is 91.528817 (50 iterations in 0.94 seconds)
#>  Iteration 150: error is 87.655942 (50 iterations in 0.86 seconds)
#>  Iteration 200: error is 87.401635 (50 iterations in 0.80 seconds)
#>  Iteration 250: error is 87.390413 (50 iterations in 0.80 seconds)
#>  Iteration 300: error is 3.150117 (50 iterations in 0.76 seconds)
#>  Iteration 350: error is 2.759333 (50 iterations in 0.80 seconds)
#>  Iteration 400: error is 2.547394 (50 iterations in 0.79 seconds)
#>  Iteration 450: error is 2.410243 (50 iterations in 0.82 seconds)
#>  Iteration 500: error is 2.312220 (50 iterations in 0.83 seconds)
#>  Iteration 550: error is 2.237924 (50 iterations in 0.80 seconds)
#>  Iteration 600: error is 2.180089 (50 iterations in 0.81 seconds)
#>  Iteration 650: error is 2.133598 (50 iterations in 0.82 seconds)
#>  Iteration 700: error is 2.096471 (50 iterations in 0.84 seconds)
#>  Iteration 750: error is 2.066134 (50 iterations in 0.86 seconds)
#>  Iteration 800: error is 2.043112 (50 iterations in 0.85 seconds)
#>  Iteration 850: error is 2.025149 (50 iterations in 0.85 seconds)
#>  Iteration 900: error is 2.011054 (50 iterations in 0.77 seconds)
#>  Iteration 950: error is 2.000807 (50 iterations in 0.79 seconds)
#>  Iteration 1000: error is 1.993250 (50 iterations in 0.80 seconds)
#>  Iteration 1050: error is 1.986982 (50 iterations in 0.82 seconds)
#>  Iteration 1100: error is 1.981659 (50 iterations in 0.81 seconds)
#>  Iteration 1150: error is 1.976530 (50 iterations in 0.80 seconds)
#>  Iteration 1200: error is 1.971739 (50 iterations in 0.81 seconds)
#>  Iteration 1250: error is 1.967146 (50 iterations in 0.82 seconds)
#>  Iteration 1300: error is 1.962795 (50 iterations in 0.83 seconds)
#>  Iteration 1350: error is 1.959035 (50 iterations in 0.83 seconds)
#>  Iteration 1400: error is 1.955480 (50 iterations in 0.80 seconds)
#>  Iteration 1450: error is 1.951481 (50 iterations in 0.85 seconds)
#>  Iteration 1500: error is 1.947439 (50 iterations in 0.86 seconds)
#>  Fitting performed in 24.69 seconds.
#>  13: 2000
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 5 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 58.62 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158528 (50 iterations in 0.89 seconds)
#>  Iteration 100: error is 91.701544 (50 iterations in 1.26 seconds)
#>  Iteration 150: error is 87.718649 (50 iterations in 0.99 seconds)
#>  Iteration 200: error is 87.421626 (50 iterations in 0.86 seconds)
#>  Iteration 250: error is 87.295610 (50 iterations in 0.85 seconds)
#>  Iteration 300: error is 3.163977 (50 iterations in 0.78 seconds)
#>  Iteration 350: error is 2.766114 (50 iterations in 0.74 seconds)
#>  Iteration 400: error is 2.548356 (50 iterations in 0.74 seconds)
#>  Iteration 450: error is 2.407818 (50 iterations in 0.76 seconds)
#>  Iteration 500: error is 2.307008 (50 iterations in 0.77 seconds)
#>  Iteration 550: error is 2.231244 (50 iterations in 0.77 seconds)
#>  Iteration 600: error is 2.173011 (50 iterations in 0.78 seconds)
#>  Iteration 650: error is 2.126874 (50 iterations in 0.81 seconds)
#>  Iteration 700: error is 2.090215 (50 iterations in 0.93 seconds)
#>  Iteration 750: error is 2.061422 (50 iterations in 0.90 seconds)
#>  Iteration 800: error is 2.039478 (50 iterations in 0.80 seconds)
#>  Iteration 850: error is 2.021641 (50 iterations in 0.83 seconds)
#>  Iteration 900: error is 2.007296 (50 iterations in 0.80 seconds)
#>  Iteration 950: error is 1.994402 (50 iterations in 0.82 seconds)
#>  Iteration 1000: error is 1.983175 (50 iterations in 0.87 seconds)
#>  Iteration 1050: error is 1.976216 (50 iterations in 0.82 seconds)
#>  Iteration 1100: error is 1.970135 (50 iterations in 0.82 seconds)
#>  Iteration 1150: error is 1.963933 (50 iterations in 0.86 seconds)
#>  Iteration 1200: error is 1.957391 (50 iterations in 0.81 seconds)
#>  Iteration 1250: error is 1.951244 (50 iterations in 0.83 seconds)
#>  Iteration 1300: error is 1.945571 (50 iterations in 0.82 seconds)
#>  Iteration 1350: error is 1.940771 (50 iterations in 0.82 seconds)
#>  Iteration 1400: error is 1.936940 (50 iterations in 0.83 seconds)
#>  Iteration 1450: error is 1.933444 (50 iterations in 0.80 seconds)
#>  Iteration 1500: error is 1.929544 (50 iterations in 0.79 seconds)
#>  Iteration 1550: error is 1.925853 (50 iterations in 0.80 seconds)
#>  Iteration 1600: error is 1.923100 (50 iterations in 0.80 seconds)
#>  Iteration 1650: error is 1.920598 (50 iterations in 0.84 seconds)
#>  Iteration 1700: error is 1.917857 (50 iterations in 0.82 seconds)
#>  Iteration 1750: error is 1.914636 (50 iterations in 0.84 seconds)
#>  Iteration 1800: error is 1.911834 (50 iterations in 0.83 seconds)
#>  Iteration 1850: error is 1.909228 (50 iterations in 0.82 seconds)
#>  Iteration 1900: error is 1.907078 (50 iterations in 0.80 seconds)
#>  Iteration 1950: error is 1.904833 (50 iterations in 0.82 seconds)
#>  Iteration 2000: error is 1.902994 (50 iterations in 0.83 seconds)
#>  Fitting performed in 33.36 seconds.
#>  14: 4000
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 5 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 56.60 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158528 (50 iterations in 0.81 seconds)
#>  Iteration 100: error is 91.104099 (50 iterations in 0.90 seconds)
#>  Iteration 150: error is 87.421907 (50 iterations in 0.83 seconds)
#>  Iteration 200: error is 87.243785 (50 iterations in 0.81 seconds)
#>  Iteration 250: error is 87.240871 (50 iterations in 0.82 seconds)
#>  Iteration 300: error is 3.136839 (50 iterations in 0.81 seconds)
#>  Iteration 350: error is 2.741795 (50 iterations in 0.79 seconds)
#>  Iteration 400: error is 2.532664 (50 iterations in 0.79 seconds)
#>  Iteration 450: error is 2.396711 (50 iterations in 0.78 seconds)
#>  Iteration 500: error is 2.298424 (50 iterations in 0.81 seconds)
#>  Iteration 550: error is 2.223870 (50 iterations in 0.82 seconds)
#>  Iteration 600: error is 2.165971 (50 iterations in 0.83 seconds)
#>  Iteration 650: error is 2.119579 (50 iterations in 0.84 seconds)
#>  Iteration 700: error is 2.081870 (50 iterations in 0.85 seconds)
#>  Iteration 750: error is 2.050715 (50 iterations in 0.84 seconds)
#>  Iteration 800: error is 2.024935 (50 iterations in 0.83 seconds)
#>  Iteration 850: error is 2.004529 (50 iterations in 0.83 seconds)
#>  Iteration 900: error is 1.988898 (50 iterations in 0.82 seconds)
#>  Iteration 950: error is 1.978179 (50 iterations in 0.82 seconds)
#>  Iteration 1000: error is 1.969653 (50 iterations in 0.80 seconds)
#>  Iteration 1050: error is 1.963218 (50 iterations in 0.83 seconds)
#>  Iteration 1100: error is 1.957369 (50 iterations in 0.83 seconds)
#>  Iteration 1150: error is 1.951666 (50 iterations in 0.85 seconds)
#>  Iteration 1200: error is 1.946405 (50 iterations in 0.85 seconds)
#>  Iteration 1250: error is 1.941208 (50 iterations in 0.90 seconds)
#>  Iteration 1300: error is 1.936344 (50 iterations in 0.88 seconds)
#>  Iteration 1350: error is 1.932056 (50 iterations in 0.86 seconds)
#>  Iteration 1400: error is 1.927897 (50 iterations in 0.88 seconds)
#>  Iteration 1450: error is 1.923819 (50 iterations in 0.85 seconds)
#>  Iteration 1500: error is 1.919751 (50 iterations in 0.83 seconds)
#>  Iteration 1550: error is 1.915946 (50 iterations in 0.85 seconds)
#>  Iteration 1600: error is 1.912396 (50 iterations in 0.89 seconds)
#>  Iteration 1650: error is 1.908977 (50 iterations in 0.88 seconds)
#>  Iteration 1700: error is 1.905759 (50 iterations in 0.89 seconds)
#>  Iteration 1750: error is 1.902626 (50 iterations in 0.86 seconds)
#>  Iteration 1800: error is 1.899715 (50 iterations in 0.87 seconds)
#>  Iteration 1850: error is 1.897106 (50 iterations in 0.90 seconds)
#>  Iteration 1900: error is 1.894744 (50 iterations in 0.82 seconds)
#>  Iteration 1950: error is 1.892361 (50 iterations in 0.82 seconds)
#>  Iteration 2000: error is 1.890173 (50 iterations in 0.86 seconds)
#>  Iteration 2050: error is 1.888325 (50 iterations in 0.84 seconds)
#>  Iteration 2100: error is 1.886578 (50 iterations in 0.84 seconds)
#>  Iteration 2150: error is 1.885064 (50 iterations in 0.84 seconds)
#>  Iteration 2200: error is 1.883556 (50 iterations in 0.84 seconds)
#>  Iteration 2250: error is 1.881984 (50 iterations in 0.84 seconds)
#>  Iteration 2300: error is 1.880327 (50 iterations in 0.84 seconds)
#>  Iteration 2350: error is 1.878578 (50 iterations in 0.85 seconds)
#>  Iteration 2400: error is 1.876908 (50 iterations in 0.85 seconds)
#>  Iteration 2450: error is 1.875184 (50 iterations in 0.94 seconds)
#>  Iteration 2500: error is 1.873445 (50 iterations in 0.88 seconds)
#>  Iteration 2550: error is 1.872074 (50 iterations in 0.86 seconds)
#>  Iteration 2600: error is 1.870789 (50 iterations in 0.85 seconds)
#>  Iteration 2650: error is 1.869528 (50 iterations in 0.85 seconds)
#>  Iteration 2700: error is 1.868020 (50 iterations in 0.89 seconds)
#>  Iteration 2750: error is 1.866593 (50 iterations in 0.88 seconds)
#>  Iteration 2800: error is 1.865337 (50 iterations in 0.88 seconds)
#>  Iteration 2850: error is 1.863979 (50 iterations in 0.89 seconds)
#>  Iteration 2900: error is 1.862796 (50 iterations in 0.88 seconds)
#>  Iteration 2950: error is 1.861857 (50 iterations in 0.87 seconds)
#>  Iteration 3000: error is 1.860754 (50 iterations in 0.90 seconds)
#>  Iteration 3050: error is 1.859724 (50 iterations in 0.89 seconds)
#>  Iteration 3100: error is 1.858735 (50 iterations in 0.88 seconds)
#>  Iteration 3150: error is 1.857795 (50 iterations in 0.92 seconds)
#>  Iteration 3200: error is 1.856671 (50 iterations in 0.87 seconds)
#>  Iteration 3250: error is 1.855587 (50 iterations in 0.86 seconds)
#>  Iteration 3300: error is 1.854608 (50 iterations in 0.87 seconds)
#>  Iteration 3350: error is 1.853711 (50 iterations in 0.89 seconds)
#>  Iteration 3400: error is 1.852882 (50 iterations in 0.92 seconds)
#>  Iteration 3450: error is 1.852177 (50 iterations in 0.92 seconds)
#>  Iteration 3500: error is 1.851320 (50 iterations in 0.93 seconds)
#>  Iteration 3550: error is 1.850411 (50 iterations in 0.92 seconds)
#>  Iteration 3600: error is 1.849453 (50 iterations in 0.90 seconds)
#>  Iteration 3650: error is 1.848700 (50 iterations in 0.91 seconds)
#>  Iteration 3700: error is 1.847631 (50 iterations in 0.91 seconds)
#>  Iteration 3750: error is 1.846709 (50 iterations in 0.91 seconds)
#>  Iteration 3800: error is 1.846083 (50 iterations in 0.90 seconds)
#>  Iteration 3850: error is 1.845434 (50 iterations in 0.92 seconds)
#>  Iteration 3900: error is 1.844776 (50 iterations in 0.91 seconds)
#>  Iteration 3950: error is 1.844131 (50 iterations in 0.90 seconds)
#>  Iteration 4000: error is 1.843325 (50 iterations in 0.88 seconds)
#>  Fitting performed in 68.96 seconds.

res %>% str(2)
#>  List of 14
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 10 10 10 10 10 10 10 10 10 10 ...
#>    ..$ Y1       : num [1:10000] -5.03e-06 1.30e-07 5.96e-06 1.37e-05 -9.13e-06 ...
#>    ..$ Y2       : num [1:10000] -1.71e-06 3.04e-06 -7.48e-06 5.63e-07 3.80e-06 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 50 50 50 50 50 50 50 50 50 50 ...
#>    ..$ Y1       : num [1:10000] 2.09e-05 3.15e-05 2.22e-05 1.22e-05 5.06e-05 ...
#>    ..$ Y2       : num [1:10000] -5.30e-06 -4.45e-06 7.19e-05 -3.74e-05 -2.91e-05 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 100 100 100 100 100 100 100 100 100 100 ...
#>    ..$ Y1       : num [1:10000] -0.7453 -0.7698 0.0976 0.7364 -0.8109 ...
#>    ..$ Y2       : num [1:10000] -0.0736 -0.1056 -0.0183 0.6199 -0.068 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 150 150 150 150 150 150 150 150 150 150 ...
#>    ..$ Y1       : num [1:10000] -0.981 -1.169 0.208 1.758 -1.129 ...
#>    ..$ Y2       : num [1:10000] 0.4174 0.1964 -0.2724 0.0544 0.4233 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 200 200 200 200 200 200 200 200 200 200 ...
#>    ..$ Y1       : num [1:10000] -0.182 -0.497 0.132 0.504 -0.253 ...
#>    ..$ Y2       : num [1:10000] -1.12081 -1.1246 0.00868 1.72896 -1.25223 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 300 300 300 300 300 300 300 300 300 300 ...
#>    ..$ Y1       : num [1:10000] -1.567 1.085 -0.891 -1.679 -1.412 ...
#>    ..$ Y2       : num [1:10000] -3.504 -6.165 -0.711 6.169 -6.502 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 400 400 400 400 400 400 400 400 400 400 ...
#>    ..$ Y1       : num [1:10000] -4.83 -0.717 -1.747 -1.164 -5.233 ...
#>    ..$ Y2       : num [1:10000] -4.64 -12.32 -1.48 13.5 -11.87 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 500 500 500 500 500 500 500 500 500 500 ...
#>    ..$ Y1       : num [1:10000] 5.031 -0.523 0.336 -4.727 5.741 ...
#>    ..$ Y2       : num [1:10000] -6.815 -17.145 -0.664 19.337 -16.718 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 600 600 600 600 600 600 600 600 600 600 ...
#>    ..$ Y1       : num [1:10000] 1.13 13.67 1.19 -13.67 8.23 ...
#>    ..$ Y2       : num [1:10000] 10.152 15.699 0.416 -21.346 20.956 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 700 700 700 700 700 700 700 700 700 700 ...
#>    ..$ Y1       : num [1:10000] -15.63 -18.99 1.64 12.34 -25.99 ...
#>    ..$ Y2       : num [1:10000] 1.63 14.51 6.8 -24.63 9.59 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 ...
#>    ..$ Y1       : num [1:10000] -23.6 -33.6 -6.8 36.2 -37.5 ...
#>    ..$ Y2       : num [1:10000] 9.26 -5.87 10.9 4.53 5.31 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 ...
#>    ..$ Y1       : num [1:10000] -26.78 -33.52 -8.67 32.77 -42.7 ...
#>    ..$ Y2       : num [1:10000] 2.31 -15.01 11.43 16.38 -4.44 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 2000 2000 2000 2000 2000 2000 2000 2000 2000 2000 ...
#>    ..$ Y1       : num [1:10000] 22.82 34.1 5.62 -36.57 41.58 ...
#>    ..$ Y2       : num [1:10000] 5.23 -13.15 18.58 -18.09 -1.97 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 4000 4000 4000 4000 4000 4000 4000 4000 4000 4000 ...
#>    ..$ Y1       : num [1:10000] -24.68 -20.99 -4.46 36.23 -36.05 ...
#>    ..$ Y2       : num [1:10000] -9.94 -34.13 -0.41 37.67 -29.51 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...

saveRDS(res, file = "./output/maxIter_mnist.Rds")
```

# plot


```r
res <- readRDS("./output/maxIter_mnist.Rds")

for(i in 1:NROW(res)){
  this.i <- res[[i]]$iteration[1]
  print(this.i)

  ggp.map.this <- res[[i]] %>% 
    ggplot(aes(x = Y1, y = Y2, color = factor(label))) +
    geom_point(alpha = 0.3) +
    labs(title = paste("iteration = ", this.i)) +
    theme(legend.position = "none")
  ggsave(filename = sprintf("./output/iter_size/iter_%04i.png", this.i))
}
#>  [1] 10
#>  Saving 7 x 5 in image
#>  [1] 50
#>  Saving 7 x 5 in image
#>  [1] 100
#>  Saving 7 x 5 in image
#>  [1] 150
#>  Saving 7 x 5 in image
#>  [1] 200
#>  Saving 7 x 5 in image
#>  [1] 300
#>  Saving 7 x 5 in image
#>  [1] 400
#>  Saving 7 x 5 in image
#>  [1] 500
#>  Saving 7 x 5 in image
#>  [1] 600
#>  Saving 7 x 5 in image
#>  [1] 700
#>  Saving 7 x 5 in image
#>  [1] 1000
#>  Saving 7 x 5 in image
#>  [1] 1500
#>  Saving 7 x 5 in image
#>  [1] 2000
#>  Saving 7 x 5 in image
#>  [1] 4000
#>  Saving 7 x 5 in image
```

