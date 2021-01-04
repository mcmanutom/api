#install.packages("jsonlite, httr")
#install.packages("httpuv")
#install.packages("plotly")
library(jsonlite)
library(httr)
library(httpuv)
require(devtools)

oauth_endpoints("github")

#details
x = oauth_app(appname = "mcmanus_tom", key = "c029fe9909c264561f0a", secret = "2a11e9ca27d7154b40cac4e5de6cda247ad2a849")

#OAuth credentials
github_token = oauth2.0_token(oauth_endpoints("github"), x)

#API
gtoken = config(token = github_token)
req = GET("https://api.github.com/users/jtleek/repos", gtoken)

#Error check
stop_for_status(req)

#Extract content
json1 = content(req)

#Convert to data frame and subset
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))
gitDF[gitDF$full_name == "jtleek/datasharing", "created_at"]

#sourced until here from from https://towardsdatascience.com/accessing-data-from-github-api-using-r-3633fb62cb08

#Interogates github api for my account
myData = fromJSON("https://api.github.com/users/mcmautom")

#Dispaly some data
myData$followers 
followers = fromJSON("https://api.github.com/users/mcmanutom/followers")
followers$login
myData$public_repos #displays the number of repositories I have

#Visualizing the data - using another github with more data in it. - Andrew Nesbitt (andrew) second most active github user

myData = GET("https://api.github.com/users/andrew/followers?per_page=100;", gtoken)
stop_for_status(myData)
extract = content(myData)
#converts into dataframe
githubDB = jsonlite::fromJSON(jsonlite::toJSON(extract))
githubDB$login

id = githubDB$login
ids_list = c(id)

#vector and data.frame
users = c()
usersDB = data.frame(
  username = integer(),
  following = integer(),
  followers = integer(),
  repos = integer()
)

for(i in 1:length(ids_list))
{
  
  dataURL = paste("https://api.github.com/users/", ids_list[i], "/following", sep = "")
  dataRequest = GET(dataURL, gtoken)
  dataContent = content(dataRequest)
  
  dataDF = jsonlite::fromJSON(jsonlite::toJSON(dataContent))
  dataLogin = dataDF$login
  
  for (j in 1:length(dataLogin))
  {
      #Add user to list
      users[length(users) + 1] = dataLogin[j]
      
      userURL = paste("https://api.github.com/users/", dataLogin[j], sep = "")
      userGet = GET(userURL, gtoken)
      userContent = content(userGet)
      userDF = jsonlite::fromJSON(jsonlite::toJSON(userContent))
      
      #Following and followers numbers
      followingNumber = userDF$following
      followersNumber = userDF$followers
      
      #Add users data to dataframe
      usersDB[nrow(usersDB) + 1, ] = c(followingLogin[j], followingNumber, followersNumber)
      
    }
}

#Graphing
#install.packages("plotly")
library(plotly)
Sys.setenv("plotly_username"="mcmanutom")
Sys.setenv("plotly_api_key"="Pnx0pYFhvcdySQuV01Xo")

#Following vs followers - It shows relationship between number of followers and following - majority were clustered at a low number of each but it apperared those with lots of followers didnt follow many and those who followed lots had few followers
plot = plot_ly(data = usersDB, x = ~following, y = ~followers, text = ~paste("Followers: ", followers, "<br>Following: ", following))
plot

#send to plotly
api_create(plot, filename = "Following vs Followers")
