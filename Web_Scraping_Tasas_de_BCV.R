# Web Scraping BCV (Banco Central de Venezuela) - Tasas de Cambio - Del Día

library(httr) 
library(rvest)
library(openxlsx)

# get your current working directory

wd <- getwd()

# function to get "Tasas de compra-venta para Bancos"
get_tasas_compra_venta_bancos_bcv<- function(){
  
  # get the url of BCV
  url <- "https://www.bcv.org.ve/tasas-informativas-sistema-bancario"
  
  response <- GET(url)
  
  # Look the nodes until you find what you want
  
  root_node <- read_html(response)
  
  table_nodes <- html_nodes(root_node,"table")
  
  table <- html_table(table_nodes)
  
  # Get the table 
  
  tasas_sin_depurar <- table[1]
  
  # Create a Dataframe
  
  tasas_sin_depurar <- as.data.frame(tasas_sin_depurar)
  
  # Say where end the most recent "TASA de cambio"
  tasas <- tasas_sin_depurar[1:6,]
  
  return(tasas)
}

# function to get "Tasas Oficiales de Cambio BCV (Dólar, Euro, Lira, Yuan, Rublo)"
get_tasas_cambio_bcv_today<- function(){
  # get the url of BCV
  url <- "https://www.bcv.org.ve/tasas-informativas-sistema-bancario"
  
  response <- GET(url)
  
  # Look the nodes until you find what you want
  
  root_node <- read_html(response)
  
  root_node
  
  body_node<-html_nodes(root_node,"body")
  
  div_node<-html_nodes(body_node,"div")
  
  main_container_node<-div_node[20]
  
  main_div<-html_nodes(main_container_node,"div")
  
  # Here we get the Amounts
  
  euro_div <- html_nodes(main_div[48],"strong")
  yuan_div <- html_nodes(main_div[52],"strong")
  lira_div <- html_nodes(main_div[57],"strong")
  rublo_div<- html_nodes(main_div[62],"strong")
  dolar_div<- html_nodes(main_div[67],"strong")
  
  fecha_cambio <- html_nodes(main_div[72],"span")
  
  #Fecha de Cambio
  html_text(fecha_cambio)
  
  
  # Conversion de TASAS EURO
  euro_text <- html_text(euro_div)
  yuan_text <- html_text(yuan_div)
  lira_text <- html_text(lira_div)
  rublo_text<-html_text(rublo_div)
  dolar_text<-html_text(dolar_div)
  
  
  
  # Cambiar el html_text a valor numerico
  
  euro_text <- gsub("[^0-9,]", "", euro_text) # Eliminar caracteres que no sean nros ni comas. 
  yuan_text <- gsub("[^0-9,]", "", yuan_text) # Por ejemplo si incluye signos de moneda quedan eliminados esos simbolos
  lira_text <- gsub("[^0-9,]", "", lira_text)
  rublo_text<- gsub("[^0-9,]", "", rublo_text)
  dolar_text<- gsub("[^0-9,]", "", dolar_text)
  
  euro_numeric <- as.numeric(gsub(",", ".", euro_text))  # Reemplazar la coma por el punto decimal
  yuan_numeric <- as.numeric(gsub(",", ".", yuan_text))
  lira_numeric <- as.numeric(gsub(",", ".", lira_text))
  rublo_numeric<- as.numeric(gsub(",", ".", rublo_text))
  dolar_numeric<- as.numeric(gsub(",", ".", dolar_text))
  
  # Hacer que esos valores extraidos sean un Datafram
  # Limpiar y convertir el valor a numérico
  df = data.frame(c("Euro","Yuan","Lira","Rublo","Dólar"),
                  c(euro_numeric,yuan_numeric,lira_numeric,rublo_numeric,dolar_numeric))
  names(df)<-c("Moneda","Tasa de Cambio")
  
  return(df)
}

# function to get the day when it's official the "Tasa de Cambio"
get_fecha_de_cambio <- function(){
  # get the url of BCV
  url <- "https://www.bcv.org.ve/tasas-informativas-sistema-bancario"
  
  response <- GET(url)
  
  # Look the nodes until you find what you want
  root_node <- read_html(response)
  
  root_node
  
  body_node<-html_nodes(root_node,"body")
  
  div_node<-html_nodes(body_node,"div")
  
  main_container_node<-div_node[20]
  
  main_div<-html_nodes(main_container_node,"div")
  
  fecha_cambio <- html_nodes(main_div[72],"span")
  
  #Fecha de Cambio
  fecha_cambio <- html_text(fecha_cambio)
  
  return(fecha_cambio)
}


# Call the functions
tasas_bancos_nacionales <- get_tasas_compra_venta_bancos_bcv()

tasa_cambio_bcv <- get_tasas_cambio_bcv_today()

fecha_cambio <- get_fecha_de_cambio()

# Print the Data on the console
print(tasa_cambio_bcv)
print(tasas_bancos_nacionales)
print(fecha_cambio)

# Export data as a Excel file (.xlsx) - use openxlsx library

# Create the Workbook

Workbook <- openxlsx::createWorkbook()

# Create the Sheets
Sheet1 <- openxlsx::addWorksheet(Workbook,"Tasa_Oficial_BCV")
Sheet2 <- openxlsx::addWorksheet(Workbook,"Tasa_Compra_Venta_Bancos")

# Write the data to the Sheets
openxlsx::writeData(Workbook,Sheet1,tasa_cambio_bcv) # Write data Sheet1
openxlsx::writeData(Workbook,Sheet2,tasas_bancos_nacionales) # Write date Sheet2

# Save the Workbook (Excel file)
openxlsx::saveWorkbook(Workbook,
                       file = paste0(wd,"/Tasas_de_Cambio_BCV_",fecha_cambio,".xlsx"))

