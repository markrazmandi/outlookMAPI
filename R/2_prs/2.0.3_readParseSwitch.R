# read target file types--------------------------------------------------------
readSwitch <- function(filepath,extension) {

  # read attachment data--------------------------------------------------------
  chr <- switch(
    EXPR=extension,
    pdf=readPdf(filepath),
    txt=readTxt(filepath),
    xls=readXlsx(filepath),
    xlsx=readXlsx(filepath),
    csv=readCsv(filepath),
    html=readHtml(filepath),
    htm=readHtml(filepath),
    body=readTxt(filepath)
  )

  return(chr)

}

# parse character strings-------------------------------------------------------
parseSwitch <- function(chr,parse_level,line_split='(\\r|\\n)+',bound_split='\\s+') {

  # parse attachment data-------------------------------------------------------
  dt <- switch(
    EXPR=parse_level,
    page=parseDataPages(chr),
    line=parseDataLines(chr,line_split),
    bound=parseDataBoundaries(chr,line_split,bound_split)
  )

  return(dt)

}
