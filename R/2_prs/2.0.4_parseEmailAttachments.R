# parse attachments into table--------------------------------------------------
parseFile <- function(a,parse_level,parse_pars) {

  tryCatch({

    # validate oversized files--------------------------------------------------
    if (file.size(a$filepath)>15000000) {

      # size constraint---------------------------------------------------------
      dt <- data.table(
        text='<oversize>',
        entryid=a$entryid,
        attachment=a$attachment,
        extension=a$extension
      )

      return(dt)

    }

    # read target file types----------------------------------------------------
    chr <- readSwitch(a$filepath,a$extension)

    # apply sequential preprocessing string replacements------------------------
    if (length(parse_pars$pre_process)>0) {

      for (i in 1:length(parse_pars$pre_process)) {

        p <- parse_pars$pre_process[[i]]

        chr <- gsub(p$pattern,p$replacement,chr,perl=p$perl)

      }

    }

    # parse character strings---------------------------------------------------
    dt <- parseSwitch(chr,parse_level,parse_pars$line_split,parse_pars$bound_split)

    # attachment metadata-------------------------------------------------------
    dt[,`:=` (
      entryid=a$entryid,
      attachment=a$attachment,
      extension=a$extension
    )]

  },error=function(e) {

    # read error----------------------------------------------------------------
    data.table(
      text='<error>',
      entryid=a$entryid,
      attachment=a$attachment,
      extension=a$extension
    )

  })

}
