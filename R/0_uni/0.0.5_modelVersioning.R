# version files application development---------------------------------------
versionDevelopment <- function(all_file_dirs,name) {

  # base model directory------------------------------------------------------
  basedir <- 'C:/Users/razmandi/Desktop/r'
  setwd(paste0(basedir,'/exchangeMapi'))

  # directories to take all files---------------------------------------------
  all_files_paths <- list.files(all_file_dirs,full.names=TRUE)

  # latest version number-----------------------------------------------------
  devdir <- paste0(basedir,'/exchangeMapi/dev')

  dir.create(devdir,showWarnings=FALSE,recursive=TRUE)

  version <- list.files(devdir) %>%
    grep(name,.,value=TRUE) %>%
    sub(paste0(name,'(.*)\\.zip'),'\\1',.) %>%
    as.integer() %>% max() %>% +1

  if (is.infinite(version)) {

    version <- 1

  }

  # version zip path----------------------------------------------------------
  version_path <- paste0(devdir,'/',name,version,'.zip')

  if (!file.exists(version_path)) {

    zip(version_path,all_files_paths)

  }

}
