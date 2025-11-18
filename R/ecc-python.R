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



##############################################################################
# FUNCTION EXECUTE PYTHON ECC                                               #
#   Objective                                                                #
#       Tests ECC partitions                                              #
#   Parameters                                                               #
#       ds: specific dataset information                                     #
#       parameters$Config.File$Dataset.Name: dataset name. It is used to save files.                #
#       number_folds: number of folds created                                #
#       Folder: folder path                                                  #
#   Return                                                                   #
#       configurations files                                                 #
##############################################################################
execute.ecc.python <- function(parameters){
  
  # f = 1
  PythonEccParalel <- foreach(f = 1:parameters$Config.File$Number.Folds) %dopar%{
  # while(f<=parameters$Config.File$Number.Folds){
    
    #########################################################################
    # cat("\nFold: ", f)
    source(file.path(parameters$Config.File$FolderScripts, "libraries.R"))
    source(file.path(parameters$Config.File$FolderScripts, "utils.R"))
    
    
    ##########################################################################
    FolderSplit = paste(parameters$Directories$folderECC , "/Split-", f, sep="")
    if(dir.exists(FolderSplit)==FALSE){dir.create(FolderSplit)}
    
    FolderSplit2 = paste(parameters$Directories$FolderECC2 , "/Split-", f, sep="")
    if(dir.exists(FolderSplit2)==FALSE){dir.create(FolderSplit2)}
    
    
    ##########################################################################
    train.file.name = paste(parameters$Directories$folderCVTR, "/", 
                            parameters$Config.File$Dataset.Name, 
                            "-Split-Tr-", f , ".csv", sep="")
    
    test.file.name = paste(parameters$Directories$folderCVTS, "/",
                           parameters$Config.File$Dataset.Name, 
                           "-Split-Ts-", f, ".csv", sep="")
    
    val.file.name = paste(parameters$Directories$folderCVVL, "/", 
                          parameters$Config.File$Dataset.Name, 
                            "-Split-Vl-", f , ".csv", sep="")
    
    
    ##########################################################################
    setwd(FolderSplit)
    train = data.frame(read.csv(train.file.name))
    test = data.frame(read.csv(test.file.name))
    val = data.frame(read.csv(val.file.name))
    tv = rbind(train, val)
    
    
    ##########################################################################
    labels.indices = seq(parameters$Dataset.Info$LabelStart, 
                         parameters$Dataset.Info$LabelEnd, by=1)
    
    
    ##########################################################################
    mldr.treino = mldr_from_dataframe(train, labelIndices = labels.indices)
    mldr.teste = mldr_from_dataframe(test, labelIndices = labels.indices)
    mldr.val = mldr_from_dataframe(val, labelIndices = labels.indices)
    mldr.tv = mldr_from_dataframe(tv, labelIndices = labels.indices)
    
    
    ##################################################################
    # EXECUTE ECC PYTHON
    str.execute = paste("python3 ", parameters$Directories$FolderPython,
                        "/main.py ", 
                        train.file.name, " ",
                        val.file.name,  " ",
                        test.file.name, " ", 
                        start = as.numeric(parameters$Dataset.Info$AttEnd), " ", 
                        FolderSplit, " ", 
                        fold = f,
                        sep="")
    res = system(str.execute)
    if(res!=0){
      system(paste("rm -r ", parameters$Directories$FolderResults, sep=""))
      stop("\n\n Something went wrong in python VERSION 2\n\n")
    } else {
      message("\n\n PYTHON RAN OK! \n\n")
    }
    
   
    
    # f = f + 1
    gc()
  }
  
  gc()
  cat("\n###############################################")
  cat("\n# END EXECUTE ECC PYTHON                      #")
  cat("\n###############################################")
  cat("\n\n")
}




