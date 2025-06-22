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



############################################################################
converteArff <- function(arg1, arg2, arg3, FolderUtils){  
  str = paste("java -jar ", FolderUtils,  "/R_csv_2_arff.jar ", 
              arg1, " ", arg2, " ", arg3, sep="")
  print(system(str))
  cat("\n\n")  
}


##################################################################################################
# FUNCTION DIRECTORIES                                                                           #
#   Objective:                                                                                   #
#      Creates all the necessary folders for the project. These are the main folders that must   # 
#      be created and used before the script starts to run                                       #  
#   Parameters:                                                                                  #
#      None                                                                                      #
#   Return:                                                                                      #
#      All path directories                                                                      #
##################################################################################################
directories <- function(parameters){
  
  retorno = list()
  
  #############################################################################
  # RESULTS FOLDER:                                                           #
  # Parameter from command line. This folder will be delete at the end of the #
  # execution. Other folder is used to store definitely the results.          #
  # Example: "/dev/shm/result"; "/scratch/result"; "/tmp/result"              #
  #############################################################################
  folderResults = parameters$Config.File$Folder.Results
  if(dir.exists(parameters$Config.File$Folder.Results) == TRUE){
    setwd(folderResults)
    dir_folderResults = dir(folderResults)
    n_folderResults = length(dir_folderResults)
  } else {
    dir.create(folderResults)
    setwd(folderResults)
    dir_folderResults = dir(folderResults)
    n_folderResults = length(dir_folderResults)
  }
  retorno$FolderResults = parameters$Config.File$Folder.Results
  
  #############################################################################
  #
  #############################################################################
  folderScripts = parameters$Config.File$FolderScripts
  if(dir.exists(parameters$Config.File$FolderScripts) == TRUE){
    setwd(folderScripts)
    dir_folderScripts = dir(folderScripts)
    n_folderScripts = length(dir_folderScripts)
  } else {
    dir.create(folderScripts)
    setwd(folderScripts)
    dir_folderScripts= dir(folderScripts)
    n_folderScripts = length(dir_folderScripts)
  }
  retorno$folderScripts = parameters$Config.File$folderScripts
  
  #############################################################################
  #
  #############################################################################
  folderUtils = paste(FolderRoot, "/Utils", sep="")
  if(dir.exists(folderUtils) == TRUE){
    setwd(folderUtils)
    dir_folderUtils = dir(folderUtils)
    n_folderUtils = length(dir_folderUtils)
  } else {
    dir.create(folderUtils)
    setwd(folderUtils)
    dir_folderUtils = dir(folderUtils)
    n_folderUtils = length(dir_folderUtils)
  }
  retorno$FolderUtils = folderUtils
  
  #############################################################################
  #
  #############################################################################
  folderPython = paste(FolderRoot, "/Python", sep="")
  if(dir.exists(folderPython) == TRUE){
    setwd(folderPython)
    dir_folderPython = dir(folderPython)
    n_folderPython = length(dir_folderPython)
  } else {
    dir.create(folderPython)
    setwd(folderPython)
    dir_folderPython = dir(folderPython)
    n_folderPython = length(dir_folderPython)
  }
  retorno$FolderPython = folderPython
  
  
  #############################################################################
  # VALIDATION FOLDER: "/dev/shm/results/Validation"                          #
  #         Folder that will temporarily store the files and folders needed   #
  #     for code processing in the validation phase                           #
  #############################################################################
  folderECC = paste(parameters$Config.File$Folder.Results, "/ECC", sep="")
  if(dir.exists(folderECC) == TRUE){
    setwd(folderECC)
    dir_folderECC = dir(folderECC)
    n_folderECC = length(dir_folderECC)
  } else {
    dir.create(folderECC)
    setwd(folderECC)
    dir_folderECC = dir(folderECC)
    n_folderECC = length(dir_folderECC)
  }
  
  
  
  
  #############################################################################
  # DATASET FOLDER: "/dev/shm/results/Dataset"                                #
  #         Folder that will temporarily store the dataset files and folders  #
  #############################################################################
  folderDataset = paste(parameters$Config.File$Folder.Results, "/Dataset", sep="")
  if(dir.exists(folderDataset) == TRUE){
    setwd(folderDataset)
    dir_folderDataset = dir(folderDataset)
    n_folderDataset = length(dir_folderDataset)
  } else {
    dir.create(folderDataset)
    setwd(folderDataset)
    dir_folderDataset = dir(folderDataset)
    n_folderDataset = length(dir_folderDataset)
  }
  
  
  #############################################################################
  # SPECIFIC DATASET FOLDER:                                                  #
  #         "/dev/shm/results/Dataset/GpositiveGO"                            #
  #         Folder that will temporarily store the dataset files and folders  #
  #############################################################################
  folderDatasetX = paste(folderDataset, "/", 
                         parameters$Config.File$Dataset.Name , sep="")
  if(dir.exists(folderDatasetX) == TRUE){
    setwd(folderDatasetX)
    dir_folderDatasetX = dir(folderDatasetX)
    n_folderDatasetX = length(dir_folderDatasetX)
  } else {
    dir.create(folderDatasetX)
    setwd(folderDatasetX)
    dir_folderDatasetX = dir(folderDatasetX)
    n_folderDatasetX = length(dir_folderDatasetX)
  }
  
  #############################################################################
  # CROSS VALIDATION FOLDER:                                                  #
  #         "/dev/shm/results/Dataset/GpositiveGO/CrossValidation"            #
  #         Folder that will temporarily store the dataset files and folders  #
  #############################################################################
  folderCV = paste(folderDatasetX, "/CrossValidation", sep="")
  if(dir.exists(folderCV) == TRUE){
    setwd(folderCV)
    dir_folderCV = dir(folderCV)
    n_folderCV = length(dir_folderCV)
  } else {
    dir.create(folderCV)
    setwd(folderCV)
    dir_folderCV = dir(folderCV)
    n_folderCV = length(dir_folderCV)
  }
  
  #############################################################################
  # CROSS VALIDATION TRAIN FILES/FOLDER:                                      #
  #         "/dev/shm/results/Dataset/GpositiveGO/CrossValidation/Tr"         #
  #         Folder that will temporarily store the dataset files and folders  #
  #############################################################################
  folderCVTR = paste(folderCV, "/Tr", sep="")
  if(dir.exists(folderCVTR) == TRUE){
    setwd(folderCVTR)
    dir_folderCVTR = dir(folderCVTR)
    n_folderCVTR = length(dir_folderCVTR)
  } else {
    dir.create(folderCVTR)
    setwd(folderCVTR)
    dir_folderCVTR = dir(folderCVTR)
    n_folderCVTR = length(dir_folderCVTR)
  }
  
  #############################################################################
  # CROSS VALIDATION TEST FILES/FOLDER:                                       #
  #          "/dev/shm/results/Dataset/GpositiveGO/CrossValidation/Ts"        #
  #         Folder that will temporarily store the dataset files and folders  #
  #############################################################################
  folderCVTS = paste(folderCV, "/Ts", sep="")
  if(dir.exists(folderCVTS) == TRUE){
    setwd(folderCVTS)
    dir_folderCVTS = dir(folderCVTS)
    n_folderCVTS = length(dir_folderCVTS)
  } else {
    dir.create(folderCVTS)
    setwd(folderCVTS)
    dir_folderCVTS = dir(folderCVTS)
    n_folderCVTS = length(dir_folderCVTS)
  }
  
  #############################################################################
  # CROSS VALIDATION VALIDATION FILES/FOLDER:                                 #
  #         "/dev/shm/results/Dataset/GpositiveGO/CrossValidation/Vl"         #
  #         Folder that will temporarily store the dataset files and folders  #
  #############################################################################
  folderCVVL = paste(folderCV, "/Vl", sep="")
  if(dir.exists(folderCVVL) == TRUE){
    setwd(folderCVVL)
    dir_folderCVVL = dir(folderCVVL)
    n_folderCVVL = length(dir_folderCVVL)
  } else {
    dir.create(folderCVVL)
    setwd(folderCVVL)
    dir_folderCVVL = dir(folderCVVL)
    n_folderCVVL = length(dir_folderCVVL)
  }
  
  #############################################################################
  # CROSS VALIDATION LABEL SPACE FILES/FOLDER:                                #
  #         "/dev/shm/results/Dataset/GpositiveGO/LabelSpace"                 #
  #         Folder that will temporarily store the dataset files and folders  #
  #############################################################################
  folderLabelSpace = paste(folderDatasetX, "/LabelSpace", sep="")
  if(dir.exists(folderLabelSpace) == TRUE){
    setwd(folderLabelSpace)
    dir_folderLabelSpace = dir(folderLabelSpace)
    n_folderLabelSpace = length(dir_folderLabelSpace)
  } else {
    dir.create(folderLabelSpace)
    setwd(folderLabelSpace)
    dir_folderLabelSpace = dir(folderLabelSpace)
    n_folderLabelSpace = length(dir_folderLabelSpace)
  }
  
  #############################################################################
  # CROSS VALIDATION LABELS NAMES FILES/FOLDER:                               #
  #        "/dev/shm/results/Dataset/GpositiveGO/NamesLabels"                 #
  #         Folder that will temporarily store the dataset files and folders  #
  #############################################################################
  folderNamesLabels = paste(folderDatasetX, "/NamesLabels", sep="")
  if(dir.exists(folderNamesLabels) == TRUE){
    setwd(folderNamesLabels)
    dir_folderNamesLabels = dir(folderNamesLabels)
    n_folderNamesLabels = length(dir_folderNamesLabels)
  } else {
    dir.create(folderNamesLabels)
    setwd(folderNamesLabels)
    dir_folderNamesLabels = dir(folderNamesLabels)
    n_folderNamesLabels = length(dir_folderNamesLabels)
  }
  
  
  # return folders
  retorno$folderUtils = folderUtils
  retorno$folderECC = folderECC
  retorno$folderResults = folderResults
  retorno$folderDataset = folderDataset
  retorno$folderDatasetX = folderDatasetX
  retorno$folderCV = folderCV
  retorno$folderCVTR = folderCVTR
  retorno$folderCVTS = folderCVTS
  retorno$folderCVVL = folderCVVL
  retorno$folderLabelSpace = folderLabelSpace
  retorno$folderNamesLabels = folderNamesLabels
  
  # return folder contents
  retorno$dir_folderUtils = dir_folderUtils
  retorno$dir_folderECC = dir_folderECC
  retorno$dir_folderResults = dir_folderResults
  retorno$dir_folderDataset = dir_folderDataset
  retorno$dir_folderDatasetX = dir_folderDatasetX
  retorno$dir_folderCV = dir_folderCV
  retorno$dir_folderCVTR = dir_folderCVTR
  retorno$dir_folderCVTS = dir_folderCVTS
  retorno$dir_folderCVVL = dir_folderCVVL
  retorno$dir_folderLabelSpace = dir_folderLabelSpace
  retorno$dir_folderNamesLabels = dir_folderNamesLabels
  
  # return of the number of objects inside the folder
  retorno$n_folderUtils = n_folderUtils
  retorno$n_folderECC = n_folderECC
  retorno$n_folderResults = n_folderResults
  retorno$n_folderDataset = n_folderDataset
  retorno$n_folderDatasetX = n_folderDatasetX
  retorno$n_folderCV = n_folderCV
  retorno$n_folderCVTR = n_folderCVTR
  retorno$n_folderCVTS = n_folderCVTS
  retorno$n_folderCVVL = n_folderCVVL
  retorno$n_folderLabelSpace = n_folderLabelSpace
  retorno$n_folderNamesLabels = n_folderNamesLabels
  
  return(retorno)
  gc()
  
}



