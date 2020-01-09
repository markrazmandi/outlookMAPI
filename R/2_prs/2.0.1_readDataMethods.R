# read pdf data-----------------------------------------------------------------
readPdf <- function(filepath) {

  l <- pdf_text(filepath) %>%
    paste0(collapse='\n')

  return(l)

}

# read txt data-----------------------------------------------------------------
readTxt <- function(filepath) {

  l <- readLines(filepath,skipNul=TRUE,warn=FALSE) %>%
    paste0(collapse='\n')

  return(l)

}

# read csv data-----------------------------------------------------------------
readCsv <- function(filepath) {

  l <- read.csv(
    file=filepath,
    header=FALSE,
    colClasses='character'
  )

  do.call(paste,l) %>%
    paste0(collapse='\n')

}

# read xls/xlsx data------------------------------------------------------------
readXlsx <- function(filepath) {

  tryCatch({

    # read table and coerce to matrix-------------------------------------------
    l <- read_excel(
      path=filepath,
      col_names=FALSE,
      col_types='text'
    ) %>% as.matrix()

    # replace na values for collapse--------------------------------------------
    l[is.na(l)] <- ''

    # collapse matrix into string-----------------------------------------------
    apply(X=l,MARGIN=1,FUN=paste,collapse=' ') %>%
      paste0(collapse='\n')

  },error=function(e) {

    # read as text file if format is corrupted----------------------------------
    readTxt(filepath)

  })

}

# read html data----------------------------------------------------------------
readHtml <- function(filepath) {

  l <- read_html(filepath) %>%
    html_nodes('body') %>%
    html_text()

  return(l)

}
