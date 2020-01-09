# parse whole document data-----------------------------------------------------
parseDataPages <- function(chr) {

  data.table(
    page=seq_along(chr),
    text=chr
  )

}

# parse document line data------------------------------------------------------
parseDataLines <- function(chr,line_split) {

  # parse text string by lines--------------------------------------------------
  l <- strsplit(chr,line_split)

  # drop null elements----------------------------------------------------------
  l <- l[lapply(l,length)!=0]

  if (length(unlist(l))>0) {

    dt <- lapply(seq_along(l),function(p) {

      data.table(
        page=p,
        line=seq_along(l[[p]]),
        text=l[[p]]
      )

    }) %>% rbindlist(fill=TRUE)

  } else {

    dt <- data.table(
      page=0,
      line=0,
      text='<no text>'
    )

  }

  return(dt)

}

# parse document boundary data--------------------------------------------------
parseDataBoundaries <- function(chr,line_split,bound_split) {

  # parse text string by lines--------------------------------------------------
  l <- strsplit(chr,line_split)

  # drop null elements----------------------------------------------------------
  l <- l[lapply(l,length)!=0]

  if (length(l)>0) {

  dt <- lapply(seq_along(l),function(p) {

    lapply(seq_along(l[[p]]),function(b) {

      # split character string into boundaries by lines-------------------------
      w <- trimws(x=l[[p]][b],'both','[\\h\\v]') %>%
        strsplit(bound_split) %>%
        unlist()

      if (length(w)>0) {

        data.table(
          page=p,
          line=b,
          bound=seq_along(w),
          text=w
        )

      } else {

        data.table(
          page=p,
          line=b,
          bound=0,
          text='<no text>'
        )

      }

    }) %>% rbindlist(fill=TRUE)

  }) %>% rbindlist(fill=TRUE)

  } else {

    dt <- data.table(
      page=0,
      line=0,
      bound=0,
      text='<no text>'
    )

  }

  return(dt)

}