##################################################################################################
# FUNCTION INFO DATA SET                                                                         #
#  Objective                                                                                     #
#     Gets the information that is in the "datasets.csv" file.                                    #  
#  Parameters                                                                                    #
#     dataset: the specific dataset                                                              #
#  Return                                                                                        #
#     Everything in the spreadsheet                                                              #
##################################################################################################
infoDataSet <- function(dataset){
  retorno = list()
  retorno$id = dataset$ID
  retorno$name = dataset$Name
  retorno$instances = dataset$Instances
  retorno$inputs = dataset$Inputs
  retorno$labels = dataset$Labels
  retorno$LabelsSets = dataset$LabelsSets
  retorno$single = dataset$Single
  retorno$maxfreq = dataset$MaxFreq
  retorno$card = dataset$Card
  retorno$dens = dataset$Dens
  retorno$mean = dataset$Mean
  retorno$scumble = dataset$Scumble
  retorno$tcs = dataset$TCS
  retorno$attStart = dataset$AttStart
  retorno$attEnd = dataset$AttEnd
  retorno$labStart = dataset$LabelStart
  retorno$labEnd = dataset$LabelEnd
  return(retorno)
  gc()
}

avaliacao <- function(f, y_true, y_pred, salva, nome){
  
  #salva.0 = paste(salva, "/", nome, "-conf-mat.txt", sep="")
  #sink(file=salva.0, type="output")
  confmat = multilabel_confusion_matrix(y_true, y_pred)
  #print(confmat)
  #sink()
  
  resConfMat = multilabel_evaluate(confmat)
  resConfMat = data.frame(resConfMat)
  names(resConfMat) = paste("Fold-", f, sep="")
  salva.1 = paste(salva, "/", nome, ".csv", sep="")
  write.csv(resConfMat, salva.1)
  
  conf.mat = data.frame(confmat$TPl, confmat$FPl,
                        confmat$FNl, confmat$TNl)
  names(conf.mat) = c("TP", "FP", "FN", "TN")
  conf.mat.perc = data.frame(conf.mat/nrow(y_true$dataset))
  names(conf.mat.perc) = c("TP.perc", "FP.perc", "FN.perc", "TN.perc")
  wrong = conf.mat$FP + conf.mat$FN
  wrong.perc = wrong/nrow(y_true$dataset)
  correct = conf.mat$TP + conf.mat$TN
  correct.perc = correct/nrow(y_true$dataset)
  conf.mat.2 = data.frame(conf.mat, conf.mat.perc, wrong, correct, 
                          wrong.perc, correct.perc)
  salva.2 = paste(salva, "/", nome, "-utiml.csv", sep="")
  #write.csv(conf.mat.2, salva.2)
  
}




##################################################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com                                   #
# Thank you very much!                                                                           #
##################################################################################################
