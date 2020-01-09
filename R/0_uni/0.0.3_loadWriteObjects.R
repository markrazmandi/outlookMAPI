# load database objects to global environment-----------------------------------
loadObjects <- function(objs) {

  # load each object to global environment--------------------------------------
  lapply(objs,function(j) {

    if (!exists(j,.GlobalEnv,mode='list')) {

      filepath <- paste0('./data/dbs/',j,'.rds')

      if (file.exists(filepath)) {

        assign(j,readRDS(filepath),pos=1L)

        cat(j,'- loaded to global environment',fill=TRUE)

      } else {

        assign(j,data.table(),pos=1L)

        cat(j,'- object does not exist; assign new object',fill=TRUE)

      }

    } else {

      cat(j,'- already loaded to global environment',fill=TRUE)

    }

  }) %>% invisible()

}

# write database objects from global environment--------------------------------
writeObjects <- function(objs) {

  dt <- format(Sys.time(),'_%m%d%Y%H%M%S')

  lapply(objs,function(j) {

    # build object and backup file paths----------------------------------------
    opath <- paste0('./data/dbs/',j,'.rds')

    obkpath <- paste0('./data/dbs/bkp/',j,dt,'.rds')

    # backup data objects-------------------------------------------------------
    if (file.exists(opath)) {

      file.rename(opath,obkpath)

      cat(j,'- data object backed up to',obkpath,fill=TRUE)

    }

    # save data object----------------------------------------------------------
    saveRDS(get(j),file=opath,compress=FALSE)

    cat(j,'- data object written to',opath,fill=TRUE)

  }) %>% invisible()

}
