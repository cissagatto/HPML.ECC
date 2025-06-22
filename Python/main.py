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


import sys
import platform
import os
import io

from ecc import ECC

FolderRoot = os.path.expanduser('~/HPML.ECC/Python')
os.chdir(FolderRoot)
current_directory = os.getcwd()
sys.path.append('..')

import joblib
import pickle
import time
import importlib

from joblib import dump
import pandas as pd
import numpy as np

from skmultilearn.problem_transform import BinaryRelevance
from sklearn.ensemble import RandomForestClassifier  

import evaluation as eval
importlib.reload(eval)
import measures as ms
importlib.reload(ms)


if __name__ == '__main__':

    # =========== ARGUMENTOS ===========
    train_path = sys.argv[1]   # train CSV path
    valid_path = sys.argv[2]   # valid CSV path
    test_path = sys.argv[3]    # test CSV path
    start_label = int(sys.argv[4])  # starting index for labels
    output_dir = sys.argv[5]   # output directory
    fold = sys.argv[6]         # fold name or identifier (se precisar)

    #train_path = "/tmp/ecc-emotions/Dataset/emotions/CrossValidation/Tr/emotions-Split-Tr-1.csv"
    #valid_path = "/tmp/ecc-emotions/Dataset/emotions/CrossValidation/Vl/emotions-Split-Vl-1.csv"
    #test_path = "/tmp/ecc-emotions/Dataset/emotions/CrossValidation/Ts/emotions-Split-Ts-1.csv"
    #start_label = 72 
    #output_dir = "/tmp/ecc-emotions/ECC/Split-1"
    #fold  = 1

    print("\n\n%==============================================%")
    print("train: ", sys.argv[1])
    print("valid: ", sys.argv[2])
    print("test: ", sys.argv[3])
    print("label start: ", sys.argv[4])
    print("output_dir: ", sys.argv[5])
    print("fold: ", sys.argv[6])
    print("%==============================================%\n\n")

    # =========== LEITURA DOS DADOS ===========
    train_df = pd.read_csv(train_path)
    valid_df = pd.read_csv(valid_path)
    test_df = pd.read_csv(test_path)

    # Concatenate train + valid
    train_full = pd.concat([train_df, valid_df], axis=0).reset_index(drop=True)

    # Features and labels separation
    X_train = train_full.iloc[:, :start_label]
    Y_train = train_full.iloc[:, start_label:]

    X_test = test_df.iloc[:, :start_label]
    Y_test = test_df.iloc[:, start_label:]

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
    model.fit(X_train, Y_train)

        
    # =========== PREDICT ===========        
    start_time_proba = time.time()     
    proba = model.predict_proba(X_test)    
    end_time_proba = time.time()
    test_duration_proba = end_time_proba - start_time_proba  

    start_time_bin = time.time()     
    pred = model.predict(X_test)
    end_time_bin = time.time()
    test_duration_bin = end_time_bin - start_time_bin

    start_time_card = time.time()     
    card = model.predict_cardinality(X_test, Y_train)
    end_time_card = time.time()
    test_duration_card = end_time_card - start_time_card

    # criando o DataFrame
    df = pd.DataFrame({
        'Test_Type': ['predict_proba', 'predict_bin', 'predict_cardinality'],
        'Duration_seconds': [test_duration_proba, test_duration_bin, test_duration_card]
    })
    
    test_time_path = os.path.join(output_dir, "time_test.csv")    
    df.to_csv(test_time_path, index=False)


    # =========== SAVE PREDICTIONS ===========   
    probas_df = pd.DataFrame(proba, columns=labels_y_test)
    probas_path = os.path.join(output_dir, "y_pred_proba.csv")
    probas_df.to_csv(probas_path, index=False)

    #bin_df = pd.DataFrame(bin, columns=labels_y_test)
    #bin_path = os.path.join(output_dir, "y_pred_bin.csv")
    #bin_df.to_csv(bin_path, index=False)

    #card_df = pd.DataFrame(card, columns=labels_y_test)
    #card_path = os.path.join(output_dir, "y_pred_card.csv")
    #card_df.to_csv(card_path, index=False)

    Y_test.to_csv(os.path.join(output_dir, 'y_true.csv'), index=False)
    

    # =========== SAVE MODEL SIZE ===========      
    if not model.chain_model_sizes or model.total_model_size == 0:
        model.get_model_sizes()                
    df_chains = pd.DataFrame({
        'Chain_Index': range(1, len(model.chain_model_sizes) + 1),
        'Model_Size_Bytes': model.chain_model_sizes
    })
    df_chains.to_csv(os.path.join(output_dir, 'model_sizes_chains.csv'), index=False)
    df_total = pd.DataFrame({'Total_Model_Size_Bytes': [model.total_model_size]})
    df_total.to_csv(os.path.join(output_dir, 'model_sizes_total.csv'), index=False)

    #print("Saving to:", os.path.join(output_dir, 'model_sizes_chains.csv'))
    #print("Chain sizes:", model.chain_model_sizes)
    #print("Total size:", model.total_model_size)

    # =========== SAVE TRAINING TIME SIZE ===========              
    if not model.chain_train_times or model.train_time_total == 0:
        raise RuntimeError("Model has not been trained. Run model.fit() before saving training times.")    
    df_time = pd.DataFrame({
        'Chain_Index': range(1, len(model.chain_train_times) + 1),
        'Time_Seconds': model.chain_train_times
    })
    df_time.to_csv(os.path.join(output_dir, 'time_train_chains.csv'), index=False)    
    df_total_time = pd.DataFrame({'Time_Train_Total': [model.train_time_total]})
    df_total_time.to_csv(os.path.join(output_dir, 'time_train_total.csv'), index=False)

    #print("Training times saved to:", os.path.join(output_dir, 'time_train_chains.csv'))
    #print("Train chain times:", model.chain_train_times)
    #print("Total train time:", model.train_time_total)

    # =========== EVALUATION ===========          
    res_curves = eval.multilabel_curves_measures(Y_test, probas_df)    
    name = (output_dir + "/results-python.csv") 
    res_curves.to_csv(name, index=False)    
    
