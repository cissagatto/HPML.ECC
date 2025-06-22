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
    cat("\nFold: ", f)
    source(file.path(parameters$Config.File$FolderScripts, "libraries.R"))
    source(file.path(parameters$Config.File$FolderScripts, "utils.R"))
    
    
    ##########################################################################
    FolderSplit = paste(parameters$Directories$folderECC , "/Split-", f, sep="")
    if(dir.exists(FolderSplit)==FALSE){dir.create(FolderSplit)}
    
    
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
    
    start <- proc.time()
    res = print(system(str.execute))
    tempo = data.matrix((proc.time() - start))
    tempo = data.frame(t(tempo))
    write.csv(tempo, paste(FolderSplit, "/runtime-fold.csv", sep=""))
    
    if(res!=0){
      break
    }
    
    #f = f + 1
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
evaluate.ecc.python <- function(parameters){
  
  # f = 1
  avaliaParalel <- foreach (f = 1:parameters$Config.File$Number.Folds) %dopar%{
    # while(f<=parameters$Config.File$Number.Folds){
    
    #########################################################################
    cat("\nFold: ", f)
    
    ##########################################################################
    source(file.path(parameters$Config.File$FolderScripts, "libraries.R"))
    source(file.path(parameters$Config.File$FolderScripts, "utils.R"))

    ###########################################################################
    FolderSplit = paste(parameters$Directories$folderECC, "/Split-", f, sep="")
    if(dir.exists(FolderSplit)==FALSE){dir.create(FolderSplit)}
    
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
    #cat("\nGet the true and predict lables")
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
    y_threshold_05 = sapply(y_threshold_05, function(x) as.numeric(as.character(x)))
    y_threshold_card = sapply(y_threshold_card, function(x) as.numeric(as.character(x)))
    
    
    ##########################################################################    
    avaliacao(f = f, y_true = y.true.3, y_pred = y_proba,
              salva = FolderSplit, nome = "results-utiml")
    
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
gather.eval.python.silho <- function(parameters){
  
  final.runtime.r = data.frame()
  final.runtime.p = data.frame()
  final.results = data.frame(apagar=c(0))
  
  all.model.size.chains = data.frame(matrix(ncol = 0, nrow = 10))
  all.model.size = data.frame()
  
  all.time.test = data.frame()
  all.time.train.chains = data.frame(matrix(ncol = 0, nrow = 10))
  all.time.train = data.frame()
  
  f = 1
  while(f<=parameters$Config$Number.Folds){
    
    cat("\nFold: ", f)
    
    #########################################################################
    folderSplit = paste(parameters$Directories$folderECC,
                        "/Split-", f, sep="")
    
    #########################################################################
    res.python = data.frame(read.csv(paste(folderSplit, 
                                           "/results-python.csv", sep="")))
    names(res.python) = c("Measures", paste0("Fold-",f))
    
    res.utiml = data.frame(read.csv(paste(folderSplit, 
                                          "/results-utiml.csv", sep="")))
    names(res.utiml) = c("Measures", paste0("Fold-",f))
    
    resultados = rbind(res.python, res.utiml)
    final.results = cbind(final.results, resultados)
    
    #########################################################################
    res.model.size.chains = data.frame(read.csv(paste(folderSplit, 
                                                      "/model_sizes_chains.csv", 
                                                      sep="")))
    names(res.model.size.chains) = c("Chain_Index", paste0("Fold-",f))
    all.model.size.chains = cbind(all.model.size.chains, res.model.size.chains)
    
    #########################################################################
    res.model.size = data.frame(read.csv(paste(folderSplit, 
                                               "/model_sizes_total.csv", 
                                               sep="")))
    names(res.model.size) = "Size_Model"
    res.mode.size = data.frame(fold = f, res.model.size)
    all.model.size = rbind(all.model.size, res.mode.size)
    
    #########################################################################
    res.runtime.fold = data.frame(read.csv(paste(folderSplit, 
                                                 "/runtime-fold.csv", sep="")))
    res.runtime.fold = res.runtime.fold[,-1]
    res.runtime.fold = data.frame(fold=f, res.runtime.fold)
    final.runtime.r = rbind(final.runtime.r, res.runtime.fold)
    
    #########################################################################
    res.time.test = data.frame(read.csv(paste(folderSplit, 
                                              "/time_test.csv", 
                                              sep="")))
    res.time.test = data.frame(t(res.time.test))
    nomes.colunas = res.time.test[1,]
    names(res.time.test) = nomes.colunas
    res.time.test = res.time.test[-1,]
    rownames(res.time.test) <- NULL
    res.time.test = data.frame(fold = f, res.time.test)
    all.time.test = rbind(all.time.test, res.time.test)
    
    #########################################################################
    res.time.train.chains = data.frame(read.csv(paste(folderSplit, 
                                                      "/time_train_chains.csv", 
                                                      sep="")))
    colnames(res.time.train.chains) = c("Chain_Index", paste0("Fold-",f))
    all.time.train.chains = cbind(all.time.train.chains, res.time.train.chains)
    
    #########################################################################
    res.time.train = data.frame(read.csv(paste(folderSplit, 
                                               "/time_train_total.csv", 
                                               sep="")))
    res.time.train = data.frame(fold = f, res.time.train)
    all.time.train = cbind(all.time.train.chains, res.time.train)
    
    ###########################################################################
    system(paste0("rm -r ", folderSplit, "/results-python.csv", sep=""))
    system(paste0("rm -r ", folderSplit, "/results-utiml.csv", sep=""))
    system(paste0("rm -r ", folderSplit, "/model_sizes_chains.csv", sep=""))
    system(paste0("rm -r ", folderSplit, "/model_sizes_total.csv", sep=""))
    system(paste0("rm -r ", folderSplit, "/time_test.csv", sep=""))
    system(paste0("rm -r ", folderSplit, "/time_train_chains.csv", sep=""))
    system(paste0("rm -r ", folderSplit, "/time_train_total.csv", sep=""))
    system(paste0("rm -r ", folderSplit, "/runtime-fold.csv", sep=""))
    
    f = f + 1
    gc()
  } 
  
  
  setwd(parameters$Directories$folderECC)
  final.results <- final.results[, !duplicated(colnames(final.results))]
  final.results = final.results[,-1]
  write.csv(final.results, "performance.csv", row.names = FALSE)
  
  all.model.size.chains <- all.model.size.chains[, !duplicated(colnames(all.model.size.chains))]
  write.csv(all.model.size.chains, "model-size-chain.csv", row.names = FALSE)

  write.csv(all.model.size, "model-size.csv", row.names = FALSE)
  write.csv(final.runtime.r, "runtime-R-folds.csv", row.names = FALSE)
  write.csv(all.time.test, "runtime-test.csv", row.names = FALSE)
    
  all.time.train.chains <- all.time.train.chains[, !duplicated(colnames(all.time.train.chains))]
  write.csv(all.time.train.chains, "runtime-train-chain.csv", row.names = FALSE)
  
  all.time.train <- all.time.train[, !duplicated(colnames(all.time.train))]
  write.csv(all.time.train, "runtime-train.csv", row.names = FALSE)
  
  
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
