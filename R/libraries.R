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
# AUTO-INSTALL AND LOAD REQUIRED PACKAGES FOR MULTI-LABEL SCRIPT (v2025)
##############################################################################

# Load 'here' package and define project root folders
if (!require("here", quietly = TRUE)) install.packages("here", dependencies = TRUE)
library(here)
FolderRoot <- here::here()
FolderScripts <- here::here("R")

# List of required CRAN packages
cran_packages <- c(
  "foreign", "stringr", "tidyverse", "parallel", "rJava",
  "RWeka", "mldr", "utiml", "foreach", "doParallel", "caTools"
)

# Function to install and load packages
install_and_load <- function(pkg) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    message(paste("Installing package:", pkg))
    tryCatch({
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE, quietly = TRUE)
      message(paste("✅ Package", pkg, "successfully installed and loaded."))
    }, error = function(e) {
      message(paste("❌ Error installing package", pkg, ":", e$message))
    })
  } else {
    message(paste("✅ Package", pkg, "is already installed and loaded."))
  }
}

# Install and load all CRAN packages
invisible(lapply(cran_packages, install_and_load))

message("🎉 All packages have been successfully verified and loaded!")

##############################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com
# Thank you very much!
##############################################################################



#############################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com              #
# Thank you very much!                                                      #
#############################################################################
