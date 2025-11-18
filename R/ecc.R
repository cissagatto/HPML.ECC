cat("\n#########################################################")
cat("\n# HPML.ECC: START                                       #")
cat("\n#########################################################\n\n")

# clean
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
# 1 - Prof PhD Elaine Cecilia Gatto                                          #
# 2 - Prof PhD Ricardo Cerri                                                 #
# 3 - Prof PhD Mauri Ferrandin                                               #
# 4 - Prof PhD Celine Vens                                                   #
# 5 - PhD Felipe Nakano Kenji                                                #
# 6 - Prof PhD Jesse Read                                                    #
#                                                                            #
# 1 = Federal University of São Carlos - UFSCar - https://www2.ufscar.br     #
# Campus São Carlos | Computer Department - DC - https://site.dc.ufscar.br | #
# Post Graduate Program in Computer Science - PPGCC                          # 
# http://ppgcc.dc.ufscar.br | Bioinformatics and Machine Learning Group      #
# BIOMAL - http://www.biomal.ufscar.br                                       # 
#                                                                            # 
# 1 = Federal University of Lavras - UFLA                                    #
#                                                                            # 
# 2 = State University of São Paulo - USP                                    #
#                                                                            # 
# 3 - Federal University of Santa Catarina Campus Blumenau - UFSC            #
# https://ufsc.br/                                                           #
#                                                                            #
# 4 and 5 - Katholieke Universiteit Leuven Campus Kulak Kortrijk Belgium     #
# Medicine Department - https://kulak.kuleuven.be/                           #
# https://kulak.kuleuven.be/nl/over_kulak/faculteiten/geneeskunde            #
#                                                                            #
# 6 - Ecole Polytechnique | Institut Polytechnique de Paris | 1 rue Honoré   #
# d’Estienne d’Orves - 91120 - Palaiseau - FRANCE                            #
#                                                                            #
##############################################################################

#getwd()



cat("\n##############################")
cat("\n# Set Work Space             #")
cat("\n##############################\n\n")
library(here)
library(stringr)
FolderRoot <- here::here()



cat("\n########################################")
cat("\n# R Options Configuration              #")
cat("\n########################################\n\n")
options(java.parameters = "-Xmx64g")  # JAVA
options(show.error.messages = TRUE)   # ERROR MESSAGES
options(scipen=20)                    # number of places after the comma
options(repos = c(CRAN = "https://cloud.r-project.org"))



cat("\n########################################")
cat("\n# Creating parameters list             #")
cat("\n########################################\n\n")
parameters = list()


cat("\n########################################")
cat("\n# Reading Datasets-Original.csv        #")
cat("\n########################################\n\n")
setwd(FolderRoot)
datasets <- data.frame(read.csv("datasets-original.csv"))
parameters$Datasets.List = datasets


cat("\n#####################################")
cat("\n# GET ARGUMENTS FROM COMMAND LINE   #")
cat("\n#####################################\n\n")
args <- commandArgs(TRUE)

config_file <- args[1]


# config_file = "~/HPML.ECC/config-files/ecc-GnegativeGO-1.csv"


parameters$Config.File$Name = config_file
if(file.exists(config_file)==FALSE){
  cat("\n################################################################")
  cat("\n# Missing Config File! Verify the following path:              #")
  cat("\n################################################################")
  cat("\n --------------->", config_file)
  break
} else {
  cat("\n########################################")
  cat("\n# Properly loaded configuration file!  #")
  cat("\n########################################\n\n")
}


cat("\n########################################")
cat("\n# Config File                          #")
cat("\n########################################\n\n")
config = data.frame(read.csv(config_file))
print(config)




cat("\n##################################################")
cat("\n# HPML.ECC: Getting Parameters                   #")
cat("\n##################################################\n\n")
FolderScripts = toString(config$Value[1])
FolderScripts = str_remove(FolderScripts, pattern = " ")
parameters$Config.File$FolderScripts = FolderScripts

dataset_path = toString(config$Value[2])
dataset_path = str_remove(dataset_path, pattern = " ")
parameters$Config.File$Dataset.Path = dataset_path

folderResults = toString(config$Value[3]) 
folderResults = str_remove(folderResults, pattern = " ")
parameters$Config.File$Folder.Results = folderResults

implementation = toString(config$Value[4])
implementation = str_remove(implementation, pattern = " ")
parameters$Config.File$Implementation = implementation

dataset_name = toString(config$Value[5])
dataset_name = str_remove(dataset_name, pattern = " ")
parameters$Config.File$Dataset.Name = dataset_name

number_dataset = as.numeric(config$Value[6])
parameters$Config.File$Number.Dataset = number_dataset

number_folds = as.numeric(config$Value[7])
parameters$Config.File$Number.Folds = number_folds

number_cores = as.numeric(config$Value[8])
parameters$Config.File$Number.Cores = number_cores

ds = datasets[number_dataset,]
parameters$Dataset.Info = ds

print(ds)


cat("\n########################################")
cat("\n# Loading R Sources                    #")
cat("\n########################################\n\n")
source(file.path(FolderScripts, "libraries.R"))
source(file.path(FolderScripts, "utils.R"))


