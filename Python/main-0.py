import shutil
import sys
import io
import os
import numpy as np
import pandas as pd
import joblib
import pickle
import time
import importlib
from ecc import ECC
from sklearn.ensemble import RandomForestClassifier  
from sklearn.metrics import average_precision_score
import evaluation as eval
importlib.reload(eval)
import measures as ms
importlib.reload(ms)

if __name__ == '__main__':

    
    # obtendo argumentos da linha de comando
    train = pd.read_csv(sys.argv[1]) # conjunto de treino
    valid = pd.read_csv(sys.argv[2]) # conjunto de validação
    test = pd.read_csv(sys.argv[3])  # conjunto de teste
    start = int(sys.argv[4])         # inicio do espaço de rótulos  
    directory = sys.argv[5]          # diretório para salvar as predições 
     
    #train = pd.read_csv("/tmp/ecc-emotions/Dataset/emotions/CrossValidation/Tr/emotions-Split-Tr-1.csv")
    #valid = pd.read_csv("/tmp/ecc-emotions/Dataset/emotions/CrossValidation/Vl/emotions-Split-Vl-1.csv") 
    #test = pd.read_csv("/tmp/ecc-emotions/Dataset/emotions/CrossValidation/Ts/emotions-Split-Ts-1.csv")
    #start = 72    
    #directory = "/tmp/ecc-emotions/"
    
    # juntando treino com validação
    train = pd.concat([train,valid],axis=0).reset_index(drop=True)
    
    # treino: separando os atributos e os rótulos
    X_train = train.iloc[:, :start]    # atributos 
    Y_train = train.iloc[:, start:] # rótulos 
    
    # teste: separando os atributos e os rótulos
    X_test = test.iloc[:, :start]     # atributos
    Y_test = test.iloc[:, start:] # rótulos verdadeiros
    
    # obtendo os nomes dos rótulos
    labels_y_train = list(Y_train.columns)
    labels_y_test = list(Y_test.columns)
    
    # obtendo os nomes dos atributos
    attr_x_train = list(X_train.columns)
    attr_x_test = list(X_test.columns)
    
    # parametros do classificador base
    n_chains = 10
    random_state = 1234    
    n_estimators = 200

    # inicializa o classificador base
    rf = RandomForestClassifier(n_estimators = n_estimators, random_state = random_state)        
    model = ECC(rf, n_chains)

    start_time_fit = time.time()     
    try:
        model.fit(X_train, Y_train)

    except Exception as e:
        print(f"ERRO DURANTE O TREINAMENTO: {e}")    
    
    if os.path.exists(directory):
        print(f"Limpando a pasta: {directory}")
        shutil.rmtree(directory)

    sys.exit(1)
    end_time_fit = time.time()
    runtime_fit = end_time_fit - start_time_fit

    # predições probabilísticas
    start_time_predict = time.time()     
    y_pred_d = pd.DataFrame(model.predict_probabilities(X_test)) 
    end_time_predict = time.time()
    runtime_predict = end_time_predict - start_time_predict

    # criando o DataFrame
    df = pd.DataFrame({
        'Test_Type': ['runtime_fit', 'runtime_predict'],
        'Duration_seconds': [runtime_fit, runtime_predict]
    })
    
    test_time_path = os.path.join(directory, "runtime-python.csv")    
    df.to_csv(test_time_path, index=False)

    buffer = io.BytesIO()
    pickle.dump(model, buffer)    
    model_size_bytes = buffer.tell()
    pd.DataFrame({'Model_Size': [model_size_bytes]}).to_csv('model_size.csv', index=False)
    
    # renomeando as colunas
    y_pred_d.columns = labels_y_test
    
    # obtendo os rótulos verdadeiros
    y_true_a = np.array(Y_test)      # array
    y_true_d = pd.DataFrame(Y_test)  # dataframe
    
    # setando nome do diretorio e arquivo para salvar
    true = (directory + "/y_true.csv")          # salva os rótulos verdadeiros
    proba = (directory + "/y_proba.csv")          # salva as predições binárias
    
    # salvando true labels and predict labels
    y_pred_d.to_csv(proba, index=False)
    y_true_d.to_csv(true, index=False)   
    
    y_true = pd.read_csv(true)
    y_proba = pd.read_csv(proba)

    res_curves = eval.multilabel_curves_measures(y_true, y_proba)    
    name = (directory + "/results-python.csv") 
    res_curves.to_csv(name, index=False)    


    