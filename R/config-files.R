rm(list=ls())

##############################################################################
# ENSEMBLE OF CLASSIFIER CHAINS                                              #
# Copyright (C) 2025                                                         #
#                                                                            #
# This code is free software: you can redistribute it and/or modify it under #
# the terms of the GNU General Public License as published by the Free       #
# Software Foundation, either version 3 of the License, or (at your option)  #
# any later version. This code is distributed in the hope that it will be    #
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of     #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General   #
# Public License for more details.                                           #
#                                                                            #
# Prof. Elaine Cecilia Gatto - UFLA - Lavras, Minas Gerais, Brazil           #
# Prof. Ricardo Cerri - USP - São Carlos, São Paulo, Brazil                  #
# Prof. Mauri Ferrandin - UFSC - Blumenau, Santa Catarina, Brazil            #
# Prof. Celine Vens - Ku Leuven - Kortrijik, West Flanders, Belgium          #
# PhD Felipe Nakano Kenji - Ku Leuven - Kortrijik, West Flanders, Belgium    #
#                                                                            #
# BIOMAL - http://www.biomal.ufscar.br                                       #
#                                                                            #
##############################################################################



###############################################################################
# SET WORKSAPCE                                                               #
###############################################################################
library(here)
library(stringr)
FolderRoot <- here::here()
FolderScripts <- here::here("R")



###############################################################################
# READING DATASET INFORMATION FROM DATASETS-ORIGINAL.CSV                      #
###############################################################################
setwd(FolderRoot)
datasets = data.frame(read.csv("datasets-original.csv"))
n = nrow(datasets)


###############################################################################
# CREATING FOLDER TO SAVE CONFIG FILES                                        #
###############################################################################
FolderCF = paste(FolderRoot, "/config-files", sep="")
if(dir.exists(FolderCF)==FALSE){dir.create(FolderCF)}



###############################################################################
# QUAL Implementation USAR
###############################################################################
Implementation.1 = c("rf")
Implementation.2 = c("rf")


###############################################################################
# CREATING CONFIG FILES FOR EACH DATASET                                      #
###############################################################################
w = 1
while(w<=length(Implementation.1)){
  
  FolderPa = paste(FolderCF, "/", Implementation.1[w], sep="")
  if(dir.exists(FolderPa)==FALSE){dir.create(FolderPa)}
  
  i = 1
  while(i<=n){
    
    # specific dataset
    ds = datasets[i,]
    
    # print the dataset name
    cat("\n================================================")
    cat("\n\tDataset:", ds$Name)
    cat("\n\tPackge:", Implementation.1[w])
    
    
    name = paste("ecc-", ds$Name, sep = "")
    
    
    # name 
    file_name = paste(FolderPa, "/", name, ".csv", sep="")
    
    # Starts building the configuration file
    output.file <- file(file_name, "wb")
    
    # Config file table header
    write("Config, Value", file = output.file, append = TRUE)
    
    write("FolderScripts, ~/HPML.ECC/R", 
          file = output.file, append = TRUE)
    
    write("Dataset_Path,  ~/HPML.ECC/Datasets", 
          file = output.file, append = TRUE)
    
    temp.name = paste("/tmp/", name, sep = "")
     
    str.0 = paste("Temporary_Path, ", temp.name, sep="")
    write(str.0,file = output.file, append = TRUE)
    
    str.1 = paste("Implementation, ", Implementation.1[w], sep="")
    write(str.1, file = output.file, append = TRUE)
    
    str.2 = paste("Dataset_Name, ", ds$Name, sep="")
    write(str.2, file = output.file, append = TRUE)
    
    str.3 = paste("Number_Dataset, ", ds$Id, sep="")
    write(str.3, file = output.file, append = TRUE)
    
    write("Number_Folds, 10", file = output.file, append = TRUE)
    
    write("Number_Cores, 10", file = output.file, append = TRUE)
    
    close(output.file)
    
    i = i + 1
    
    gc()
  }
  
  cat("\n================================================")
  w = w + 1
  gc()
}

###############################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com                #
# Thank you very much!                                                        #                                #
###############################################################################