cat("\n#########################################")
cat("\n# HPML.ECC: Get directories             #")
cat("\n#########################################\n\n")
diretorios <- directories(parameters)
parameters$Directories = diretorios

FolderE = paste(parameters$Directories$FolderResults, 
                "/ECC2", sep="")
if(dir.exists(FolderE)==FALSE){dir.create(FolderE)}
parameters$Directories$FolderECC2 = FolderE


cat("\n########################################")
cat("\n# Creating temporary processing folder #")
cat("\n########################################\n\n")
if (dir.exists(folderResults) == FALSE) {dir.create(folderResults)}



cat("\n####################################################################")
cat("\n# Checking the dataset tar.gz file                                 #")
cat("\n####################################################################\n\n")
str00 = paste(dataset_path, "/", ds$Name,".tar.gz", sep = "")
str00 = str_remove(str00, pattern = " ")

if(file.exists(str00)==FALSE){
  
  cat("\n######################################################################")
  cat("\n# The tar.gz file for the dataset to be processed does not exist!    #")
  cat("\n# Please pass the path of the tar.gz file in the configuration file! #")
  cat("\n# The path entered was: ", str00, "                                  #")
  cat("\n######################################################################\n\n")
  break
  
} else {
  
  cat("\n####################################################################")
  cat("\n# tar.gz file of the DATASET loaded correctly!                     #")
  cat("\n####################################################################\n\n")
  
  # COPIANDO
  str01 = paste("cp ", str00, " ", diretorios$folderDataset, sep = "")
  res = system(str01)
  if (res != 0) {
    cat("\nError: ", str01)
    break
  }
  
  # DESCOMPACTANDO
  str02 = paste("tar xzf ", diretorios$folderDataset, "/", ds$Name,
                ".tar.gz -C ", diretorios$folderDataset, sep = "")
  res = system(str02)
  if (res != 0) {
    cat("\nError: ", str02)
    break
  }
  
  #APAGANDO
  str03 = paste("rm ", diretorios$folderDataset, "/", ds$Name,
                ".tar.gz", sep = "")
  res = system(str03)
  if (res != 0) {
    cat("\nError: ", str03)
    break
  }
  
}




##############################################################################

