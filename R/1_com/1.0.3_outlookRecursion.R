# construct outlook folder structure through recursion--------------------------
outlookRecursion <- function(accounts,restricteddate=NULL) {

  # create com object-----------------------------------------------------------
  mapi <<- COMCreate('Outlook.Application')$GetNameSpace('MAPI')

  # initialize base outlook table-----------------------------------------------
  outlook <<- lapply(accounts,function(j) {

    # extract folder properties into table record-----------------------------
    folderProperties(mapi$Folders(j),emails,restricteddate)

  }) %>% rbindlist(fill=TRUE)

  # recurse through com objects with mapi namespace-----------------------------
  while (outlook[,any(folders>0 & frun!=1)]) {

    # subset qualified table indecies and recurse-------------------------------
    folders <- outlook[,.I[folders>0 & frun!=1]] %>%
      lapply(function(j) {

        # disqualify record for recursion---------------------------------------
        outlook[j,`:=` (frun=1,irun=0)]

        # extract folder properties for qualified records-----------------------
        baseObjectParse(outlook[j,folderpath])$Folders() %>%
          lapply(function(com) {

            # extract folder properties into table record-----------------------
            folderProperties(com,emails,restricteddate)

          }) %>% rbindlist(fill=TRUE)

      }) %>% rbindlist(fill=TRUE)

    # assign base outlook table to global environment---------------------------
    outlook <<- rbindlist(list(outlook,folders),fill=TRUE)

  }

}
