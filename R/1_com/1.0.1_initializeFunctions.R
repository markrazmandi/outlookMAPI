# build com object string from path---------------------------------------------
baseObjectParse <- function(string) {

  # evaluate com object path----------------------------------------------------
  unlist(strsplit(string,'[\\]+'))[-1] %>%
    paste0('$Folders("',.,'")',collapse='') %>%
    paste0('mapi',.) %>%
    parse(text=.) %>%
    eval()

}

# restrict com object by most recent extraction date----------------------------
maxDate <- function(emails,objpath,restricteddate=NULL) {

  if (is.null(restricteddate)) {

    if (nrow(emails)>0) {

      dates <- emails[folderpath==objpath,runtime]

      if (length(dates)>0) {

        restricteddate <- format(max(dates,na.rm=TRUE)-1,'%m/%d/%Y')

      } else {

        restricteddate <- '01/01/1901'

      }

    } else {

      restricteddate <- '01/01/1901'

    }

  } else {

    restricteddate <- format(as.Date(restricteddate),'%m/%d/%Y')

  }

  return(restricteddate)

}

# create account directories----------------------------------------------------
accountDirectory <- function(outlook,extension) {

  # extract account from object path--------------------------------------------
  account <- outlook[,unlist(
    strsplit(folderpath,'[\\]+')
  )[2],by=folderpath]$V1 %>% unique()

  # account attachment directory------------------------------------------------
  dir <- paste0(getwd(),'/data/ost/',account)

  # create directory if needed--------------------------------------------------
  if (!dir.exists(dir)) {

    dir.create(dir)

    cat('directory created:',dir,fill=TRUE)

  }

  # attachment extension directory----------------------------------------------
  if (!missing(extension)) {

    dir <- paste0(dir,'/',extension,'/')

  }

  # create directory if necessary-----------------------------------------------
  if (!dir.exists(dir)) {

    dir.create(dir)

    cat('directory created:',dir,fill=TRUE)

  }

  return(dir)

}

# com object datetime conversion------------------------------------------------
as.comDateTime <- function(x) {

  as.POSIXct(as.numeric(x)*86400,origin='1899-12-30',tz='UTC')

}

# normalize filepaths-----------------------------------------------------------
normalizePath <- function(creationtime,filename,extension) {

  paste(

    gsub('-|:','',creationtime),
    sub('(.*)(\\..*)$','\\1',filename) %>%
      gsub('([[:punct:]|[:space:]]|[^[:ascii:]])+','_',.,perl=TRUE) %>%
      sub('_$','',.)

  ) %>% gsub('\\s+','_',.) %>%
    toupper(.) %>%
    paste0(.,'.',extension)

}
