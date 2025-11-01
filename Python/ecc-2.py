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
import time
import io
import pickle
import warnings

#FolderRoot = os.path.expanduser('/lapix/arquivos/elaine/HPML.ECC/Python')
#os.chdir(FolderRoot)
#current_directory = os.getcwd()
#sys.path.append('..')


import numpy as np
import pandas as pd

from sklearn.base import clone
from sklearn.multioutput import ClassifierChain


class ECC:
    """
    Ensemble of Classifier Chains (ECC) for multilabel classification,
    with timing, memory size tracking, and prediction export functionality.
    """

    def __init__(self, model, n_chains=10):             
        """
        Initialize the ECC ensemble.

        Purpose:
        --------
        Create an ensemble of classifier chains with a given base model and number of chains.

        Parameters:
        -----------
        model : scikit-learn compatible classifier
            The base classifier to be cloned in each chain.
        n_chains : int, default=10
            The number of classifier chains in the ensemble.

        Returns:
        --------
        None

        Example usage:
        --------------
        >>> from sklearn.ensemble import RandomForestClassifier
        >>> model = RandomForestClassifier()
        >>> ecc = ECC(model=model, n_chains=5)
        """
        self.model = model
        self.n_chains = n_chains
        self.chains = []                   # List of ClassifierChain objects
        self.chain_train_times = []        # Training time per chain
        self.train_time_total = 0          # Total training time
        self.test_time_total = 0           # Total prediction time (sum over all chains)
        self.chain_model_sizes = []        # Size of each chain in bytes
        self.total_model_size = 0          # Sum of all model sizes


    def fit2(self, X, Y):
        """
        Train the ECC ensemble on the input features and labels.

        Purpose:
        --------
        Fit multiple classifier chains on the training data, each with a random chain order,
        and measure the training time for each chain.

        Parameters:
        -----------
        X : array-like or pandas DataFrame
            Feature matrix for training.
        Y : array-like or pandas DataFrame
            Multi-label target matrix for training.

        Returns:
        --------
        None
            The method trains the ensemble chains in-place and records training times.

        Example usage:
        --------------
        >>> ecc = ECC(model, n_chains=10)
        >>> ecc.fit(X_train, Y_train)
        >>> print(ecc.train_time_total)       # total training time
        >>> print(ecc.chain_train_times)      # list of training times per chain
        """
        self.chains = []
        self.chain_train_times = []
        self.total_times = [0] * self.n_chains  # used also for prediction time summing
        self.train_time_total = 0

        for i in range(self.n_chains):
            chain = ClassifierChain(clone(self.model), order="random")
            start_time = time.time()
            chain.fit(X, Y)
            end_time = time.time()

            fit_time = end_time - start_time
            self.chains.append(chain)
            self.chain_train_times.append(fit_time)
            self.total_times[i] += fit_time

        self.train_time_total = sum(self.chain_train_times)


  #=========================================================#
    #                                                         #
    #=========================================================#
    def fit(self, X, Y):
        """
        Train the ensemble of classifier chains.

        Parameters:
        - X: Feature matrix (DataFrame or array-like).
        - Y: Multi-label targets (DataFrame or array-like).

        Returns:
        - None
        
        Example of usage:

        from sklearn.ensemble import RandomForestClassifier
        from sklearn.datasets import make_multilabel_classification
        from sklearn.multioutput import ClassifierChain
        from sklearn.base import clone
        import time

        # Creating a multi-label dataset
        X, Y = make_multilabel_classification(n_samples=100, n_features=20, n_classes=5, random_state=42)

        # Base model: RandomForestClassifier
        base_model = RandomForestClassifier()

        # Initialize the ECC model with 5 chains (for example) and 1 job (no parallelization)
        ecc_model = ECC(model=base_model, n_chains=5, n_jobs=1)

        # Train the ECC model using the fit method
        ecc_model.fit(X, Y)
        
        # After training, you can inspect the training times for each chain
        print(ecc_model.chain_train_times)
        print(f"Total training time: {ecc_model.train_time_total:.2f} seconds")
        
        """
        if len(X) != len(Y):
            raise ValueError("The number of samples in X and Y must be the same.")
        
        # Initialize chains with random order and independent models
        self.chains = [ClassifierChain(clone(self.model), order="random") for _ in range(self.n_chains)]
        
        # Start total training time
        start_time_total = time.time()

        for chain in self.chains:
            start_time_chain = time.time()
            chain.fit(X, Y)  # Fit each chain independently
            end_time_chain = time.time()
            self.chain_train_times.append(end_time_chain - start_time_chain)  # Save time for this chain
        
        # Save total training time
        self.train_time_total = time.time() - start_time_total


    def predict_proba(self, x):
        """
        Predict class probabilities for the input data.

        Objective:
            Computes the average predicted class probabilities from multiple chains/models.

        Parameters:
            x (array-like): Input data for which to predict class probabilities.

        Returns:
            np.ndarray: Array of predicted class probabilities averaged over all chains.

        Example:
            >>> model = YourModel()
            >>> model.fit(X_train, y_train)
            >>> probs = model.predict_proba(X_test)
        """
        if self.chains is None:
            raise Exception('Oh no no no no!', 'Model has not been fitted yet.')

        return np.array([chain.predict_proba(x) for chain in self.chains]).mean(axis=0)
    


    # ----------------------------------------------- #
    #                                                 #
    # ----------------------------------------------- #
    def predict1(self, x):
        """
        Realiza a previsão do modelo, agregando os resultados de várias cadeias.

        Parâmetros:
        -----------
        x : pd.DataFrame
            DataFrame contendo os dados de entrada (features) para previsão.
    
        Retorna:
        --------
        pd.DataFrame
            DataFrame contendo as previsões agregadas de todas as cadeias.
        """

        # Realiza previsões para cada uma das cadeias, usando __predictChain para cada índice de cadeia (0 a n_chains-1)
        # O resultado de cada cadeia é concatenado ao longo do eixo 0 (empilhando verticalmente).
        predictions = pd.concat([self.__predictChain(x, i) for i in range(self.n_chains)], axis=0)

        # print("PREDIÇÕES DENTRO DO PREDICT 1 antes de aplicar a média")
        # print(predictions)

        # Agrupa as previsões pelo índice, e aplica a média para combinar os resultados das múltiplas cadeias.
        # Iso é útil para suavizar ou agregá-las de forma consistente.
        return predictions.groupby(predictions.index).apply(np.mean) 
    


    # ----------------------------------------------- #
    #                                                 #
    # ----------------------------------------------- #
    def predict2(self, x):
        """
        Realiza a previsão do modelo, agregando os resultados de várias cadeias.

        Parâmetros:
        -----------
        x : pd.DataFrame
            DataFrame contendo os dados de entrada (features) para previsão.
    
        Retorna:
        --------
        pd.DataFrame
            DataFrame contendo as previsões agregadas de todas as cadeias para cada classe.
        """
        # Realiza previsões para cada uma das cadeias, usando __predictChain para cada índice de cadeia (0 a n_chains-1)
        # O resultado de cada cadeia é concatenado ao longo do eixo 0 (empilhando verticalmente).
        # predictions = pd.concat([self.__predictChain(x, i) for i in range(self.n_chains)], axis=0)        
        
        try:
            predictions = pd.concat([self.__predictChain(x, i) for i in range(self.n_chains)], axis=0)
            #print("PREDIÇÕES DENTRO DO PREDICT 2 antes de aplicar a média")
            #print(predictions)
        except Exception as e:
            print(f"Erro: {e}")
        
        predictions_aggregated = predictions.groupby(predictions.index).mean()
        # print("PREDIÇÕES AGREGADAS:")
        # print(predictions_aggregated)

        # Agora, para cada classe (coluna) no DataFrame, calcula-se a média das previsões para cada grupo de exemplos (linhas)
        # Agrupamos pelas linhas (index), e para cada grupo (classe), aplicamos a média        
        # return predictions.groupby(predictions.index).apply(np.mean)
        # predictions.mean(axis=0)  # Calcula a média por rótulo (coluna)

        # Agora, para cada amostra, selecionamos a maior previsão ao longo das cadeias
        # Agrupamos pelas amostras (index), e para cada grupo (classe), aplicamos o max
        # predictions_aggregated = predictions.groupby(predictions.index).max()

        return predictions_aggregated 

    

    def predict(self, X, threshold=0.5):
        """
        Make binary predictions based on a fixed probability threshold.

        Purpose:
        --------
        Generate binary multilabel predictions by applying a fixed threshold to the predicted probabilities.

        Parameters:
        -----------
        X : array-like or DataFrame
            Feature matrix for prediction.
        threshold : float, optional (default=0.5)
            Probability threshold used to convert probabilities into binary predictions.

        Returns:
        --------
        ndarray
            Binary predictions for each label, where probabilities equal or above the threshold are assigned 1, else 0.

        Example usage:
        --------------
        >>> ecc = ECC(model, n_chains=10)
        >>> ecc.fit(X_train, Y_train)
        >>> binary_predictions = ecc.predict(X_test, threshold=0.5)
        """
        probas = self.predict_proba(X)
        return (probas >= threshold).astype(int)

    

    def predict_cardinality(self, X, Y_train):
        """
        Make binary predictions using a threshold derived from the label cardinality in the training set.

        Purpose:
        --------
        Generate binary multilabel predictions by applying a threshold based on the average label cardinality 
        (average number of active labels per instance) calculated from the training labels.

        Parameters:
        -----------
        X : array-like or DataFrame
            Feature matrix for prediction.
        Y_train : array-like or DataFrame
            Multi-label target matrix used to compute the label cardinality threshold.

        Returns:
        --------
        ndarray
            Binary predictions for each label, thresholded according to the training label cardinality.

        Example usage:
        --------------
        >>> ecc = ECC(model, n_chains=10)
        >>> ecc.fit(X_train, Y_train)
        >>> predictions = ecc.predict_cardinality(X_test, Y_train)
        """
        cardinality = Y_train.sum(axis=1).mean() / Y_train.shape[1]
        probas = self.predict_proba(X)
        return (probas >= cardinality).astype(int)

    

    def get_model_sizes(self):
        """
        Measure the memory size (in bytes) of each trained chain and the total ensemble.

        Purpose:
        --------
        Calculate and return the memory size occupied by each chain classifier as well as the total size
        of the ensemble, for analyzing the model's memory consumption.

        Parameters:
        -----------
        None besides self.

        Returns:
        --------
        tuple (list, int)
            - A list with the size in bytes of each chain (list of integers).
            - The total size in bytes summing all chains (integer).

        Example usage:
        --------------
        >>> ecc = ECC(model, n_chains=5)
        >>> ecc.fit(X_train, Y_train)
        >>> sizes_per_chain, total_size = ecc.get_model_sizes()
        >>> print(f"Sizes per chain: {sizes_per_chain}")
        >>> print(f"Total ensemble size: {total_size} bytes")
        """
        if not self.chains:
            raise Exception('Model has not been fitted yet.')

        sizes = []
        for chain in self.chains:
            buffer = io.BytesIO()
            pickle.dump(chain, buffer)
            size = buffer.tell()
            sizes.append(size)

        self.chain_model_sizes = sizes           # Atualiza aqui!
        self.total_model_size = sum(sizes)
        return self.chain_model_sizes, self.total_model_size  



    def safe_predict_proba(self, X_test, Y_train):
        """
        Safely computes class probabilities for ECC, handling classifiers trained on a single class.

        Parameters
        ----------
        X_test : pandas.DataFrame or np.ndarray
            Feature matrix for prediction.
        
        Y_train : pandas.DataFrame
            Training label matrix used to determine output structure.

        Returns
        -------
        pandas.DataFrame
            Averaged predicted probabilities over all chains, shape (n_samples, n_labels).
        """
        import numpy as np
        import pandas as pd

        all_chain_probas = []

        for chain_idx, chain in enumerate(self.chains):
            n_samples = X_test.shape[0]
            n_labels = Y_train.shape[1]
            probas = np.zeros((n_samples, n_labels))
            X_aug = X_test.values

            for idx, estimator in enumerate(chain.estimators_):
                if idx > 0:
                    X_aug = np.hstack((X_test.values, probas[:, :idx]))

                try:
                    proba = estimator.predict_proba(X_aug)
                    if proba.shape[1] == 2:
                        probas[:, idx] = proba[:, 1]
                    else:
                        label_class = estimator.classes_[0]
                        probas[:, idx] = 1.0 if label_class == 1 else 0.0
                except Exception:
                    # Fallback if predict_proba fails for any reason
                    label_class = estimator.classes_[0]
                    probas[:, idx] = 1.0 if label_class == 1 else 0.0

            all_chain_probas.append(probas)

        mean_proba = np.mean(all_chain_probas, axis=0)
        return pd.DataFrame(mean_proba, columns=Y_train.columns)
    

    def safe_predict_proba_2(self, X_test, Y_train):
        """
        Safe probability prediction for ECC (Ensemble of Classifier Chains),
        handling single-class classifiers without breaking the internal chain structure.
        """        

        all_chain_probas = []

        for chain_idx, chain in enumerate(self.chains):
            try:
                # Try the normal sklearn way first
                chain_proba = chain.predict_proba(X_test)

                # Handle single-class columns manually if needed
                for i, estimator in enumerate(chain.estimators_):
                    if len(estimator.classes_) == 1:
                        val = 1.0 if estimator.classes_[0] == 1 else 0.0
                        chain_proba[:, i] = val
            except Exception as e:
                warnings.warn(f"Chain {chain_idx}: predict_proba failed ({e})")
                # Fallback: all zeros (or 0.5 if you prefer)
                chain_proba = np.zeros((X_test.shape[0], Y_train.shape[1]))

            all_chain_probas.append(chain_proba)

        # Average over all chains
        mean_proba = np.mean(all_chain_probas, axis=0)
        return pd.DataFrame(mean_proba, columns=Y_train.columns)


