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


###############################################################################
# SET WORKSAPCE                                                               #
###############################################################################
library(here)
library(stringr)
FolderRoot <- here::here()
FolderScripts <- here::here("R")





###########################################################################
# Runs for all datasets listed in the "datasets.csv" file                                        #
# n_dataset: number of the dataset in the "datasets.csv"                                         #
# number_cores: number of cores to paralell                                                      #
# number_folds: number of folds for cross validation                                             # 
# delete: if you want, or not, to delete all folders and files generated                         #
######################################################################
run.ecc.python <- function(parameters){
  
  source(file.path(parameters$Config.File$FolderScripts, "ecc-python.R"))
  
  if(parameters$Config.File$Number.Cores == 0){
    
    cat("\n##########################################################")
    cat("\n# Zero is a disallowed value for number_cores. Please    #")
    cat("\n# choose a value greater than or equal to 1.             #")
    cat("\n##########################################################\n\n")
    
  } else {
    
    cl <- parallel::makeCluster(parameters$Config.File$Number.Cores)
    doParallel::registerDoParallel(cl)
    print(cl)
    
    if(parameters$Config.File$Number.Cores==1){
      cat("\n######################################################")
      cat("\n# Running Sequentially!                              #")
      cat("\n######################################################\n\n")
    } else {
      cat("\n#############################################################################")
      cat("\n# Running in parallel with ", parameters$Config.File$Number.Cores, " cores! #")
      cat("\n#############################################################################\n\n")
    }
  }
  
  retorno = list()
  
  cat("\n##################################################")
  cat("\n# RUN: Names Labels                              #")
  cat("\n##################################################\n\n")
  name.file = paste(parameters$Directories$folderNamesLabels, "/",
                    parameters$Config.File$Dataset.Name,
                    "-NamesLabels.csv", sep="")
  labels.names = data.frame(read.csv(name.file))
  names(labels.names) = c("Index", "Labels")
  parameters$Names.Labels = labels.names
  
  
  cat("\n###################################################")
  cat("\n# RUN: Execute ECC                                #")
  cat("\n###################################################\n\n")
  time.execute = system.time(execute.ecc.python(parameters))
  
  
  cat("\n############################################################")
  cat("\n# RUN: Evaluate 1                                          #")
  cat("\n############################################################\n\n")
  time.evaluate = system.time(evaluate.ecc.python(parameters,
                                                  folder = parameters$Directories$folderECC))
  
  
  cat("\n############################################################")
  cat("\n# RUN: Evaluate 2                                          #")
  cat("\n############################################################\n\n")
  time.evaluate = system.time(evaluate.ecc.python(parameters,
                                                  folder = parameters$Directories$FolderECC2))
  
  
  cat("\n############################################################")
  cat("\n# RUN: Gather Evaluated Measures 1                         #")
  cat("\n############################################################\n\n")
  time.gather.evaluate = system.time(gather.eval.python.silho(parameters,
                                                              folder = parameters$Directories$folderECC))
  
  
  cat("\n############################################################")
  cat("\n# RUN: Gather Evaluated Measures 2                         #")
  cat("\n############################################################\n\n")
  time.gather.evaluate = system.time(gather.eval.python.silho(parameters,
                                                              folder = parameters$Directories$FolderECC2))
  
  
  #cat("\n############################################################")
  #cat("\n# RUN: Save Runtime                                        #")
  #cat("\n##############################################################\n\n")
  #RunTimeecc = rbind(time.execute, time.evaluate, time.gather.evaluate)
  #setwd(diretorios$folderECC)
  #write.csv(RunTimeecc, "runtime-run-python.csv")
  
  
  cat("\n\n############################################################")
  cat("\n# RUN: Stop Parallel                                         #")
  cat("\n##############################################################\n\n")
  parallel::stopCluster(cl) 	
  
}


##################################################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com                                   #
# Thank you very much!                                                                           #
##################################################################################################
