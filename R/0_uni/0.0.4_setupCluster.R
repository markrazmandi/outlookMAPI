# create cluster over cores-----------------------------------------------------
setupCluster <- function(objs,n) {

  # kill cluster----------------------------------------------------------------
  suppressWarnings(print(system('TASKKILL /F /IM Rscript.exe',intern=TRUE)))

  # assign cluster size---------------------------------------------------------
  if (missing(n)) {

    n <- ceiling(detectCores()*0.75)

  }

  # build nodes from detected cores---------------------------------------------
  clust <- makeCluster(n)

  # export global parameters to cluster-----------------------------------------
  clusterExport(clust,objs,parent.frame())

  # load libraries across cluster-----------------------------------------------
  clusterEvalQ(clust,{

    setwd(wdir)

    source('./R/0_uni/0.0.0_setup.R')

    loadLibraries()

  })

  return(clust)

}
