collection <- function(xpaths, driver){
  # We scrape tab by tab
  # In each tab, we scrape each breed
  # Within each breed, we scrape each year for which there is data
  # Within each year, we scrape every page of data
  # Each of these tasks are represented by a for loop


  # The list containing the results
  all_data <- list()

  for(tab in xpaths[["tabnames"]]){
    click_element_on_page(xpath_value = tab)

    # Determines which xpath to use for the years--we want to use different UI elements for the years in 'Horses - By Foaling Year'
    xpaths[["relevant_years"]] <- determine_relevant_year(tab_xpath = tab, xpaths_list = xpaths)

    for(breed in xpaths[["horse_breeds"]]){
      click_element_on_page(xpath_value = breed)

      for(year in xpaths[["relevant_years"]]){
        click_element_on_page(xpath_value = year)



        # Get the HTML source code from the browser
        html <- driver$getPageSource()[[1]]



        # Finds the number of pages in the table
        numpages <- get_numpages(html = html)
        for(pagenum in 1:numpages){
          # Extracts the table containing data, stores it in a tibble, then adds the year and breed
          incoming_data <- get_table(html = html)
          incoming_data$breed <- determine_breed(breed_xpath = breed)[[1]]
          incoming_data$year <- determine_year(year_xpath = year)[[1]]


          # Not the fastest implementation, but it decides whether to append rows or create a new data frame
          horse_data <- append_data(pagenum = pagenum, incoming_data = incoming_data)


          # Moves to the next page (the next set of 100); 'clicks' on the next arrow in the browser
          driver$findElements(using = "xpath", "//*[@id=\"Pagination\"]/ul/a[8]")[[1]]$clickElement()


          # Wait for a few seconds before continuing
          sleep()


          message("Data for page ", pagenum, " of ", numpages, " added.\n", sep = "")

        }#end of 'pagenum' for loop


        message("\nData for ", determine_year(year_xpath = year), " added.\n", sep = "")

      }#end of 'year' for loop


      message("\n\n", str_to_title(determine_breed(breed_xpath = breed)), " data complete.\n\n", sep = "")

    }#end of 'breed' for loop


    # Writing the data to a csv file--it should contain data for all pages, the year, and breed
    # This setup writes to a csv after extracting all the tab's data
    write_csv(x = horse_data,
              file = str_c("datasets/", determine_tabname(tab_xpath = tab), " ", Sys.Date(), ".csv", collapse = ""),
              append = FALSE,
              col_names = TRUE)


    message("\n\n\n", determine_tabname(tab_xpath = tab), " Tab Complete.\n\n\n", sep = "")

  }#end of 'tab' for loop
  return(all_data)
}#end of collection()
