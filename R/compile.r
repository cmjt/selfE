#' @importFrom TMB compile MakeADFun sdreport
#' @importFrom ggplot2 ggplot aes xlab ylab geom_line theme_minimal geom_histogram .data
#' geom_sf theme ggtitle geom_abline theme_void
#' @importFrom gridExtra grid.arrange
#' @importFrom grid textGrob gpar
#' @importFrom utils sessionInfo tail
#' @importFrom grDevices dev.new
#' @importFrom graphics points
#' @importFrom stats ppoints qexp quantile runif qlogis optim plogis ks.test Box.test nlminb
#' @importFrom sf st_sfc st_polygon st_sf st_as_sf st_coordinates st_multipoint st_crs st_is_valid
#' st_make_valid st_polygon st_intersects st_intersection st_area st_geometry st_contains
#' @importFrom dplyr left_join
#' @importFrom reshape2 melt
#' @importFrom methods is
#' @importFrom Matrix diag sparseMatrix
#' @importFrom INLA inla.spde.make.A inla.spde2.matern
#' @useDynLib custom_hawkes
#' @useDynLib hawkes
#' @useDynLib lgcp
#' @useDynLib marked_lgcp
#' @useDynLib neg_alpha_custom_hawkes
#' @useDynLib neg_alpha_hawkes
#' @useDynLib spatial_hawkes
#' @useDynLib spde_hawkes
NULL
