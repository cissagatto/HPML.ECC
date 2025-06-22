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
  cat("\n# RUN: Evaluate                                            #")
  cat("\n############################################################\n\n")
  time.evaluate = system.time(evaluate.ecc.python(parameters))
  
  
  cat("\n############################################################")
  cat("\n# RUN: Gather Evaluated Measures                           #")
  cat("\n############################################################\n\n")
  time.gather.evaluate = system.time(gather.eval.python.silho(parameters))
  
  
  cat("\n############################################################")
  cat("\n# RUN: Save Runtime                                        #")
  cat("\n##############################################################\n\n")
  RunTimeecc = rbind(time.execute, time.evaluate, time.gather.evaluate)
  setwd(diretorios$folderECC)
  write.csv(RunTimeecc, "runtime-run-python.csv")
  
  
  cat("\n\n############################################################")
  cat("\n# RUN: Stop Parallel                                         #")
  cat("\n##############################################################\n\n")
  parallel::stopCluster(cl) 	
  
}


##################################################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com                                   #
# Thank you very much!                                                                           #
##################################################################################################
