week_of_month <- function(df) {
  wom <- c()
  
  for (u in 1:nrow(df)) {
    curr_mo <- df$mo[u]
    curr_dt <-  df$date[u]
    temp_df <- df %>% filter(
      (mo == curr_mo) & (date <= curr_dt)
    )
    ones <- sum(temp_df$dow == 1)
    wom <- append(wom, ones)
  }
  
  return(wom)
}