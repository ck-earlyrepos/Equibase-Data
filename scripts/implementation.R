# Packages ---------------------------------------------------------------
if(!require(pacman)) install.pacakges("pacman")
pacman::p_load(RSelenium, rvest, dplyr, readr, stringr)



# Sourcing Files ---------------------------------------------------------
# This function was provided thanks to the wonderful people at ?source
sourceDir <- function(path, trace = TRUE, ...) {
  op <- options(); on.exit(options(op)) # to reset after each
  for (nm in list.files(path, pattern = "[.][RrSsQq]$")) {
    if(trace) cat(nm,":")
    source(file.path(path, nm), ...)
    if(trace) cat("\n")
    options(op)
  }
}

sourceDir(path = str_c(getwd(), "/scripts/collection", sep = ""))


# Implementation ---------------------------------------------------------
# Starting a browser
browser <- rsDriver(port = 4545L,
                    browser = "firefox",
                    version = "latest",
                    geckover = "latest",
                    verbose = FALSE)

# assigning the browser client to an object
remote_driver <- browser[["client"]]

# Navigate to webpage (the statistics tab)
url <- "https://www.equibase.com/stats/View.cfm?tf=year&tb=horse"
remote_driver$navigate(url)

# This is where the magic happens
collection(xpaths = xpaths, driver = remote_driver)
