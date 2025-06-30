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

#FolderRoot = os.path.expanduser('/lapix/arquivos/elaine/HPML.ECC/Python')
#os.chdir(FolderRoot)
#current_directory = os.getcwd()
#sys.path.append('..')

import time
import io
import pickle
import numpy as np
import pandas as pd
from sklearn.base import clone
from sklearn.multioutput import ClassifierChain
import os

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


    def fit(self, X, Y):
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
        
