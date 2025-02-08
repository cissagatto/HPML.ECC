# Hybrid Partitions for Multi-Label Classification with Ensemble of Classifier Chains
This code is part of my PhD research at PPG-CC/DC/UFSCar in colaboration with Katholieke Universiteit Leuven Campus Kulak Kortrijk Belgium. The R script runs in parallel the ECC made in python.


## How to cite 
@misc{Gatto2023, author = {Gatto, E. C.}, title = {Ensemble of Classifier Chains}, year = {2023}, publisher = {GitHub}, journal = {GitHub repository}, howpublished = {\url{https://github.com/cissagatto/Ensemble-Classifier-Chains}}}

## Source Code
This code source is composed of the project R to be used in RStudio IDE and also the following scripts R:

1. libraries.R
2. utils.R
4. ecc-python.R
5. ecc-mulan.R
6. ecc-utiml.R
7. run-python.R
8. run-mulan.R
9. run-utiml.R
10. start.R
11. config_files.R

_ecc-mulan, ecc-utimlm, run-mulan and run-utiml are not implemented._



## Preparing your experiment

### STEP 1
A file called _datasets-original.csv_ must be in the *root project directory*. This file is used to read information about the datasets and they are used in the code. We have 90 multilabel datasets in this _.csv_ file. If you want to use another dataset, please, add the following information about the dataset in the file:


| Parameter    | Status    | Description                                           |
|------------- |-----------|-------------------------------------------------------|
| Id           | mandatory | Integer number to identify the dataset                |
| Name         | mandatory | Dataset name (please follow the benchmark)            |
| Domain       | optional  | Dataset domain                                        |
| Instances    | mandatory | Total number of dataset instances                     |
| Attributes   | mandatory | Total number of dataset attributes                    |
| Labels       | mandatory | Total number of labels in the label space             |
| Inputs       | mandatory | Total number of dataset input attributes              |
| Cardinality  | optional  | **                                                    |
| Density      | optional  | **                                                    |
| Labelsets    | optional  | **                                                    |
| Single       | optional  | **                                                    |
| Max.freq     | optional  | **                                                    |
| Mean.IR      | optional  | **                                                    | 
| Scumble      | optional  | **                                                    | 
| TCS          | optional  | **                                                    | 
| AttStart     | mandatory | Column number where the attribute space begins * 1    | 
| AttEnd       | mandatory | Column number where the attribute space ends          |
| LabelStart   | mandatory | Column number where the label space begins            |
| LabelEnd     | mandatory | Column number where the label space ends              |
| Distinct     | optional  | ** 2                                                  |
| xn           | mandatory | Value for Dimension X of the Kohonen map              | 
| yn           | mandatory | Value for Dimension Y of the Kohonen map              |
| gridn        | mandatory | X times Y value. Kohonen's map must be square         |
| max.neigbors | mandatory | The maximum number of neighbors is given by LABELS -1 |


1 - Because it is the first column the number is always 1.

2 - [Click here](https://link.springer.com/book/10.1007/978-3-319-41111-8) to get explanation about each property.


### STEP 2
To run this experiment you need the _X-Fold Cross-Validation_ files and they must be compacted in **tar.gz** format. You can download these files, with 10-folds, ready for multilabel dataset by clicking [here](https://www.4shared.com/directory/ypgzwzjq/datasets-cross-validation.html). For a new dataset, in addition to including it in the **datasets-original.csv** file, you must also run this code [here](https://github.com/cissagatto/crossvalidationmultilabel). In the repository in question you will find all the instructions needed to generate the files in the format required for this experiment. The **tar.gz** file can be placed on any directory on your computer or server. The absolute path of the file should be passed as a parameter in the configuration file that will be read by **start.R** script. The dataset folds will be loaded from there.


### STEP 3
You need to have installed all the Java, Python and R packages required to execute this code on your machine or server. This code does not provide any type of automatic package installation!

You can use the [Conda Environment](https://1drv.ms/u/s!Aq6SGcf6js1mw4hbhU9Raqarl8bH8Q?e=IA2aQs) that I created to perform this experiment. Below are the links to download the files. Try to use the command below to extract the environment to your computer:

```
conda env create -file AmbienteTeste.yaml
```

See more information about Conda environments [here](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html) 

You can also run this code using the AppTainer [container](https://1drv.ms/u/s!Aq6SGcf6js1mw4hcVuz_IN8_Bh1oFQ?e=5NuyxX) that I'm using to run this code in a SLURM cluster. Please, check this [tutorial](https://rpubs.com/cissagatto/apptainer-slurm-r) (in portuguese) to see how to do that. 



### STEP 4
To run this code you will need a configuration file saved in *csv* format and with the following information:

| Config          | Value                                                                            | 
|-----------------|----------------------------------------------------------------------------------| 
| Dataset_Path    | Absolute path to the directory where the dataset's tar.gz is stored              |
| Temporary_Path  | Absolute path to the directory where temporary processing will be performed * 1  |
| Partitions_Path | Absolute path to the directory where the best partitions are                     |
| Implementation  | Must be "clus", "mulan", "python" or "utiml"                                     |
| Dataset_Name    | Dataset name according to *dataset-original.csv* file                            |
| Number_Dataset  | Dataset number according to *dataset-original.csv* file                          |
| Number_Folds    | Number of folds used in cross validation                                         |
| Number_Cores    | Number of cores for parallel processing                                          |


1 - Use directorys like */dev/shm*, *tmp* or *scratch* here.


You can save configuration files wherever you want. The absolute path will be passed as a command line argument.


## Software Requirements

This code was develop in RStudio Version 2022.07.2+576 "Spotted Wakerobin" Release (e7373ef832b49b2a9b88162cfe7eac5f22c40b34, 2022-09-06) for Ubuntu Bionic Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) QtWebEngine/5.12.8 Chrome/69.0.3497.128 Safari/537.36 

## Hardware Requirements
This code may or may not be executed in parallel, however, it is highly recommended that you run it in parallel. The number of cores can be configured via the command line (number_cores). If number_cores = 1 the code will run sequentially. In our experiments, we used 10 cores. For reproducibility, we recommend that you also use ten cores. This code was tested with the birds dataset in the following machine:

*System:*

Kernel: 5.4.0-136-generic x86_64 bits: 64 compiler: gcc v: 9.4.0. Desktop: Cinnamon 5.2.7 wm: muffin dm: LightDM. Distro: Linux Mint 20.3 Una. Base: Ubuntu 20.04 focal 

*Machine:*

Type: Laptop System: LENOVO product: 82CG v: IdeaPad Gaming 3 15IMH05 serial: <filter> Chassis: type: 10 v: IdeaPad Gaming 3 15IMH05 serial: <filter> Mobo: LENOVO model: LNVNB161216 v: SDK0R33126 WIN serial: <filter> UEFI: LENOVO v: EGCN33WW date: 12/24/2020 

*CPU:*

Topology: 6-Core model: Intel Core i7-10750H bits: 64 type: MT MCP arch: N/A | L2 cache: 12.0 MiB | flags: avx avx2 lm nx pae sse sse2 sse3 sse4_1 sse4_2 ssse3 vmx bogomips: 62399 | Speed: 4287 MHz min/max: 800/5000 MHz Core speeds (MHz): 1: 4264 2: 4240 3: 4254 | 4: 4240 5: 4273 6: 4275 7: 4267 8: 4223 9: 4275 10: 4226 11: 4264 12:4282

Then the experiment was executed in a cluster at UFSCar.


## Results
The results are stored in the _OUTPUT_ (or reports) directory.


## RUN
To run the code, open the terminal, enter the *~/Chains-Hybrid-Partition/R* directory, and type:

```
Rscript start.R [absolute_path_to_config_file]
```

Example:

```
Rscript start.R "~/Chains-Hybrid-Partition/R/config-files/python/jaccard/ward.D2/silho/eccp-GpositiveGO.csv"
```

## DOWNLOAD RESULTS
[Click here]


## Acknowledgment
- This study was financed in part by the Coordenação de Aperfeiçoamento de Pessoal de Nível Superior - Brasil (CAPES) - Finance Code 001.
- This study was financed in part by the Conselho Nacional de Desenvolvimento Científico e Tecnológico - Brasil (CNPQ) - Process number 200371/2022-3.
- The authors also thank the Brazilian research agencies FAPESP financial support.

# Contact
elainececiliagatto@gmail.com

## Links

| [Site](https://sites.google.com/view/professor-cissa-gatto) | [Post-Graduate Program in Computer Science](http://ppgcc.dc.ufscar.br/pt-br) | [Computer Department](https://site.dc.ufscar.br/) |  [Biomal](http://www.biomal.ufscar.br/) | [CNPQ](https://www.gov.br/cnpq/pt-br) | [Ku Leuven](https://kulak.kuleuven.be/) | [Embarcados](https://www.embarcados.com.br/author/cissa/) | [Read Prensa](https://prensa.li/@cissa.gatto/) | [Linkedin Company](https://www.linkedin.com/company/27241216) | [Linkedin Profile](https://www.linkedin.com/in/elainececiliagatto/) | [Instagram](https://www.instagram.com/cissagatto) | [Facebook](https://www.facebook.com/cissagatto) | [Twitter](https://twitter.com/cissagatto) | [Twitch](https://www.twitch.tv/cissagatto) | [Youtube](https://www.youtube.com/CissaGatto) |

# Thanks
