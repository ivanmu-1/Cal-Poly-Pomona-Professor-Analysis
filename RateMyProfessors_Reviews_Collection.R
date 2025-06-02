library(tidyverse)
library(RSelenium)
library(dplyr)

## Create Selenium Driver object
## make sure chromedriver matches current chrome version, 
## search chrome://version/ to check current chrome version
## download latest chromedriver here: https://googlechromelabs.github.io/chrome-for-testing/ 
rs_driver_object <- rsDriver(browser = "chrome", chromever = "134.0.6998.165") #the latest version should go here
remDr <- rs_driver_object$client

##open chromebrowser
remDr$open()

##navigate to Cal Poly Pomona rate my professors, professors page
remDr$navigate("https://www.ratemyprofessors.com/search/professors/13914?q=*") 




# initialize empty dataframe
all_reviews <- data.frame(Professor_ID = NA,
                          Professor_Name = NA,
                          University = NA,
                          Department = NA,
                          Quality = NA,
                          Difficulty = NA,
                          Class_Name = NA, 
                          Comment = NA, Thumbs_Up = NA,
                          Thumbs_Down = NA,
                          Review_Date = NA)


#function that will be used later on
collect_review <- function(rating) { 
  
  quality <- rating$findChildElement(using = "xpath", "(.//div[starts-with(@class, 'CardNumRating')])[3]")$getElementText() %>% 
    unlist() %>% 
    as.numeric()
  
  difficulty <- rating$findChildElement(using = "xpath", "(.//div[starts-with(@class, 'CardNumRating')])[6]")$getElementText() %>%
    unlist() %>%
    as.numeric()
  
  class_name <- rating$findChildElement(using = "xpath", "(.//div[starts-with(@class,'RatingHeader__StyledClass')])[2]")$getElementText() %>% 
    unlist()
  
  comment <- rating$findChildElement(using = "xpath", ".//div[starts-with(@class, 'Comments__StyledComments')]")$getElementText() %>% 
    unlist()
  
  thumbs_up <- rating$findChildElement(using = "xpath", "(.//div[starts-with(@class, 'Thumbs__HelpTotal')])[1]")$getElementText() %>% 
    unlist() %>% 
    as.numeric()
  
  thumbs_down <- rating$findChildElement(using = "xpath", "(.//div[starts-with(@class, 'Thumbs__HelpTotal')])[2]")$getElementText() %>% 
    unlist() %>% 
    as.numeric()
  
  review_date <- rating$findChildElement(using = "xpath", "(.//div[starts-with(@class, 'TimeStamp')])[2]")$getElementText() %>% 
    unlist()
  
  return(list(Professor_ID = professor_id,
              Professor_Name = professor_name, 
              University = university, 
              Department = department,
              Quality = quality, 
              Difficulty = difficulty, 
              Class_Name = class_name, 
              Comment = comment, 
              Thumbs_Up = thumbs_up,
              Thumbs_Down = thumbs_down, 
              Review_Date = review_date)) 
}

## Apply function to all reviews and append to *all_reviews* dataframe
# run the function on all reviews 
reviews <- rating_body %>% map_dfr(~collect_review(.))

# append the reviews to the main dataframe 
all_reviews <- bind_rows(all_reviews, reviews)




## Clicks the "Load More" button to show all reviews and professors
## Edit for (t in 1:160) when needing to change amounts of time "Load More" is clicked
for (t in 1:160) {
  show_more <- remDr$findElement(using = "xpath", "//button[text()='Show More']")
  y_position <- show_more$getElementLocation()$y - 300
  remDr$executeScript(sprintf("window.scrollTo(0, %f)", y_position))  
  show_more$clickElement()
  Sys.sleep(2) 
}



# locates all teacher cards displayed
teacher_cards <- remDr$findElements(using = "xpath", "//a[starts-with(@class, 'TeacherCard__StyledTeacherCard')]")

# extracts urls from teacher cards. We will need these URLs to loop over the data.
teacher_urls <- map(teacher_cards, ~.$getElementAttribute("href") %>% unlist())




