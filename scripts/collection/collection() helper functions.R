# Contains the xpaths on the HTML file for different elements
xpaths <- list()
# The xpaths to select the tab name ('Horses - By Racing Year', 'Jockeys', 'Trainers', 'Owners', and 'Horses - By Foaling Year', respectively)
xpaths[["tabnames"]] <- paste0("//*[@id=\"c-stats-central\"]/div/ul/li[", 1:5, "]/a")
# The xpaths to select the horse breed ('thoroughbred' and 'quarter horse', respectively)
xpaths[["horse_breeds"]] <- paste0("//*[@id=\"raceBreedType\"]/option[", 1:2, "]")
# The xpaths to select the year (option 1 is the current year--the final number in the list will need to be incremented each year)
xpaths[["years"]] <- paste0("//*[@id=\"year\"]/option[", 1:22, "]")
# The xpaths to select the foaling year (option 1 is the current year--the final number in the list will need to be incremented each year)
xpaths[["foaling_years"]] <- paste0("//*[@id=\"foalYearList\"]/option[", 1:22, "]")


# Give the system time to load and lower burden on server
sleep <- function(){
  Sys.sleep(runif(n = 1, min = 10, max = 15))
}


# loads the element then sleeps for a few seconds seconds
click_element_on_page <- function(xpath_value){
  # Chooses the the element to click on
  remote_driver$findElements(using = "xpath", value = xpath_value)[[1]]$clickElement()

  sleep()
}


# Determines which xpaths to use for the year
determine_relevant_year <- function(tab_xpath, xpaths_list){
  if(tab_xpath == "//*[@id=\"c-stats-central\"]/div/ul/li[2]/a"){
    relevant_years <- xpaths_list[["foaling_years"]]
  }else {
    relevant_years <- xpaths_list[["years"]]
  }

  return(relevant_years)
}


# Finds the number of pages in the table (the number before the next arrow)
get_numpages <- function(html){
  read_html(html) %>%
    html_elements(xpath = "//*[@id=\"Pagination\"]/ul/a[7]") %>%
    html_text() %>%
    readr::parse_number() %>%
    return()
}


# Pull the table out of the HTML and store it in a tibble
get_table <- function(html){
  read_html(html) %>%                  # parse HTML
    html_elements(css = "#data") %>%
    .[[1]] %>%                         # keep the first element of the list returned by html_elements()
    html_table(fill = TRUE)            # have rvest turn it into a dataframe
}


# Determines which breed to return based on the xpath
determine_breed <- function(breed_xpath){
  return(if_else(breed_xpath == "//*[@id=\"raceBreedType\"]/option[1]", "thoroughbred", "quarter horse"))
}


# Determines which year to return based on the xpath
determine_year <- function(year_xpath){
  return(2000 + length(xpaths[["years"]]) - parse_number(year_xpath))
}


# Adds new data to the data frame
append_data <- function(pagenum, incoming_data){
  if(pagenum == 1){
    # If this is the first iteration of the loop, make the return dataset the same as the input
    horse_data <- incoming_data
  } else {
    # Otherwise, add new data to the existing tibble
    horse_data <- bind_rows(horse_data, incoming_data)
  }#end of conditional
}


# Determines which tab name to return based on the xpath
determine_tabname <- function(tab_xpath){
  case_when(
    tab_xpath == "//*[@id=\"c-stats-central\"]/div/ul/li[1]/a" ~ "Horses - By Racing Year",
    tab_xpath == "//*[@id=\"c-stats-central\"]/div/ul/li[2]/a" ~ "Horses - By Foaling Year",
    tab_xpath == "//*[@id=\"c-stats-central\"]/div/ul/li[3]/a" ~ "Jockeys",
    tab_xpath == "//*[@id=\"c-stats-central\"]/div/ul/li[4]/a" ~ "Trainers",
    tab_xpath == "//*[@id=\"c-stats-central\"]/div/ul/li[5]/a" ~ "Owners",
    TRUE ~ "unknown"
  ) %>%
    return()
}
