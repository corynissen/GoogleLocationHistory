
#' Get location history
#'
#' After login, get location history for a specified date
#' @param session An rvest session returned from the login() function
#' @param date A date string in YYYY-MM-DD format
#' @param asKML TRUE if desired output is KML, FALSE if desired output is a dataframe of data parsed from the KML
#' @keywords login
#' @export
#' @return A dataframe of location data or raw KML text
#' @examples
#' \dontrun{
#' sess <- login(username="corynissen@gmail.com", password="my_google_password")
#' df <- location_history(session=sess, date="2016-04-04")
#' }
#' location_history
location_history <- function(session, date, asKML=FALSE){
  if(!"session" %in% class(session)){stop("session must be of class session")}
  if(!grepl("^\\d{4}-\\d{2}-\\d{2}$", date)){stop("date must be a date string in YYYY-MM-DD format")}

  year <- substring(date, 1, 4)
  month <- substring(date, 6, 7)
  day <- substring(date, 9, 10)
  monthm1 <- sprintf("%02d", as.numeric(month) -1)

  url <- paste0("https://www.google.com/maps/timeline/kml?authuser=0&pb=!1m8!1m3!1i",
                year, "!2i", monthm1, "!3i", day, "!2m3!1i", year, "!2i",
                monthm1, "!3i", day)
  s <- rvest::jump_to(session, url)
  kml <- httr::content(s$response, as="text")

  if(asKML) return(kml)

  kmll <- xml2::as_list(xml2::read_xml(kml))
  dat <- unlist(kmll$Document$Placemark$Track)
  df <- data.frame("when"=dat[names(dat)=="when"],
                   "coord"=dat[names(dat)=="coord"],
                   stringsAsFactors = FALSE)
  tmp <- strsplit(df$coord, " ")
  df$lon <- as.numeric(sapply(tmp, "[", 1))
  df$lat <- as.numeric(sapply(tmp, "[", 2))
  df$time <- as.POSIXct(substring(df$when, 1, 19), "%Y-%m-%dT%H:%M:%S",
                        tz="GMT")

  return(df)
}

