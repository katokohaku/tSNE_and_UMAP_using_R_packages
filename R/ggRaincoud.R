#' rain could plot wrapper for ggRidges package
#'
#' template wrapper ggridges::geom_density_ridges(., jittered_points = TRUE, position = "raincloud")
#'
#' @param .data a data frame or a matrix
#' @param title title text passed to labs(title = title, ...)
#' @param xlab text passed to labs(xlab = xlab, ...)
#' @param ylab text passed to labs(ylab = ylab, ...)
#' @param scaled logical. If .data are scaled for each colmn (default = TRUE).
#' @param .alpha numeric (0, 1). Alpha transparency scales for density plots.
#' @param .scale numeric. Position scales for Y-axis.
#' @param .verbose ligical. If TRUE, which colmn were converted (from factor to numeric) is printed.
#' @param ... other options passed to theme(., ...)
#'
#' @examples
#' \dontrun{
#' ggRaincloud(iris)
#'
#' iris %>%
#'   select(-Species) %>%
#'   ggRaincloud("feature distribution",.scale = 0.7 .verbose = FALSE)
#' }
#' @return a ggplots object
#'
#' @export
#' @importFrom magrittr %>%
#' @import ggplot2
#

ggRaincloud <- function(.data, title = "", xlab = "", ylab = "", scaled = TRUE,
                        .alpha = 0.3, .scale = 0.9,
                        .verbose = TRUE, ...) {
  stopifnot(!missing(.data))

  mutate_all2 <- dplyr::mutate_all
  if(.verbose) {
    mutate_all2 <- tidylog::mutate_all
    cat("Force conversion to numeric\n")
  }

  .data <- .data %>%
    dplyr::mutate_if(is.character, factor) %>%
    mutate_all2(as.numeric)

  if(scaled) {
    .data <- scale(.data)
  }

  feature.value.long <- .data %>%
    data.frame() %>%
    tidyr::gather(key = "feature", value = "value")

  ggp.raincloud <- feature.value.long %>%
    ggplot(aes(x = value, y = feature, color = feature, fill = feature))+
    ggridges::geom_density_ridges(
      jittered_points = TRUE, position = "raincloud", alpha = .alpha, scale = .scale) +
    theme(legend.position = 'none', ...) +
    labs(title = title, x=xlab, y=ylab)

  return(ggp.raincloud)
}
