# install.packages("remotes")
remotes::install_github("rstudio/tensorflow")
reticulate::install_python()
install.packages("keras")

keras::install_keras()
tensorflow::install_tensorflow(envname = "r-tensorflow")
