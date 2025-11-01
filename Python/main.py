##############################################################################
# ENSEMBLE CLASSIFIER CHAINS - MULTI-LABEL CLASSIFICATION                    #
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
 
 
import sys
import platform
import os
import io

from ecc import ECC

#FolderRoot = os.path.expanduser('/lapix/arquivos/elaine/HPML.ECC/Python')
#os.chdir(FolderRoot)
#current_directory = os.getcwd()
#sys.path.append('..')

# import joblib
import pickle
import time
import importlib

from joblib import dump
import pandas as pd
import numpy as np

from sklearn.ensemble import RandomForestClassifier  
# from sklearn.multioutput import ClassifierChain

import evaluation as eval
importlib.reload(eval)

import measures as ms
importlib.reload(ms)


if __name__ == '__main__':

     # =========== ARGUMENTS ===========    
    """
    train = pd.read_csv("/tmp/cc-GnegativeGO/Dataset/GnegativeGO/CrossValidation/Tr/GnegativeGO-Split-Tr-1.csv")
    valid = pd.read_csv("/tmp/cc-GnegativeGO/Dataset/GnegativeGO/CrossValidation/Vl/GnegativeGO-Split-Vl-1.csv")
    test = pd.read_csv("/tmp/cc-GnegativeGO/Dataset/GnegativeGO/CrossValidation/Ts/GnegativeGO-Split-Ts-1.csv")
    start = 1717    
    directory = "/tmp/cc-GnegativeGO/CC/Split-1"            
    """    

    train = pd.read_csv(sys.argv[1])
    valid = pd.read_csv(sys.argv[2])
    test = pd.read_csv(sys.argv[3])
    start = int(sys.argv[4])    
    directory = sys.argv[5]    
    
    # juntando treino com validação    
    train = pd.concat([train,valid],axis=0).reset_index(drop=True) 

    print("\n\n%==============================================%")
    print("train: ", sys.argv[1])
    print("valid: ", sys.argv[2])
    print("test: ", sys.argv[3])
    print("label start: ", sys.argv[4])
    print("output_dir: ", sys.argv[5])
    print("%==============================================%\n\n")


    # Features and labels separation
    X_train = train.iloc[:, :start]
    Y_train = train.iloc[:, start:]
    X_test = test.iloc[:, :start]
    Y_test = test.iloc[:, start:]

    # Labels and attributes names
    labels_y_train = list(Y_train.columns)
    labels_y_test = list(Y_test.columns)
    attr_x_train = list(X_train.columns)
    attr_x_test = list(X_test.columns)
    

    # =========== INITIALIZE MODEL ===========    
    random_state = 1234
    n_estimators = 200
    n_chains = 10
    rf_base = RandomForestClassifier(n_estimators=n_estimators, random_state=random_state)
    model = ECC(rf_base, n_chains=n_chains)    
    

    # =========== TRAIN ===========        
    start_time_train = time.time()     
    model.fit(X_train, Y_train)
    end_time_train = time.time()
    training = end_time_train - start_time_train    
    
        
    # =========== PREDICT PROBA ===========            
    start_time_proba = time.time()     
    proba_original = model.predict_probabilities(X_test)        
    end_time_proba = time.time()
    testing_proba = end_time_proba - start_time_proba 
    proba_df = pd.DataFrame(proba_original, columns=Y_test.columns)     


    # =========== PREDICT BIN ===========    
    start_time_test_bin = time.time()
    bin = model.predict(X_test)
    end_time_test_bin = time.time()
    testing_bin = end_time_test_bin - start_time_test_bin   
    bin_df = pd.DataFrame(bin, columns=Y_test.columns)     


    # ======= SALVANDO OS CSVS =======        
    true_name = os.path.join(directory, "y_true.csv")
    binary_name = os.path.join(directory, "y_pred_bin.csv")
    proba_name = os.path.join(directory, "y_pred_proba.csv")   
    Y_test.to_csv(true_name, index=False)        
    bin_df.to_csv(binary_name, index=False)
    proba_df.to_csv(proba_name, index=False)   

    
    # ======= SAVE TIME =======    
    df_timing = pd.DataFrame([[        
        training,
        testing_bin,
        testing_proba
    ]], columns=["training", "testing_bin", "testing_proba"])
    df_timing.to_csv(os.path.join(directory, "runtime-python.csv"), index=False)

   
    # =========== SAVE MEASURES ===========   
    metrics_df = eval.multilabel_curves_measures(Y_test, pd.DataFrame(proba_df, columns=labels_y_test))
    metrics_df.to_csv(os.path.join(directory, "results-python.csv"), index=False)           
    

    # =========== SAVE MODEL SIZE EM BYTES ===========
    model_buffer = io.BytesIO()
    pickle.dump(model, model_buffer)
    model_size_bytes = model_buffer.tell()
    model_size_df = pd.DataFrame({
        'model_size_bytes': [model_size_bytes]
    })
    model_size_df.to_csv(os.path.join(directory, "model-size.csv"), index=False)   