## The main loop which loops through the professors and collects all their reviews
for (t_url in teacher_urls) {
  
  # navigate to professor's page
  remDr$navigate(t_url)
  
  # a check for skipping over professors with no ratings
  rating_check <- remDr$findElement(using = "xpath", "//div[starts-with(@class,'RatingValue__NumRatings')]")$getElementText() %>% 
    unlist()
  if (rating_check == "No ratings yet. Add a rating.") { next }
  
  #get teacher ID 
  professor_id <- remDr$getCurrentUrl() %>% 
    unlist() %>% 
    str_extract("[:digit:]+$")
  
  # find teacher name 
  professor_name <- remDr$findElement(using = "xpath", "//div[starts-with(@class, 'NameTitle__Name')]")$getElementText() %>% 
    unlist()
  
  # department 
  department <- remDr$findElement(using = "xpath", "//div[starts-with(@class, 'NameTitle__Title')]//span//b")$getElementText() %>% 
    unlist()
  
  # university 
  university <- remDr$findElement(using = "xpath", "//div[starts-with(@class, 'NameTitle__Title')]//a")$getElementText() %>%
    unlist()
  
  # find number of ratings 
  num_of_ratings <- remDr$findElement(using = 'xpath', "//a[@href='#ratingsList']")$getElementText() %>% 
    unlist() %>% 
    str_extract("[:digit:]+") %>% 
    as.numeric()
  
  # determine how many times to click the "Load More Ratings" button
  num_of_iterations <- ceiling((num_of_ratings - 20) / 10)
  
  if (num_of_iterations >= 1) { 
    for (i in 1:num_of_iterations) {
      # click to load more ratings
      load_more <- remDr$findElement(using = "xpath", "//button[text()='Load More Ratings']")
      
      y_position <- load_more$getElementLocation()$y - 300 # determine y position of element - 100
      remDr$executeScript(sprintf("window.scrollTo(0, %f)", y_position)) # scroll to the element
      load_more$clickElement() # click the element
      Sys.sleep(1) # pause code for one second
    }
  }
  
  # locate the rating body 
  rating_body <- remDr$findElements(using = 'xpath', "//div[starts-with( @class, 'Rating__RatingBody')]")
  
  # run the function on all reviews 
  reviews <- rating_body %>% map_dfr(~collect_review(.))
  
  # append the reviews to the main dataframe 
  all_reviews <- bind_rows(all_reviews, reviews)
  
  # five second pause before it moves to the next professor 
  Sys.sleep(4.5)
}




# use to restart loop at a certain index incase of error
## can edit to for example 102:104 to start and stop at a certain index
for (t_url in teacher_urls[102:length(teacher_urls)]) {
  
  # navigate to professor's page
  remDr$navigate(t_url)
  
  # a check for skipping over professors with no ratings
  rating_check <- remDr$findElement(using = "xpath", "//div[starts-with(@class,'RatingValue__NumRatings')]")$getElementText() %>% 
    unlist()
  if (rating_check == "No ratings yet. Add a rating.") { next }
  
  # get teacher ID 
  professor_id <- remDr$getCurrentUrl() %>% 
    unlist() %>% 
    str_extract("[:digit:]+$")
  
  # find teacher name 
  professor_name <- remDr$findElement(using = "xpath", "//div[starts-with(@class, 'NameTitle__Name')]")$getElementText() %>% 
    unlist()
  
  # department 
  department <- remDr$findElement(using = "xpath", "//div[starts-with(@class, 'NameTitle__Title')]//span//b")$getElementText() %>% 
    unlist()
  
  # university 
  university <- remDr$findElement(using = "xpath", "//div[starts-with(@class, 'NameTitle__Title')]//a")$getElementText() %>%
    unlist()
  
  # find number of ratings 
  num_of_ratings <- remDr$findElement(using = 'xpath', "//a[@href='#ratingsList']")$getElementText() %>% 
    unlist() %>% 
    str_extract("[:digit:]+") %>% 
    as.numeric()
  
  # determine how many times to click the "Load More Ratings" button
  num_of_iterations <- ceiling((num_of_ratings - 20) / 10)
  
  if (num_of_iterations >= 1) { 
    for (i in 1:num_of_iterations) {
      # click to load more ratings
      load_more <- remDr$findElement(using = "xpath", "//button[text()='Load More Ratings']")
      
      y_position <- load_more$getElementLocation()$y - 300 # determine y position of element - 100
      remDr$executeScript(sprintf("window.scrollTo(0, %f)", y_position)) # scroll to the element
      load_more$clickElement() # click the element
      Sys.sleep(1) # pause code for one second
    }
  }
  
  # locate the rating body 
  rating_body <- remDr$findElements(using = 'xpath', "//div[starts-with( @class, 'Rating__RatingBody')]")
  
  # run the function on all reviews 
  reviews <- rating_body %>% map_dfr(~collect_review(.))
  
  # append the reviews to the main dataframe 
  all_reviews <- bind_rows(all_reviews, reviews)
  
  # five second pause before it moves to the next professor 
  Sys.sleep(5)
}

