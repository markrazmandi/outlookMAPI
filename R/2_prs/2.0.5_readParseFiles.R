# parse files on single thread--------------------------------------------------
singleThreadFileParse <- function(emails_new,parse_level,parse_pars) {

  # create index----------------------------------------------------------------
  i <- seq_len(nrow(emails_new))

  # process filepaths-----------------------------------------------------------
  contentsadd <- lapply(i,function(j) {

    print(emails_new[j])

    # parse attachments into table----------------------------------------------
    parseFile(
      a=emails_new[j],
      parse_level=parse_level,
      parse_pars
    )

  }) %>% rbindlist(fill=TRUE)

  return(contentsadd)

}

# parse files over cluster------------------------------------------------------
parallelFileParse <- function(emails_new,parse_level,parse_pars) {

  # create cluster over cores---------------------------------------------------
  clust <- setupCluster(c('wdir','emails_new','parse_level','parse_pars'))

  # create index----------------------------------------------------------------
  i <- seq_len(nrow(emails_new))

  # process filepaths-----------------------------------------------------------
  contentsadd <- parLapplyLB(clust,i,function(j) {

    # parse attachments into table----------------------------------------------
    parseFile(
      a=emails_new[j],
      parse_level=parse_level,
      parse_pars
    )

  }) %>% rbindlist(fill=TRUE)

  # kill cluster----------------------------------------------------------------
  stopCluster(clust)

  return(contentsadd)

}

# read and parse email attachments----------------------------------------------
readParseFiles <- function(
  emails,
  contents,
  types,
  parse_level=c('bound','line','page'),
  parse_pars,
  method=c('single','parallel')
) {

  # index attachments for parsing-----------------------------------------------
  emails_new <- emails[write==1 & crun==0 & extension %in% types]

  # test for items to parse-----------------------------------------------------
  if (nrow(emails_new)==0) {

    return(cat('no items to parse',fill=TRUE))

  }

  # construct index for retrieving files----------------------------------------
  emails_new[,filepath := paste0(
    getwd(),'/data/ost/',
    sub('^.*[\\]+(.*@.*\\.com)[\\]+.*$','\\1',folderpath),
    '/',extension,'/',storepath
  )]

  # read and parse data across one or more cores--------------------------------
  contentsadd <- switch(
    EXPR=method[1],
    single=singleThreadFileParse(emails_new,parse_level[1],parse_pars),
    parallel=parallelFileParse(emails_new,parse_level[1],parse_pars)
  )

  # update parsed attachments---------------------------------------------------
  cols <- c('entryid','attachment')

  contentsadd[,unique(.SD),.SDcols=cols] %>%
    emails[.,crun := 1L,on=cols]

  contentsadd[text=='<error>',unique(.SD),.SDcols=cols] %>%
    emails[.,crun := 2L,on=cols]

  contentsadd[text=='<oversize>',unique(.SD),.SDcols=cols] %>%
    emails[.,crun := 3L,on=cols]

  # bind current parsed data----------------------------------------------------
  contents <- rbindlist(list(contents,contentsadd),fill=TRUE)

  # sort data for modelling-----------------------------------------------------
  pcols <- c('page','line','bound')

  setorderv(contents,c(cols,names(contents)[names(contents) %in% pcols]))

  # assign emails and contents to global environment----------------------------
  emails <<- emails
  contents <<- contents

}
