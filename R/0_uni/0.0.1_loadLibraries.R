# package installation and load function----------------------------------------
loadLibraries <- function() {

  # package list for outlook model----------------------------------------------
  pkgs <- list(

    list(
      package='devtools',
      install=quote(install.packages('devtools'))
    ),

    list(
      package='RDCOMClient',
      install=quote(install_github('markrazmandi/RDCOMClient'))
    ),

    list(
      package='data.table',
      install=quote(install.packages('data.table'))
    ),

    list(
      package='magrittr',
      install=quote(install.packages('magrittr'))
    ),

    list(
      package='parallel',
      install=quote(install.packages('parallel'))
    ),

    list(
      package='pdftools',
      install=quote(install.packages('pdftools'))
    ),

    list(
      package='readxl',
      install=quote(install.packages('readxl'))
    ),

    list(
      package='openxlsx',
      install=quote(install.packages('openxlsx'))
    ),

    list(
      package='rvest',
      install=quote(install.packages('rvest'))
    ),

    list(
      package='stringi',
      install=quote(install.packages('stringi'))
    ),

    list(
      package='parsedate',
      install=quote(install.packages('parsedate'))
    ),

    list(
      package='anytime',
      install=quote(install.packages('anytime'))
    ),

    list(
      package='caTools',
      install=quote(install.packages('caTools'))
    ),

    list(
      package='ranger',
      install=quote(install.packages('ranger'))
    ),

    list(
      package='stringdist',
      install=quote(install.packages('stringdist'))
    ),

    list(
      package='RODBC',
      install=quote(install.packages('RODBC'))
    ),

    list(
      package='R.utils',
      install=quote(install.packages('R.utils'))
    )

    # list(
    #   package='msgxtractr',
    #   install=quote(install_github('markrazmandi/msgxtractr'))
    # )

  )

  # test for installation and load packages-------------------------------------
  invisible(lapply(pkgs,function(j) {

    if (!(j$package %in% installed.packages())) {

      eval(j$install)

      cat(j$package,'install - COMPLETE',fill=TRUE)

    }

    x <- library(j$package,character.only=TRUE,logical.return=TRUE)

    cat(j$package,'load -',x,fill=TRUE)

  }))

}