############################################################################
#
############################################################################
evaluate.ecc.python <- function(parameters, folder){
  
  # f = 1
  avaliaParalel <- foreach (f = 1:parameters$Config.File$Number.Folds) %dopar%{
  # while(f<=parameters$Config.File$Number.Folds){
    
    #########################################################################
    cat("\nFold: ", f)
    
    
    ###########################################################################
    FolderSplit = paste(folder, "/Split-", f, sep="")
    

    ##########################################################################
    source(file.path(parameters$Config.File$FolderScripts, "libraries.R"))
    source(file.path(parameters$Config.File$FolderScripts, "utils.R"))
    
    
    ##########################################################################
    train.file.name = paste(parameters$Directories$folderCVTR, "/", 
                            parameters$Config$Dataset.Name, 
                            "-Split-Tr-", f , ".csv", sep="")
    
    test.file.name = paste(parameters$Directories$folderCVTS, "/",
                           parameters$Config$Dataset.Name, 
                           "-Split-Ts-", f, ".csv", sep="")
    
    val.file.name = paste(parameters$Directories$folderCVVL, "/", 
                          parameters$Config$Dataset.Name, 
                          "-Split-Vl-", f , ".csv", sep="")
    
    ##########################################################################
    train = data.frame(read.csv(train.file.name))
    test = data.frame(read.csv(test.file.name))
    val = data.frame(read.csv(val.file.name))
    tv = rbind(train, val)
    
    
    ##########################################################################
    labels.indices = seq(parameters$Dataset.Info$LabelStart, 
                         parameters$Dataset.Info$LabelEnd, by=1)
    
    
    ##########################################################################
    mldr.treino = mldr_from_dataframe(train, labelIndices = labels.indices)
    mldr.teste = mldr_from_dataframe(test, labelIndices = labels.indices)
    mldr.val = mldr_from_dataframe(val, labelIndices = labels.indices)
    mldr.tv = mldr_from_dataframe(tv, labelIndices = labels.indices)
    
    
    ###################################################################
    y_true = data.frame(read.csv(paste0(FolderSplit, "/y_true.csv")))
    y_proba = data.frame(read.csv(paste0(FolderSplit, "/y_pred_proba.csv")))
    
    
    ####################################################################################
    y.true.2 = data.frame(sapply(y_true, function(x) as.numeric(as.character(x))))
    y.true.3 = mldr_from_dataframe(y.true.2, 
                                   labelIndices = seq(1,ncol(y.true.2)), 
                                   name = "y.true.2")
    y_proba = sapply(y_proba, function(x) as.numeric(as.character(x)))
    
    
    ########################################################################
    y_threshold_05 <- data.frame(as.matrix(fixed_threshold(y_proba,
                                                           threshold = 0.5)))
    write.csv(y_threshold_05, 
              paste(FolderSplit, "/y_pred_thr05.csv", sep=""),
              row.names = FALSE)
    
    ########################################################################
    y_threshold_card = lcard_threshold(as.matrix(y_proba), 
                                       mldr.tv$measures$cardinality,
                                       probability = F)
    write.csv(y_threshold_card, 
              paste(FolderSplit, "/y_pred_thrLC.csv", sep=""),
              row.names = FALSE)
    
    
    ##########################################################################    
    avaliacao(f = f, y_true = y.true.3, y_pred = y_proba,
              salva = FolderSplit, nome = "results-utiml")
    
    
    ##########################################################################    
    roc.curve(f = f, y_pred = y_proba, test = y.true.3, 
              Folder = FolderSplit, 
              nome = paste(FolderSplit, "/results-mldr.csv", sep=""))
    
    ##########################################################################    
    # auprc.curve <- function(y_true, y_proba, Folder, nome){
    auprc.curve(y_true = y_true, 
                y_proba = y_proba,
                Folder = FolderSplit, 
                nome = paste(FolderSplit, "/results-r.csv", sep=""))
    
    #########################################################################
    name.true = paste0(FolderSplit, "/y_true.csv")
    name.proba = paste0(FolderSplit, "/y_pred_proba.csv")
    
    str.execute = paste("python3 ", parameters$Directories$FolderPython,
                        "/curves.py ", 
                        name.true, " ", 
                        name.proba, " ", 
                        FolderSplit, " ", 
                        sep = "")
    res = system(str.execute)
    
    if(res!=0){
      #system(paste("rm -r ", parameters$Directories$FolderResults, sep=""))
      #stop("\n\n Something went wrong in python\n\n")
      message("\n\n Something went wrong in python \n\n")
    } else {
      message("\n\n PYTHON RAN OK! \n\n")
    }
    
    
    
    # f = f + 1
    gc()
  }
  
  gc()
  cat("\n##################################")
  cat("\n# END FUNCTION EVALUATE          #")
  cat("\n##################################")
  cat("\n\n\n\n")
}