def safe_predict_proba_ecc(self, X_test, Y_train):
    """
    Robust safe probability prediction for ECC (Ensemble of Classifier Chains),
    handling single-class estimators without exceptions and preserving chain structure.

    Parameters
    ----------
    X_test : array-like or DataFrame
        Feature matrix for prediction.
    Y_train : DataFrame
        Training labels, used to define output shape and column order.

    Returns
    -------
    pd.DataFrame
        DataFrame with averaged predicted probabilities over all chains.
    """  
    n_samples = X_test.shape[0]
    n_labels = Y_train.shape[1]

    all_chain_probas = []

    # Iterate over each chain
    for chain in self.chains:
        probas = np.zeros((n_samples, n_labels))
        X_aug = X_test.values.copy()  # start with raw test features

        # Iterate over each estimator in the chain
        for idx, estimator in enumerate(chain.estimators_):
            if idx > 0:
                # Concatenate previous predictions as features
                X_aug = np.hstack((X_test.values, probas[:, :idx]))

            # Handle single-class estimators safely
            if len(estimator.classes_) == 1:
                val = 1.0 if estimator.classes_[0] == 1 else 0.0
                probas[:, idx] = val
            else:
                # Normal binary case
                proba = estimator.predict_proba(X_aug)
                probas[:, idx] = proba[:, 1]  # probability of class 1

        all_chain_probas.append(probas)

    # Average over all chains
    mean_proba = np.mean(all_chain_probas, axis=0)
    return pd.DataFrame(mean_proba, columns=Y_train.columns)