## use to delete a certain row/rows
all_reviews <- all_reviews[-c(33164:33176), ]

## export to excel
write_csv(all_reviews, "Rate_My_Professors_Reviews.csv")


## use to double check if amount of professors in data match amount listed in ratemyprofessors website
Unique_Professor_IDs <- all_reviews %>%
  select(Professor_ID) %>%
  distinct()


# incase you have to insert custom urls
new_urls <- c(
  "https://www.ratemyprofessors.com/professor/2555864",
  "https://www.ratemyprofessors.com/professor/1106034"
)

# Iterate over the custom list of URLs
for (t_url in new_urls) {
  
  # navigate to professor's page
  remDr$navigate(t_url)
  
  # a check for skipping over professors with no ratings
  rating_check <- remDr$findElement(using = "xpath", "//div[starts-with(@class,'RatingValue__NumRatings')]")$getElementText() %>% 
    unlist()
  if (rating_check == "No ratings yet. Add a rating.") { next }
  
  # get teacher ID 
  professor_id <- remDr$getCurrentUrl() %>% 
    unlist() %>% 
    str_extract("[:digit:]+$")
  
  # find teacher name 
  professor_name <- remDr$findElement(using = "xpath", "//div[starts-with(@class, 'NameTitle__Name')]")$getElementText() %>% 
    unlist()
  
  # department 
  department <- remDr$findElement(using = "xpath", "//div[starts-with(@class, 'NameTitle__Title')]//span//b")$getElementText() %>% 
    unlist()
  
  # university 
  university <- remDr$findElement(using = "xpath", "//div[starts-with(@class, 'NameTitle__Title')]//a")$getElementText() %>%
    unlist()
  
  # find number of ratings 
  num_of_ratings <- remDr$findElement(using = 'xpath', "//a[@href='#ratingsList']")$getElementText() %>% 
    unlist() %>% 
    str_extract("[:digit:]+") %>% 
    as.numeric()
  
  # determine how many times to click the "Load More Ratings" button
  num_of_iterations <- ceiling((num_of_ratings - 20) / 10)
  
  if (num_of_iterations >= 1) { 
    for (i in 1:num_of_iterations) {
      # click to load more ratings
      load_more <- remDr$findElement(using = "xpath", "//button[text()='Load More Ratings']")
      
      y_position <- load_more$getElementLocation()$y - 300 # determine y position of element - 100
      remDr$executeScript(sprintf("window.scrollTo(0, %f)", y_position)) # scroll to the element
      load_more$clickElement() # click the element
      Sys.sleep(1) # pause code for one second
    }
  }
  
  # locate the rating body 
  rating_body <- remDr$findElements(using = 'xpath', "//div[starts-with( @class, 'Rating__RatingBody')]")
  
  # run the function on all reviews 
  reviews <- rating_body %>% map_dfr(~collect_review(.))
  
  # append the reviews to the main dataframe 
  all_reviews <- bind_rows(all_reviews, reviews)
  
  # five second pause before it moves to the next professor 
  Sys.sleep(4.5)
}

#checking if nas
any(is.na(all_reviews))
#how many
sum(is.na(all_reviews))
#where
which(apply(all_reviews, 1, function(x) any(is.na(x))))
