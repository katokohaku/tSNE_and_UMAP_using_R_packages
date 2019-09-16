#' wrapper for density plot with jittered x points using ggRidges package
#'
#' template wrapper ggridges::geom_density_ridges(., jittered_points = TRUE, position = position_points_jitter())
#'
#' @param .data a data frame or a matrix
#' @param title title text passed to labs(title = title, ...)
#' @param xlab text passed to labs(xlab = xlab, ...)
#' @param ylab text passed to labs(ylab = ylab, ...)
#' @param scaled logical. If .data are scaled for each colmn (default = TRUE).
#' @param .jitter.width numeric. Width for horizonal jittering. By default set to 0.05.
#' @param .alpha numeric (0, 1). Alpha transparency scales for density plots.
#' @param .scale numeric. Position scales for Y-axis.
#' @param .verbose ligical. If TRUE, which colmn were converted (from factor to numeric) is printed.
#' @param ... other options passed to theme(., ...)
#'
#' @examples
#' \dontrun{
#' ggDensityJitter(iris)
#'
#' iris %>%
#'   select(-Species) %>%
#'   ggDensityJitter("feature distribution", .scale = 0.7, .jitter.width = 0.1, .verbose = FALSE)
#' }
#' @return a ggplots object
#'
#' @export
#' @importFrom magrittr %>%
#' @import ggplot2
#

ggDensityJitter <- function(.data, title = "", xlab = "", ylab = "", scaled = TRUE,
                            .jitter.width = 0.05, .alpha = 0.3, .scale = 0.9,
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
      jittered_points = TRUE,
      position = ggridges::position_points_jitter(width = .jitter.width, height = 0),
      point_shape = '|', point_size = 3, point_alpha = 1, alpha = 0.7, scale = .scale) +
    theme(legend.position = 'none', ...) +
    labs(title = title, x=xlab, y=ylab)

  return(ggp.raincloud)
}
