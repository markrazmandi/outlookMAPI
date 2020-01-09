# extract folder properties into table record-----------------------------------
folderProperties <- function(com,emails,restricteddate) {

  folderpath <- as.character(tryCatch(
    com$FolderPath(),
    error=function(e) NA))

  foldername <- as.character(tryCatch(
    com$Name(),
    error=function(e) NA))

  folders <- as.integer(tryCatch(
    com$Folders()$Count(),
    error=function(e) 0L))

  totalitems <- as.integer(tryCatch(
    com$Items()$Count(),
    error=function(e) 0L))

  restricteddate <- maxDate(emails,folderpath,restricteddate)

  restricteditems <- as.integer(tryCatch(
    com$Items()$Restrict(
      paste0("[Created] > '",restricteddate,"'")
    )$Count(),
    error=function(e) 0L))

  dt <- data.table(
    folderpath=folderpath,
    foldername=foldername,
    folders=folders,
    totalitems=totalitems,
    restricteditems=restricteditems,
    restricteddate=restricteddate,
    frun=0L,
    irun=0L
  )

  return(dt)

}

# extract email properties into table record------------------------------------
emailProperties <- function(outlook,com) {

  # email metadata--------------------------------------------------------------
  folderpath <- outlook$folderpath

  entryid <- as.character(tryCatch(
    com$EntryID(),
    error=function(e) NA_character_))

  creationtime <- as.comDateTime(tryCatch(
    com$CreationTime(),
    error=function(e) NA))

  receivedtime <- as.comDateTime(tryCatch(
    com$ReceivedTime(),
    error=function(e) NA))

  senderemail <- as.character(tryCatch(
    com$SenderEmailAddress(),
    error=function(e) NA_character_))

  sendername <- as.character(tryCatch(
    com$SenderName(),
    error=function(e) NA_character_))

  subject <- as.character(tryCatch(
    com$Subject(),
    error=function(e) NA_character_))

  body <- as.character(tryCatch(
    com$Body(),
    error=function(e) NA_character_))

  attachments <- as.integer(tryCatch(
    com$Attachments()$Count(),
    error=function(e) NA_integer_))

  # email item metadata---------------------------------------------------------
  email_item <- data.table(
    folderpath=folderpath,
    entryid=entryid,
    attachment=0L,
    creationtime=creationtime,
    receivedtime=receivedtime,
    senderemail=senderemail,
    sendername=sendername,
    subject=subject,
    attachmenttype=999,
    extension='body',
    storepath=paste0(entryid,'.body'),
    write=NA_integer_,
    crun=0L
  )

  # save email item-------------------------------------------------------------
  tryCatch({
    # com$SaveAs(paste0(accountDirectory(outlook,'msg'),email_item$storepath))
    writeLines(body,paste0(accountDirectory(outlook,'body'),email_item$storepath))
    email_item[,write := 1L]
  },error=function(e) {
    email_item[,write := 2L]
  })

  # process attachments---------------------------------------------------------
  if (attachments>0) {

    attachment_items <- lapply(seq_len(attachments),function(j) {

      # attachment type property------------------------------------------------
      property <- 'http://schemas.microsoft.com/mapi/proptag/0x37140003'

      # attachment metadata-----------------------------------------------------
      attachmenttype <- as.integer(tryCatch(
        com$Attachments(j)$PropertyAccessor()$GetProperty(property),
        error=function(e) NA_integer_))

      filename <- as.character(tryCatch(
        com$Attachments(j)$FileName(),
        error=function(e) NA_character_))

      # attachment item metadata------------------------------------------------
      dt <- data.table(
        folderpath=folderpath,
        entryid=entryid,
        attachment=j,
        creationtime=creationtime,
        receivedtime=receivedtime,
        senderemail=senderemail,
        sendername=sendername,
        subject=subject,
        attachmenttype=attachmenttype,
        extension=NA_character_,
        storepath=NA_character_,
        write=NA_integer_,
        crun=0L
      )

      # parse extensions--------------------------------------------------------
      dt[,extension := sub('.*\\.(.*)$','\\L\\1',filename,perl=TRUE)] %>%
        .[is.na(extension) | nchar(extension)>4,extension := 'oth']

      # only download non-embedded images---------------------------------------
      if (dt$attachmenttype!=4) {

        # normailize file paths for data store----------------------------------
        dt[!is.na(filename),storepath := normalizePath(
          creationtime,
          filename,
          extension
        )]

        # parse attachment filepath---------------------------------------------
        path <- accountDirectory(outlook,dt$extension) %>%
          paste0(dt$storepath)

        # save attachment object------------------------------------------------
        tryCatch({
          com$Attachments(j)$SaveAsFile(path)
          dt[,write := 1L]
        },error=function(e) {
          dt[,write := 2L]
        })

      } else {

        dt[,write := 0L]

      }

      return(dt)

    }) %>% rbindlist(fill=TRUE)

  } else {

    attachment_items <- data.table()

  }

  dt <- rbindlist(list(email_item,attachment_items),fill=TRUE)

  return(dt)

}
