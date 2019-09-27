---
author: "Satoshi Kato"
title: "Effect of t-SNE iteration"
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

res.tsne <- Rtsne::Rtsne(
  train.matrix, 
  verbose = TRUE, 
  num_threads = 5,
  # theta=0.0, 
  pca=FALSE, 
  perplexity = 50, 
  max_iter = n.iter[1])
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 5 threads.
#>  Using no_dims = 2, perplexity = 50.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 44.34 seconds (sparsity = 0.021150)!
#>  Learning embedding...
#>  Iteration 10: error is 91.138133 (50 iterations in 0.18 seconds)
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
                             num_threads = 7,
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
#>  OpenMP is working. 7 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 42.42 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158529 (50 iterations in 0.77 seconds)
#>  Fitting performed in 0.77 seconds.
#>  3: 100
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 7 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 44.83 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158529 (50 iterations in 1.09 seconds)
#>  Iteration 100: error is 92.361327 (50 iterations in 1.05 seconds)
#>  Fitting performed in 2.14 seconds.
#>  4: 150
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 7 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 39.81 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158528 (50 iterations in 0.72 seconds)
#>  Iteration 100: error is 92.458719 (50 iterations in 0.97 seconds)
#>  Iteration 150: error is 87.648539 (50 iterations in 0.79 seconds)
#>  Fitting performed in 2.48 seconds.
#>  5: 200
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 7 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 37.25 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158527 (50 iterations in 0.67 seconds)
#>  Iteration 100: error is 90.739395 (50 iterations in 0.76 seconds)
#>  Iteration 150: error is 87.612619 (50 iterations in 0.70 seconds)
#>  Iteration 200: error is 87.418929 (50 iterations in 0.68 seconds)
#>  Fitting performed in 2.81 seconds.
#>  6: 300
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 7 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 38.47 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158528 (50 iterations in 0.79 seconds)
#>  Iteration 100: error is 91.896950 (50 iterations in 1.04 seconds)
#>  Iteration 150: error is 87.708834 (50 iterations in 0.86 seconds)
#>  Iteration 200: error is 87.452725 (50 iterations in 0.80 seconds)
#>  Iteration 250: error is 87.433723 (50 iterations in 0.83 seconds)
#>  Iteration 300: error is 3.174318 (50 iterations in 0.73 seconds)
#>  Fitting performed in 5.05 seconds.
#>  7: 400
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 7 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 43.16 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158527 (50 iterations in 1.14 seconds)
#>  Iteration 100: error is 90.851555 (50 iterations in 0.93 seconds)
#>  Iteration 150: error is 87.900763 (50 iterations in 0.85 seconds)
#>  Iteration 200: error is 87.511338 (50 iterations in 0.74 seconds)
#>  Iteration 250: error is 87.403016 (50 iterations in 0.76 seconds)
#>  Iteration 300: error is 3.182395 (50 iterations in 0.67 seconds)
#>  Iteration 350: error is 2.784623 (50 iterations in 0.62 seconds)
#>  Iteration 400: error is 2.568166 (50 iterations in 0.65 seconds)
#>  Fitting performed in 6.36 seconds.
#>  8: 500
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 7 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 42.19 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158528 (50 iterations in 0.74 seconds)
#>  Iteration 100: error is 91.545910 (50 iterations in 0.77 seconds)
#>  Iteration 150: error is 87.598017 (50 iterations in 0.78 seconds)
#>  Iteration 200: error is 87.231795 (50 iterations in 0.76 seconds)
#>  Iteration 250: error is 87.219554 (50 iterations in 0.76 seconds)
#>  Iteration 300: error is 3.134322 (50 iterations in 0.69 seconds)
#>  Iteration 350: error is 2.735172 (50 iterations in 0.65 seconds)
#>  Iteration 400: error is 2.524142 (50 iterations in 0.67 seconds)
#>  Iteration 450: error is 2.387885 (50 iterations in 0.67 seconds)
#>  Iteration 500: error is 2.290509 (50 iterations in 0.69 seconds)
#>  Fitting performed in 7.16 seconds.
#>  9: 600
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 7 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 41.37 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158526 (50 iterations in 0.86 seconds)
#>  Iteration 100: error is 90.492232 (50 iterations in 0.81 seconds)
#>  Iteration 150: error is 87.448331 (50 iterations in 0.99 seconds)
#>  Iteration 200: error is 87.197269 (50 iterations in 0.83 seconds)
#>  Iteration 250: error is 87.194126 (50 iterations in 0.72 seconds)
#>  Iteration 300: error is 3.137342 (50 iterations in 0.77 seconds)
#>  Iteration 350: error is 2.742246 (50 iterations in 0.70 seconds)
#>  Iteration 400: error is 2.531166 (50 iterations in 0.69 seconds)
#>  Iteration 450: error is 2.393841 (50 iterations in 0.71 seconds)
#>  Iteration 500: error is 2.295503 (50 iterations in 0.72 seconds)
#>  Iteration 550: error is 2.220912 (50 iterations in 0.75 seconds)
#>  Iteration 600: error is 2.162696 (50 iterations in 0.74 seconds)
#>  Fitting performed in 9.29 seconds.
#>  10: 700
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 7 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 42.58 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158528 (50 iterations in 0.71 seconds)
#>  Iteration 100: error is 91.250797 (50 iterations in 0.79 seconds)
#>  Iteration 150: error is 88.031819 (50 iterations in 0.76 seconds)
#>  Iteration 200: error is 87.802097 (50 iterations in 0.71 seconds)
#>  Iteration 250: error is 87.762432 (50 iterations in 0.71 seconds)
#>  Iteration 300: error is 3.165843 (50 iterations in 0.68 seconds)
#>  Iteration 350: error is 2.771335 (50 iterations in 0.63 seconds)
#>  Iteration 400: error is 2.559379 (50 iterations in 0.65 seconds)
#>  Iteration 450: error is 2.424658 (50 iterations in 0.68 seconds)
#>  Iteration 500: error is 2.323089 (50 iterations in 0.74 seconds)
#>  Iteration 550: error is 2.246208 (50 iterations in 0.73 seconds)
#>  Iteration 600: error is 2.186414 (50 iterations in 0.72 seconds)
#>  Iteration 650: error is 2.140310 (50 iterations in 0.73 seconds)
#>  Iteration 700: error is 2.105313 (50 iterations in 0.72 seconds)
#>  Fitting performed in 9.98 seconds.
#>  11: 1000
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 7 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 42.25 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158527 (50 iterations in 0.84 seconds)
#>  Iteration 100: error is 90.854726 (50 iterations in 1.47 seconds)
#>  Iteration 150: error is 87.691891 (50 iterations in 0.90 seconds)
#>  Iteration 200: error is 87.370354 (50 iterations in 0.82 seconds)
#>  Iteration 250: error is 87.343817 (50 iterations in 0.80 seconds)
#>  Iteration 300: error is 3.143911 (50 iterations in 0.72 seconds)
#>  Iteration 350: error is 2.755107 (50 iterations in 0.69 seconds)
#>  Iteration 400: error is 2.545920 (50 iterations in 0.67 seconds)
#>  Iteration 450: error is 2.408593 (50 iterations in 0.73 seconds)
#>  Iteration 500: error is 2.310469 (50 iterations in 0.71 seconds)
#>  Iteration 550: error is 2.236552 (50 iterations in 0.72 seconds)
#>  Iteration 600: error is 2.178257 (50 iterations in 0.71 seconds)
#>  Iteration 650: error is 2.131737 (50 iterations in 0.71 seconds)
#>  Iteration 700: error is 2.094726 (50 iterations in 0.75 seconds)
#>  Iteration 750: error is 2.065547 (50 iterations in 0.78 seconds)
#>  Iteration 800: error is 2.042558 (50 iterations in 0.77 seconds)
#>  Iteration 850: error is 2.024315 (50 iterations in 0.78 seconds)
#>  Iteration 900: error is 2.010060 (50 iterations in 0.75 seconds)
#>  Iteration 950: error is 1.999172 (50 iterations in 0.76 seconds)
#>  Iteration 1000: error is 1.990327 (50 iterations in 0.77 seconds)
#>  Fitting performed in 15.83 seconds.
#>  12: 1500
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 7 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 41.05 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158528 (50 iterations in 0.76 seconds)
#>  Iteration 100: error is 91.528817 (50 iterations in 0.83 seconds)
#>  Iteration 150: error is 87.656144 (50 iterations in 0.87 seconds)
#>  Iteration 200: error is 87.401748 (50 iterations in 0.84 seconds)
#>  Iteration 250: error is 87.390458 (50 iterations in 0.93 seconds)
#>  Iteration 300: error is 3.151176 (50 iterations in 0.77 seconds)
#>  Iteration 350: error is 2.760516 (50 iterations in 0.73 seconds)
#>  Iteration 400: error is 2.547334 (50 iterations in 0.75 seconds)
#>  Iteration 450: error is 2.410303 (50 iterations in 0.73 seconds)
#>  Iteration 500: error is 2.312260 (50 iterations in 0.74 seconds)
#>  Iteration 550: error is 2.237682 (50 iterations in 0.75 seconds)
#>  Iteration 600: error is 2.179083 (50 iterations in 0.75 seconds)
#>  Iteration 650: error is 2.131975 (50 iterations in 0.73 seconds)
#>  Iteration 700: error is 2.094379 (50 iterations in 0.75 seconds)
#>  Iteration 750: error is 2.064237 (50 iterations in 0.75 seconds)
#>  Iteration 800: error is 2.041400 (50 iterations in 0.77 seconds)
#>  Iteration 850: error is 2.025001 (50 iterations in 0.74 seconds)
#>  Iteration 900: error is 2.012270 (50 iterations in 0.75 seconds)
#>  Iteration 950: error is 2.002342 (50 iterations in 0.78 seconds)
#>  Iteration 1000: error is 1.994357 (50 iterations in 0.78 seconds)
#>  Iteration 1050: error is 1.988157 (50 iterations in 0.74 seconds)
#>  Iteration 1100: error is 1.982537 (50 iterations in 0.73 seconds)
#>  Iteration 1150: error is 1.977327 (50 iterations in 0.78 seconds)
#>  Iteration 1200: error is 1.972698 (50 iterations in 0.77 seconds)
#>  Iteration 1250: error is 1.968046 (50 iterations in 0.77 seconds)
#>  Iteration 1300: error is 1.963162 (50 iterations in 1.22 seconds)
#>  Iteration 1350: error is 1.958550 (50 iterations in 0.90 seconds)
#>  Iteration 1400: error is 1.953935 (50 iterations in 0.84 seconds)
#>  Iteration 1450: error is 1.949511 (50 iterations in 0.84 seconds)
#>  Iteration 1500: error is 1.945552 (50 iterations in 0.95 seconds)
#>  Fitting performed in 24.03 seconds.
#>  13: 2000
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 7 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 45.63 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158528 (50 iterations in 0.90 seconds)
#>  Iteration 100: error is 91.701544 (50 iterations in 1.20 seconds)
#>  Iteration 150: error is 87.718646 (50 iterations in 1.00 seconds)
#>  Iteration 200: error is 87.421493 (50 iterations in 0.89 seconds)
#>  Iteration 250: error is 87.295784 (50 iterations in 0.80 seconds)
#>  Iteration 300: error is 3.163875 (50 iterations in 0.72 seconds)
#>  Iteration 350: error is 2.765394 (50 iterations in 0.67 seconds)
#>  Iteration 400: error is 2.551209 (50 iterations in 0.70 seconds)
#>  Iteration 450: error is 2.410514 (50 iterations in 0.71 seconds)
#>  Iteration 500: error is 2.312744 (50 iterations in 0.71 seconds)
#>  Iteration 550: error is 2.238697 (50 iterations in 0.73 seconds)
#>  Iteration 600: error is 2.181137 (50 iterations in 0.70 seconds)
#>  Iteration 650: error is 2.134817 (50 iterations in 0.73 seconds)
#>  Iteration 700: error is 2.097952 (50 iterations in 0.72 seconds)
#>  Iteration 750: error is 2.069113 (50 iterations in 0.72 seconds)
#>  Iteration 800: error is 2.045761 (50 iterations in 0.75 seconds)
#>  Iteration 850: error is 2.028176 (50 iterations in 0.73 seconds)
#>  Iteration 900: error is 2.014951 (50 iterations in 0.76 seconds)
#>  Iteration 950: error is 2.003910 (50 iterations in 0.73 seconds)
#>  Iteration 1000: error is 1.994483 (50 iterations in 0.74 seconds)
#>  Iteration 1050: error is 1.987179 (50 iterations in 0.77 seconds)
#>  Iteration 1100: error is 1.980952 (50 iterations in 0.75 seconds)
#>  Iteration 1150: error is 1.975128 (50 iterations in 0.78 seconds)
#>  Iteration 1200: error is 1.969870 (50 iterations in 0.77 seconds)
#>  Iteration 1250: error is 1.965285 (50 iterations in 0.76 seconds)
#>  Iteration 1300: error is 1.960691 (50 iterations in 0.76 seconds)
#>  Iteration 1350: error is 1.956049 (50 iterations in 0.78 seconds)
#>  Iteration 1400: error is 1.951462 (50 iterations in 0.77 seconds)
#>  Iteration 1450: error is 1.947153 (50 iterations in 0.77 seconds)
#>  Iteration 1500: error is 1.943730 (50 iterations in 0.75 seconds)
#>  Iteration 1550: error is 1.940877 (50 iterations in 0.76 seconds)
#>  Iteration 1600: error is 1.938092 (50 iterations in 0.75 seconds)
#>  Iteration 1650: error is 1.935026 (50 iterations in 0.75 seconds)
#>  Iteration 1700: error is 1.932080 (50 iterations in 0.77 seconds)
#>  Iteration 1750: error is 1.928797 (50 iterations in 0.79 seconds)
#>  Iteration 1800: error is 1.925305 (50 iterations in 0.77 seconds)
#>  Iteration 1850: error is 1.922515 (50 iterations in 0.78 seconds)
#>  Iteration 1900: error is 1.920042 (50 iterations in 0.75 seconds)
#>  Iteration 1950: error is 1.917534 (50 iterations in 0.78 seconds)
#>  Iteration 2000: error is 1.914978 (50 iterations in 0.78 seconds)
#>  Fitting performed in 30.97 seconds.
#>  14: 4000
#>  Read the 10000 x 784 data matrix successfully!
#>  OpenMP is working. 7 threads.
#>  Using no_dims = 2, perplexity = 30.000000, and theta = 0.500000
#>  Computing input similarities...
#>  Building tree...
#>   - point 10000 of 10000
#>  Done in 41.95 seconds (sparsity = 0.012715)!
#>  Learning embedding...
#>  Iteration 50: error is 97.158528 (50 iterations in 0.74 seconds)
#>  Iteration 100: error is 91.104099 (50 iterations in 0.82 seconds)
#>  Iteration 150: error is 87.421881 (50 iterations in 0.72 seconds)
#>  Iteration 200: error is 87.243697 (50 iterations in 0.72 seconds)
#>  Iteration 250: error is 87.240880 (50 iterations in 0.75 seconds)
#>  Iteration 300: error is 3.137428 (50 iterations in 0.71 seconds)
#>  Iteration 350: error is 2.741988 (50 iterations in 0.69 seconds)
#>  Iteration 400: error is 2.533727 (50 iterations in 0.74 seconds)
#>  Iteration 450: error is 2.397785 (50 iterations in 0.69 seconds)
#>  Iteration 500: error is 2.300056 (50 iterations in 0.70 seconds)
#>  Iteration 550: error is 2.225556 (50 iterations in 0.72 seconds)
#>  Iteration 600: error is 2.167537 (50 iterations in 0.74 seconds)
#>  Iteration 650: error is 2.120570 (50 iterations in 0.72 seconds)
#>  Iteration 700: error is 2.082138 (50 iterations in 0.75 seconds)
#>  Iteration 750: error is 2.051240 (50 iterations in 0.78 seconds)
#>  Iteration 800: error is 2.025690 (50 iterations in 0.80 seconds)
#>  Iteration 850: error is 2.004823 (50 iterations in 0.79 seconds)
#>  Iteration 900: error is 1.987944 (50 iterations in 0.78 seconds)
#>  Iteration 950: error is 1.974773 (50 iterations in 0.79 seconds)
#>  Iteration 1000: error is 1.964359 (50 iterations in 0.81 seconds)
#>  Iteration 1050: error is 1.955541 (50 iterations in 0.78 seconds)
#>  Iteration 1100: error is 1.948878 (50 iterations in 0.83 seconds)
#>  Iteration 1150: error is 1.943330 (50 iterations in 0.79 seconds)
#>  Iteration 1200: error is 1.938648 (50 iterations in 0.79 seconds)
#>  Iteration 1250: error is 1.934729 (50 iterations in 0.78 seconds)
#>  Iteration 1300: error is 1.930773 (50 iterations in 0.78 seconds)
#>  Iteration 1350: error is 1.927411 (50 iterations in 0.78 seconds)
#>  Iteration 1400: error is 1.924309 (50 iterations in 0.75 seconds)
#>  Iteration 1450: error is 1.921566 (50 iterations in 0.79 seconds)
#>  Iteration 1500: error is 1.918616 (50 iterations in 0.77 seconds)
#>  Iteration 1550: error is 1.915518 (50 iterations in 0.76 seconds)
#>  Iteration 1600: error is 1.912198 (50 iterations in 0.78 seconds)
#>  Iteration 1650: error is 1.909123 (50 iterations in 0.78 seconds)
#>  Iteration 1700: error is 1.906481 (50 iterations in 0.78 seconds)
#>  Iteration 1750: error is 1.904056 (50 iterations in 0.76 seconds)
#>  Iteration 1800: error is 1.901931 (50 iterations in 0.77 seconds)
#>  Iteration 1850: error is 1.899727 (50 iterations in 0.79 seconds)
#>  Iteration 1900: error is 1.897458 (50 iterations in 0.78 seconds)
#>  Iteration 1950: error is 1.895190 (50 iterations in 0.78 seconds)
#>  Iteration 2000: error is 1.892962 (50 iterations in 0.79 seconds)
#>  Iteration 2050: error is 1.890609 (50 iterations in 0.78 seconds)
#>  Iteration 2100: error is 1.888130 (50 iterations in 0.77 seconds)
#>  Iteration 2150: error is 1.885706 (50 iterations in 0.77 seconds)
#>  Iteration 2200: error is 1.883401 (50 iterations in 0.77 seconds)
#>  Iteration 2250: error is 1.881426 (50 iterations in 0.79 seconds)
#>  Iteration 2300: error is 1.879425 (50 iterations in 0.78 seconds)
#>  Iteration 2350: error is 1.877432 (50 iterations in 0.76 seconds)
#>  Iteration 2400: error is 1.875734 (50 iterations in 0.80 seconds)
#>  Iteration 2450: error is 1.873974 (50 iterations in 0.86 seconds)
#>  Iteration 2500: error is 1.872305 (50 iterations in 0.83 seconds)
#>  Iteration 2550: error is 1.870582 (50 iterations in 0.76 seconds)
#>  Iteration 2600: error is 1.869196 (50 iterations in 0.78 seconds)
#>  Iteration 2650: error is 1.867751 (50 iterations in 0.78 seconds)
#>  Iteration 2700: error is 1.866491 (50 iterations in 0.76 seconds)
#>  Iteration 2750: error is 1.865009 (50 iterations in 0.76 seconds)
#>  Iteration 2800: error is 1.863660 (50 iterations in 0.79 seconds)
#>  Iteration 2850: error is 1.862055 (50 iterations in 0.77 seconds)
#>  Iteration 2900: error is 1.860549 (50 iterations in 0.80 seconds)
#>  Iteration 2950: error is 1.859371 (50 iterations in 0.77 seconds)
#>  Iteration 3000: error is 1.858150 (50 iterations in 0.81 seconds)
#>  Iteration 3050: error is 1.856952 (50 iterations in 0.78 seconds)
#>  Iteration 3100: error is 1.856076 (50 iterations in 0.78 seconds)
#>  Iteration 3150: error is 1.855283 (50 iterations in 0.79 seconds)
#>  Iteration 3200: error is 1.854260 (50 iterations in 0.79 seconds)
#>  Iteration 3250: error is 1.853239 (50 iterations in 0.78 seconds)
#>  Iteration 3300: error is 1.852043 (50 iterations in 0.78 seconds)
#>  Iteration 3350: error is 1.850920 (50 iterations in 0.77 seconds)
#>  Iteration 3400: error is 1.849826 (50 iterations in 0.79 seconds)
#>  Iteration 3450: error is 1.848811 (50 iterations in 0.81 seconds)
#>  Iteration 3500: error is 1.847799 (50 iterations in 0.78 seconds)
#>  Iteration 3550: error is 1.846669 (50 iterations in 0.78 seconds)
#>  Iteration 3600: error is 1.845621 (50 iterations in 0.79 seconds)
#>  Iteration 3650: error is 1.844584 (50 iterations in 0.80 seconds)
#>  Iteration 3700: error is 1.843595 (50 iterations in 0.76 seconds)
#>  Iteration 3750: error is 1.842719 (50 iterations in 0.77 seconds)
#>  Iteration 3800: error is 1.841820 (50 iterations in 0.79 seconds)
#>  Iteration 3850: error is 1.840818 (50 iterations in 0.78 seconds)
#>  Iteration 3900: error is 1.839889 (50 iterations in 0.77 seconds)
#>  Iteration 3950: error is 1.838998 (50 iterations in 0.79 seconds)
#>  Iteration 4000: error is 1.838348 (50 iterations in 0.80 seconds)
#>  Fitting performed in 61.95 seconds.