if(implementation=="utiml"){
  # 
  # setwd(FolderScripts)
  # source("run-utiml.R")
  # 
  # cat("\n\n############################################################")
  #   cat("\n# RSCRIPT ECC START                                     #")
  #   cat("\n############################################################\n\n")
  # timeFinal <- system.time(results <- run.ecc.utiml(ds, 
  #                                                   dataset_name,
  #                                                   number_dataset, 
  #                                                   number_cores, 
  #                                                   number_folds, 
  #                                                   folderResults))  
  # 
  # cat("\n\n#####################################################")
  #   cat("\n# RSCRIPT SAVE RUNTIME                              #")
  #   cat("\n#####################################################\n\n")
  # result_set <- t(data.matrix(timeFinal))
  # setwd(diretorios$folderECC)
  # write.csv(result_set, "Runtime-Final.csv")
  # x.minutos =(1 * as.numeric(result_set[3]))/60
  # setwd(diretorios$folderECC)
  # write(x.minutos, "minutos.txt")
  # 
  # 
  # cat("\n\n#####################################################")
  #   cat("\n# RSCRIPT DELETE                                   #")
  #   cat("\n####################################################\n\n")
  # str5 = paste("rm -r ", diretorios$folderDataset, sep="")
  # print(system(str5))
  # 
  # 
  # 
  # cat("\n\n######################################################")
  #   cat("\n# RSCRIPT COPY TO GOOGLE DRIVE                       #")
  #   cat("\n######################################################\n\n")
  # origem = diretorios$folderECC
  # destino = paste("nuvem:ECC/Utiml/", dataset_name, sep="")
  # comando = paste("rclone -P copy ", origem, " ", destino, sep="")
  # cat("\n", comando, "\n") 
  # a = print(system(comando))
  # a = as.numeric(a)
  # if(a != 0) {
  #   stop("Erro RCLONE")
  #   quit("yes")
  # }
  # 
  
} else if(implementation=="rf"){
  
  source(file.path(FolderScripts, "run-python.R"))
  
  cat("\n#########################################################")
  cat("\n# HPML.ECC: ECC START                                   #")
  cat("\n#########################################################\n\n")
  timeFinal <- system.time(results <- run.ecc.python(parameters))  
  
  
  cat("\n#####################################################")
  cat("\n# HPML.ECC: SAVE RUNTIME                            #")
  cat("\n#####################################################\n\n")
  result_set <- t(data.matrix(timeFinal))
  setwd(diretorios$folderECC)
  write.csv(result_set, "runtime-script.csv")
  
  
  cat("\n###################################################")
  cat("\n# HPML.ECC: DELETE ALL TEMPORARY FILES            #")
  cat("\n###################################################\n\n")
  str5 = paste("rm -r ", diretorios$folderDataset, sep="")
  print(system(str5))
  
  # /tmp/ecc-GnegativeGO/ECC2
  str5 = paste("rm -r ", diretorios$folderResults, "/ECC2", sep="")
  print(system(str5))
  
  
  cat("\n##############################################################")
  cat("\n# HPML.ECC: COMPRESS RESULTS                                 #")
  cat("\n##############################################################\n\n")
  # base_dir   <- "/tmp/d-GnegativeGO/Tested"
  base_dir   <- parameters$Directories$folderECC
  
  # output_tar <- "/tmp/d-GnegativeGO/GnegativeGO-results-hpml.tar.gz"
  output_tar <- paste0(parameters$Directories$FolderResults, "/",
                       parameters$Dataset.Info$Name, "-results-ecc.tar.gz")
  
  cmd <- paste("tar -zcvf", output_tar, "-C", base_dir, ".")
  res = system(cmd)
  
  if (res != 0) {
    #system(paste("rm -r", base_dir))
    #print(res)
    message("\n\n Something went wrong in compressing results files \n\n")
  } else {
    cat("\n✅ Compressão concluída com sucesso!\n")
  }
  
  cat("\n##########################################################")
  cat("\n# ECC: COPY TO HOME                                      #")
  cat("\n##########################################################\n\n")
  str0 = paste0(FolderRoot, "/Reports")
  if(dir.exists(str0)==FALSE){dir.create(str0)}
  
  str4 <- paste0(parameters$Directories$folderResults, "/",
    parameters$Dataset.Info$Name, "-results-ecc.tar.gz")
  
  str5 = paste("cp ", str4, " ", str0, sep="")
  res = system(str5)
  
  if(res!=0){
    #system(paste("rm -r ", parameters$Directories$FolderResults, sep=""))
    #print(res)
    message("\n\n Something went wrong in compressing results files \n\n")
  }
  
  
} else {
  
  # 
  # setwd(FolderScripts)
  # source("run-mulan.R")
  # 
  # 
  # cat("\n\n############################################################")
  # cat("\n# RSCRIPT ECC START                                     #")
  # cat("\n############################################################\n\n")
  # timeFinal <- system.time(results <- run.ecc.mulan(ds, 
  #                                                   dataset_name,
  #                                                   number_dataset, 
  #                                                   number_cores, 
  #                                                   number_folds, 
  #                                                   folderResults))  
  # 
  # 
  # 
  # cat("\n\n#####################################################")
  # cat("\n# RSCRIPT SAVE RUNTIME                              #")
  # cat("\n#####################################################\n\n")
  # result_set <- t(data.matrix(timeFinal))
  # setwd(diretorios$folderECC)
  # write.csv(result_set, "Runtime-Final.csv")
  # x.minutos = (1 * as.numeric(result_set[3]))/60
  # setwd(diretorios$folderECC)
  # write(x.minutos, "minutos.txt")
  # 
  # 
  # cat("\n\n#################################################")
  # cat("\n# RSCRIPT DELETE                                  #")
  # cat("\n###################################################\n\n")
  # str5 = paste("rm -r ", diretorios$folderDataset, sep="")
  # print(system(str5))
  # 
  # 
  # cat("\n\n######################################################")
  #   cat("\n# RSCRIPT COPY TO GOOGLE DRIVE                       #")
  #   cat("\n######################################################\n\n")
  # origem = diretorios$folderECC
  # destino = paste("nuvem:ECC/Mulan/", dataset_name, sep="")
  # comando = paste("rclone -P copy ", origem, " ", destino, sep="")
  # cat("\n", comando, "\n") 
  # a = print(system(comando))
  # a = as.numeric(a)
  # if(a != 0) {
  #   stop("Erro RCLONE")
  #   quit("yes")
  # }
  # 
  
  
} 


# cat("\n\n###################################################################")
# cat("\n# ECC ECC: COMPRESS RESULTS                                      #")
# cat("\n#####################################################################\n\n")
# str3 = paste("tar -zcvf ", diretorios$folderResults, "/", 
#              dataset_name, "-results-ECC.tar.gz ", 
#              diretorios$folderResults, sep="")
# print(system(str3))


# cat("\n\n##############################################################")
# cat("\n# ECC ECC: COPY TO FOLDER REPORTS                           #")
# cat("\n###############################################################\n\n")
# str0 = "~/Ensemble-Classifier-Chains/Reports/"
# if(dir.exists(str0)==FALSE){dir.create(str0)}
# str1 = paste(diretorios$folderResults, "/", dataset_name,
#              "-results-ECC.tar.gz", sep="")
# str4 = paste("cp -r ", str1 , " ", str0, sep="")
# print(system(str4))



cat("\n#######################################################")
cat("\n# CLEAN                                               #")
cat("\n#######################################################\n\n")
cat("\nDelete folder \n")
str5 = paste("rm -r ", folderResults, sep="")
print(system(str5))


cat("\n################################################################")
cat("\n# RSCRIPT SUCCESSFULLY FINISHED                                #")
cat("\n################################################################\n\n")


rm(list = ls())
gc()

###############################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com                #
# Thank you very much!                                                        #                                #
###############################################################################
