# build base model directories--------------------------------------------------
buildBaseDirectories <- function() {

  list(
    './data/dbs/bkp',
    './data/ost'
  ) %>%
    lapply(function(j) {

      if (!dir.exists(j)) {

        dir.create(j,showWarnings=FALSE,recursive=TRUE)

        cat('directory created:',j,fill=TRUE)

      } else {

        cat('directory exists:',j,fill=TRUE)

      }

    }) %>% invisible()

}