res %>% str(2)
#>  List of 14
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 10 10 10 10 10 10 10 10 10 10 ...
#>    ..$ Y1       : num [1:10000] -5.74e-06 -1.42e-06 4.70e-06 1.70e-05 -8.83e-06 ...
#>    ..$ Y2       : num [1:10000] -2.78e-06 7.82e-06 -1.28e-05 -3.83e-06 1.73e-06 ...
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
#>    ..$ Y2       : num [1:10000] 0.4174 0.1964 -0.2724 0.0543 0.4234 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 200 200 200 200 200 200 200 200 200 200 ...
#>    ..$ Y1       : num [1:10000] -0.181 -0.497 0.132 0.504 -0.253 ...
#>    ..$ Y2       : num [1:10000] -1.12074 -1.12469 0.00882 1.7291 -1.25243 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 300 300 300 300 300 300 300 300 300 300 ...
#>    ..$ Y1       : num [1:10000] -1.577 1.137 -0.879 -1.633 -1.406 ...
#>    ..$ Y2       : num [1:10000] -3.594 -6.173 -0.723 6.23 -6.497 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 400 400 400 400 400 400 400 400 400 400 ...
#>    ..$ Y1       : num [1:10000] -4.984 -0.738 -1.409 -1.019 -5.244 ...
#>    ..$ Y2       : num [1:10000] -4.7 -12.21 -1.68 13.55 -11.84 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 500 500 500 500 500 500 500 500 500 500 ...
#>    ..$ Y1       : num [1:10000] 5.073 -0.606 0.455 -4.605 5.726 ...
#>    ..$ Y2       : num [1:10000] -7.049 -17.037 -0.399 19.371 -16.73 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 600 600 600 600 600 600 600 600 600 600 ...
#>    ..$ Y1       : num [1:10000] 1.13 13.91 1.13 -14.06 8.31 ...
#>    ..$ Y2       : num [1:10000] 10.068 15.761 0.198 -21.164 20.889 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 700 700 700 700 700 700 700 700 700 700 ...
#>    ..$ Y1       : num [1:10000] -15.39 -18.68 1.15 12.47 -26.73 ...
#>    ..$ Y2       : num [1:10000] 0.821 13.936 6.729 -24.127 9.214 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 ...
#>    ..$ Y1       : num [1:10000] -23.52 -33.97 -6.65 36.8 -37.34 ...
#>    ..$ Y2       : num [1:10000] 9.03 -6.21 10.01 4.77 5.34 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 ...
#>    ..$ Y1       : num [1:10000] -26.82 -33.51 -8.46 31.59 -42.42 ...
#>    ..$ Y2       : num [1:10000] 1.55 -14.97 11.06 16.26 -4.27 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 2000 2000 2000 2000 2000 2000 2000 2000 2000 2000 ...
#>    ..$ Y1       : num [1:10000] 27.53 38.99 5.05 -35.27 45.34 ...
#>    ..$ Y2       : num [1:10000] 6.2 -11.9 16.9 -18.4 1.5 ...
#>    ..$ label    : int [1:10000] 9 7 8 0 3 3 8 4 3 0 ...
#>   $ :'data.frame':	10000 obs. of  4 variables:
#>    ..$ iteration: num [1:10000] 4000 4000 4000 4000 4000 4000 4000 4000 4000 4000 ...
#>    ..$ Y1       : num [1:10000] -24.66 -21.95 -4.21 37.83 -36.98 ...
#>    ..$ Y2       : num [1:10000] -10.43 -34.96 -3.96 38.1 -30.29 ...
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
    geom_point(alpha = 0.5, size = 0.2) + 
    theme_bw() +
    labs(title = paste("iteration = ", this.i)) +
    theme(legend.position = "none")
  ggsave(filename = sprintf("./output/iter_size/iter_%04i.png", this.i),
         height = 4, width = 4)
}
#>  [1] 10
#>  [1] 50
#>  [1] 100
#>  [1] 150
#>  [1] 200
#>  [1] 300
#>  [1] 400
#>  [1] 500
#>  [1] 600
#>  [1] 700
#>  [1] 1000
#>  [1] 1500
#>  [1] 2000
#>  [1] 4000
```

