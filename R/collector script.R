######################################################################################
columns_to_collect<-c("Time ","Last Trade (Price Only)","Bid","Ask","Days Low","Days High","52-week Low","52-week High")

######################################################################################
# function to fetch data
fetch<-function(currency="EURUSD=X"){
  Year <- 1970
  currentYear <- as.numeric(format(Sys.time(),'%Y'))
  while (Year != currentYear) { #Sometimes yahoo returns bad quotes
    currentQuote <- getQuote(currency,
                             what=yahooQF(columns_to_collect))
    Year <- as.numeric(format(currentQuote['Trade Time'],'%Y'))
  }
  currentQuote
}


######################################################################################
# initialize new currencies

news<-setdiff(currency,dbListTables(my_db))

if(length(news)>0){
for(i in 1:length(news)){
  copy_to(dest=my_db,df=data_frame()%>%
            bind_rows(fetch(paste(news[i],"=X",sep="")))%>%
            mutate(`Trade Time`=as.character(`Trade Time`)),
          name=paste(news[i]), temporary = FALSE)
}
}
# reset local tables

for(i in 1:length(currency)){
  assign(currency[i], data_frame())
}
######################################################################################
# fetch minute data

minute_prices = function(interval = 60) {
  for(i in 1:length(currency)){
    assign(currency[i],
           get(currency[i],env=.GlobalEnv)%>%
             bind_rows(fetch(paste(currency[i],"=X",sep=""))),
           env=.GlobalEnv)
  }
  later::later(minute_prices, interval)
}



######################################################################################
transfer_to_db = function(interval = 3600) {
for(i in 1:length(currency)){
  RSQLite::dbWriteTable(con = my_db,paste(currency[i]),get(currency[i],env=.GlobalEnv)%>%mutate(`Trade Time`=as.character(`Trade Time`))%>%distinct(),append = TRUE)
}
for(i in 1:length(currency)){
    assign(currency[i],data_frame(),
           env=.GlobalEnv)
}
  later::later(transfer_to_db, interval)
}
minute_prices()
transfer_to_db()


