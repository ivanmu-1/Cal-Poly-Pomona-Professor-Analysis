# Cal Poly Pomona Professor Analysis
This project focuses on showcasing our skills in collecting, cleaning, and analyzing professor reviews for Cal Poly Pomona, sourced from [RateMyProfessors.com](https://www.ratemyprofessors.com/school/13914). The review and professor data have been successfully collected, cleaned, and analyzed. The project is currently in its final stages as we work on wrapping up the remaining tasks and conduct experiments with Supervised Topic Modeling in RStudio.

#### This Project was done as a joint collaboration between:  
- [Rodrigo Isidro](https://github.com/Rodgeroger) 
- [Ivan Mu](https://github.com/ivanmu-1)

## Project Structure

The project is organized around two primary tables:

### Professors Table

This table will store the following data for each professor:

* ```Professor_ID```: Unique identifier for each professor.
* ```Professor_Name```: Full name of the Professor.
* ```Department```: The department the professor belongs to
* ```Total_Reviews```: Total number of reviews the professor has received.
* ```Avg_Rating```: The average quality rating given to the professor (1.0-5.0).
* ```Would_Take_Again```: The percentage of students who would take the professor again.
* ```Avg_Difficulty```: The average difficulty rating of the professor’s courses (1.0-5.0).

### Reviews Table

This table stores individual reviews, linked to each professor by the foreign key, ```Professor_ID```:

* ```Professor_ID```: Unique identifier for each professor.
* ```Professor_Name```: Full name of the Professor.
* ```Class_Name```: Class name for class student is reviewing
* ```Department```: The department the professor belongs to
* ```Quality```: The quality rating given by the student (1-5).
* ```Difficulty```: The difficulty rating given by the student (1-5).
* ```Comment```: The student's written feedback.
* ```Thumbs_Up```: The number of thumbs-up votes the review received.
* ```Thumbs_Down```: The number of thumbs-down votes the review received.
* ```Review_Date```: The date the review was posted on.

### Tools Used

* RStudio
  - RSelenium
  - Tidyverse
  - dplyr
* Microsoft SQL Server
* Excel
* Instant Data Scrapper
* Jupyter Notebook
* Pandas
* Mathplotlib
* Seaborn

### Data Collection

Data collection was conducted using two primary tools. The [Instant Data Scrapper](https://chromewebstore.google.com/detail/instant-data-scraper/ofaokhiedipichpaobibbnahnkdoiiah?hl=en-US) Chrome extension was utilized to extract data for the professors table, while RStudio was used to collect and process the reviews table. Data gathering and manipulation were performed using the RSelenium and Tidyverse packages. R was used to scrape data from RateMyProfessors.com by automating a web browser with RSelenium. It started by launching a Selenium server to control a web browser from R. It then navigated to the site, interacted with the page to load all the content, and then collected the HTML source. Using R packages, It extracted key information about professors and organized it into a structured format. Finally, It saved the data in a CSV file for further analysis. The script automates the entire process, making it easy to collect large amounts of information from the site. The R code implemented in this project was originally developed by [Samer Hijjazi](https://github.com/ggSamoora) with minor modifications done by us to suit our needs. The original script can be accessed [here](https://github.com/ggSamoora/TutorialsBySamoora/blob/3cacfc7b902e8c81dd628789dc7a1100c6eb16c8/rate_my_professor_script.Rmd). His Youtube [video](https://youtu.be/GnpJujF9dBw?si=khNkvGcjxOh9AwGQ) on setting up RSelenium and his [video](https://youtu.be/mWUOdV2nMOk?si=KhwTLVmnJaj4qtVP) on his Ratemyprofessor project were especially valuable, as was his entire [Youtube channel](https://www.youtube.com/@SamerHijjazi/featured). ZeeCoding’s [tutorial](https://www.youtube.com/watch?v=Bpd04FH9ycs&ab_channel=ZeeCoding) also was instrumental in resolving Chromedriver-related issues

### Data Cleaning

Data cleaning was primarily done using Pandas, with the goal of standardizing and cleaning the data extracted from the Instant Data Scraper. This involved two CSV files: the first containing general professor information from RateMyProfessor, and the second containing in-depth comments and the overall sentiment of each individual review. The cleaning process followed a basic data cleaning structure of loading the data, inspecting it, standardizing formats, handling missing values, removing duplicates, ensuring correct data types, and addressing outliers. After cleaning, the data was saved into new, cleaned CSV files. This step represents the 'Transform' stage of the ETL process. All cleaning procedures were applied to both datasets and are documented in the accompanying Jupyter notebook files. 
- [General RatemyProfessor data-cleaning script](notebooks/RatemyProfessor.ipynb)
- [Reviews data-cleaning script](notebooks/Reviews.ipynb)

### Exploratory Data Analysis (EDA)

Basic EDA was performed in our General RateMyProfessor Jupyter notebooks to explore underlying trends and patterns in the data. Matplotlib and Seaborn were used for data visualization, while basic exploratory analysis was carried out using Pandas. However, more detailed pattern-based EDA was conducted within our SQL script, where we attempted to explore whether professors described as 'helpful' or 'clear' tend to receive higher ratings, and whether negative descriptors like 'unclear' or 'unhelpful' correlate with lower ratings. We also analyzed the relationship between the number of courses a professor teaches and their average rating, investigated rating trends over time (particularly for newer vs. longer-tenured professors), examined department-level performance, and explored the language used in highly positive vs. negative reviews to identify frequently used words and their connection to quality and difficulty ratings

### Data Analysis Observations 

Data Analysis was primarily done using SQL, Pandas, Seaborn, Matplotlib.

Observations:

  - Clear positive shew - Professors have an high amount of 5's.
  - Majority of Professors have rating between 3 and 5
  - As Avg_Difficulty increase, Avg_Rating begins to drop
  - A lower Avg_Difficulty correlates to an higher Avg_Rating score
  - "Excellent" Rating are most common among Professors, while "Hard" Difficulty has the fewest professors
  - "Moderate" and "Challenging" difficulty contains the widest spread across all rating categories
  - "Moderate" and "Excellent" contains the highest count

Takeaway:

  - The majority of professors at Cal Poly Pomona tend to receive high ratings, indicating generally positive student feedback across the board.
  - Easier Professor tend to be rated more favorably, suggesting that student satisfaction is directly influenced by difficulty.
  - Moderate difficulty seems to be the sweet spot, balancing student satisfaction with academic rigor.
  - Professors who are perceived as very hard struggle to earn high ratings, possibly due to workload or grading policies.
  - Easier classes often correlate with higher ratings, but not exclusively; students still value teaching quality, not just ease
