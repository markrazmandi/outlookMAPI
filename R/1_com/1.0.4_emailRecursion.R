# construct email table through recursion---------------------------------------
emailRecursion <- function(outlook,emails) {

  # initialize base email table-------------------------------------------------
  emailsadd <- data.table()

  # extract email properties for qualified records------------------------------
  outlook[,.I[restricteditems>0 & irun!=1]] %>%
    lapply(function(j) {

      # disqualify record for recursion-----------------------------------------
      outlook[j,irun := 1]

      # restricted items com object parse---------------------------------------
      com <- baseObjectParse(outlook[j,folderpath])$Items()$Restrict(
        paste0("[Created] > '",outlook[j,restricteddate],"'")
      )

      # recurse through com objects with mapi namespace-------------------------
      lapply(com,function(k) {

        # extract email properties for qualified records------------------------
        emailsadd <<- emailProperties(outlook[j],k) %>%
          list(emailsadd,.) %>%
          rbindlist(fill=TRUE)

      }) %>% invisible()

    }) %>% invisible()

  # assign global runtime to new records----------------------------------------
  emailsadd[,runtime := Sys.time()]

  # enforce uniqueness and assign objects to global evirornment-----------------
  emails <<- list(emails,emailsadd) %>%
    rbindlist(fill=TRUE) %>%
    setorderv(c('entryid','attachment','runtime')) %>%
    unique(by=c('entryid','attachment'))

  outlook <<- outlook

}
