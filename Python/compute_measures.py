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



########################################################################
#                                                                      #
########################################################################
import sys
# import platform
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

import pandas as pd
import numpy as np
from sklearn.metrics import (
    accuracy_score, hamming_loss, zero_one_loss,
    average_precision_score, f1_score, precision_score,
    recall_score, jaccard_score, roc_auc_score, precision_recall_curve,
    precision_recall_fscore_support, roc_curve, auc, coverage_error, 
    label_ranking_loss, classification_report
)

import confusion_matrix as cm
importlib.reload(cm)

import evaluation as eval
importlib.reload(eval)

import measures as ms
importlib.reload(ms)


if __name__ == '__main__':

    # =========== ARGUMENTOS ===========
    true_path = sys.argv[1]        # train CSV path
    proba_path = sys.argv[2]        # valid CSV path        
    output_dir = sys.argv[3]        # output directory
    fold = sys.argv[4]              # fold name or identifier (se precisar)

    true_path = "/tmp/ecc-birds/ECC/Split-1/y_true.csv"
    proba_path = "/tmp/ecc-birds/ECC/Split-1/y_pred_proba.csv"
    output_dir = "/tmp/ecc-birds/ECC/Split-1"   
    fold  = 1    

    print("\n\n%==============================================%")
    print("true: ", sys.argv[1])
    print("proba: ", sys.argv[2])    
    print("output_dir: ", sys.argv[3])
    print("Fold: ", sys.argv[4])
    print("%==============================================%\n\n")


    # =========== READING DATA ===========
    print("\n reading data")
    true_df = pd.read_csv(true_path)
    proba_df = pd.read_csv(proba_path)
    labels = list(true_df.columns)


    # =========== SAVE MEASURES ===========   
    # print("\n save multilabel evaluation measures")
    # metrics_df = eval.multilabel_curves_measures(true_df, proba_df)    
    # name = (output_dir + "/results-python1.csv") 
    # metrics_df.to_csv(name, index=False)   

    # print("\n\n ORIGINAL")
    # print(metrics_df)
    # print("\n\n")

    metrics_df_2, ignored_df = eval.multilabel_curve_metrics(true_df, proba_df)    
    name = (output_dir + "/results-python2.csv") 
    metrics_df_2.to_csv(name, index=False)
    

    #print("\n\n MODIFIED")
    #print(metrics_df_2)
    #print("\n\n")

    name = (output_dir + "/ignored-classes.csv") 
    ignored_df.to_csv(name, index=False)

    #res_bipartition = eval.multilabel_bipartition_measures(true_df, proba_df)   
    #res_ranking = eval.multilabel_ranking_measures(true_df, proba_df)
    #res_curves = eval.multilabel_curves_measures(true_df, proba_df)
    #res_lp = eval.multilabel_label_problem_measures(true_df, proba_df)

    #accuracy_score(true_df, proba_df)
    #average_precision_score(true_df, proba_df)
    #print(classification_report(true_df, proba_df, target_names=labels))