###########################################################################
#
###########################################################################
gather.eval.python.silho <- function(parameters, folder){
  
  print(folder)
  
  final.runtime = data.frame()
  final.results = data.frame(apagar=c(0))
  final.results.2 = data.frame(apagar=c(0))
  final.model.size = data.frame()
  final.auprc = data.frame() 
  
  f = 1
  while(f<=parameters$Config$Number.Folds){
    
    
    #########################################################################
    folderSplit = paste(folder, "/Split-", f, sep="")
    
    cat("\nFold: ", f)
    
    # Lista de arquivos esperados para esse fold
    arquivos_esperados <- c(
      "results-python.csv",
      "results-utiml.csv",
      "results-mldr.csv",
      "results-r.csv",
      "model-size.csv",
      "runtime-python.csv",
      "r-auprc-per-label.csv"
    )
    
    # Caminhos completos
    arquivos_caminho <- file.path(folderSplit, arquivos_esperados)
    
    # Verificar existência
    arquivos_faltando <- arquivos_caminho[!file.exists(arquivos_caminho)]
    
    if (length(arquivos_faltando) > 0) {
      cat("\n\nErro: os seguintes arquivos não foram encontrados no fold", f, ":\n")
      print(arquivos_faltando)
      stop("\n\nExecução interrompida — arquivos ausentes.")
    }
    
    
    #########################################################################
    res.python = data.frame(read.csv(paste(folderSplit, 
                                           "/results-python.csv", sep="")))
    names(res.python) = c("Measures", paste0("Fold",f))
    
    res.utiml = data.frame(read.csv(paste(folderSplit, 
                                          "/results-utiml.csv", sep="")))
    names(res.utiml) = c("Measures", paste0("Fold",f))
    
    resultados = rbind(res.python, res.utiml)
    final.results = cbind(final.results, resultados)
    
    #########################################################################
    res.mldr = data.frame(read.csv(paste(folderSplit, 
                                         "/results-mldr.csv", sep="")))
    names(res.mldr ) = c("Measures", paste0("Fold",f))
    
    res.r = data.frame(read.csv(paste(folderSplit, 
                                      "/results-r.csv", sep="")))
    names(res.r) = c("Measures", paste0("Fold",f))
    
    resultados = rbind(res.mldr, res.r)
    final.results.2 = cbind(final.results.2, resultados)
    
    #########################################################################
    res.model.size = data.frame(read.csv(paste(folderSplit, 
                                               "/model-size.csv", sep="")))
    names(res.model.size) = "Bytes"
    resultado = data.frame(fold = f, res.model.size)
    final.model.size = rbind(final.model.size, resultado)
    
    #########################################################################
    res.runtime.python = data.frame(read.csv(paste(folderSplit, 
                                                   "/runtime-python.csv", sep="")))
    res.runtime.python = data.frame(fold = f, res.runtime.python)
    final.runtime = rbind(final.runtime, res.runtime.python)
    
    #########################################################################
    res.auprc = data.frame(read.csv(paste(folderSplit, 
                                          "/r-auprc-per-label.csv", sep="")))
    res.auprc = data.frame(fold = f, res.auprc)
    final.auprc = rbind(final.auprc, res.auprc)
    
    #################################
    # /tmp/gr-emotions/Global/Split-1
    system(paste0("rm -r ", folderSplit, "/model-size.csv", sep=""))
    system(paste0("rm -r ", folderSplit, "/r-auprc-per-label.csv", sep=""))
    system(paste0("rm -r ", folderSplit, "/results-mldr.csv", sep=""))
    system(paste0("rm -r ", folderSplit, "/results-python.csv", sep=""))
    system(paste0("rm -r ", folderSplit, "/results-r.csv", sep=""))
    system(paste0("rm -r ", folderSplit, "/results-utiml.csv", sep=""))
    system(paste0("rm -r ", folderSplit, "/runtime-python.csv", sep=""))
    system(paste0("rm -r ", folderSplit, "/y_pred_thr05.csv", sep=""))
    
    f = f + 1
    gc()
  } 
  
  final.results <- final.results[, !duplicated(colnames(final.results))]
  final.results = final.results[,-1]
  nome = paste0(folder, "/performance.csv")
  write.csv(final.results, nome, row.names = FALSE)
  
  final.results.2 <- final.results.2[, !duplicated(colnames(final.results.2))]
  final.results.2 = final.results.2[,-1]
  nome = paste0(folder, "/performance2.csv")
  write.csv(final.results.2, nome, row.names = FALSE)
  
  nome = paste0(folder, "/model-size.csv")
  write.csv(final.model.size, nome, row.names = FALSE)
  
  nome = paste0(folder, "/runtime.csv")
  write.csv(final.runtime, nome, row.names = FALSE)
  
  nome = paste0(folder, "/auprc-r.csv")
  write.csv(final.auprc, nome, row.names = FALSE)
  
  gc()
  cat("\n########################################################")
  cat("\n# END EVALUATED                                        #") 
  cat("\n########################################################")
  cat("\n\n\n\n")
}




##################################################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com                                   #
# Thank you very much!                                                                           #
################################################################################################

