import sys
import numpy as np
import pandas as pd
from sklearn.base import clone
from sklearn.multioutput import ClassifierChain

class ECC:
    random_seed = 1234
    rng = np.random.default_rng(random_seed)

    def __init__(self,
                 model,
                 n_chains = 10,
                 ):
       self.model = model
       self.n_chains = n_chains
       self.chains = None
       
    def fit(self,
            x, ## dataframe
            y,
            ):
        self.chains = [ClassifierChain(self.model, order = "random") for i in range(self.n_chains)]
        for chain in self.chains:
            chain.fit(x, y)
        
    def predict(self,
                x):
        if self.chains is None:
            raise Exception('Oh no no no no!', 'Model has not been fitted yet.')
        return np.array([chain.predict(x) for chain in
                          self.chains]).mean(axis=0)

    def predict_probabilities(self,
                x):
        if self.chains is None:
            raise Exception('Oh no no no no!', 'Model has not been fitted yet.')
        return np.array([chain.predict_proba(x) for chain in
                          self.chains]).mean(axis=0)