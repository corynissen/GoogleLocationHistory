
#' Login to Google
#'
#' Login to Google
#' @param username Your Google account username or email address
#' @param password Your Google account password
#' @keywords login
#' @export
#' @return An rvest session
#' @examples
#' \dontrun{
#' sess <- login(username="corynissen@gmail.com", password="my_google_password")
#' }
#' login
login <- function(username, password){
  if(!is.character(username)){stop("username must be a character string")}
  if(!is.character(password)){stop("password must be a character string")}

  url <- "https://maps.google.com/locationhistory/b/0"
  s <- rvest::html_session(url)
  f1 <- rvest::html_form(s)[[1]]
  filled_f1 <- rvest::set_values(f1, Email=username)
  s <- rvest::submit_form(s, filled_f1, submit="signIn")
  if(s$response$status_code != 200){
    stop("Login Failed")
  }
  f2 <- rvest::html_form(s)[[1]]
  filled_f2 <- rvest::set_values(f2, "Passwd"=password)
  s <- suppressWarnings(rvest::submit_form(s, filled_f2, submit="signIn"))
  if(s$response$status_code != 411){
    stop("Login Failed")
  }
  s <- rvest::jump_to(s, s$response$url)
  f3 <- rvest::html_form(s)[[3]]
  pin <- readline(prompt="Enter the 6 digit Google PIN that was texted to you:  ")
  filled_f3 <- rvest::set_values(f3, "Pin"=pin)
  s <- suppressWarnings(rvest::submit_form(s, filled_f3, submit="NULL"))
  if(s$response$status_code != 411 | grepl("signin/challenge", s$url)){
    stop("Login Failed")
  }
  if(grepl("authuser%3D0", s$url)){
    message("Login successful")
  }

  return(s)
}

