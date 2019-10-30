#!/bin/bash


# -------------- cuda stuff ----

function cudaInstallation(){
  sudo apt update
  sudo apt-get upgrade

  https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin 
  mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
  wget http://developer.download.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda-repo-ubuntu1804-10-1-local-10.1.243-418.87.00_1.0-1_amd64.deb
  apt-key add /var/cuda-repo-10-1-local-10.1.243-418.87.00/7fa2af80.pub
  dpkg -i cuda-repo-ubuntu1804-10-1-local-10.1.243-418.87.00_1.0-1_amd64.deb

  apt-get update
  apt-get -y install cuda nvidia-cuda-dev 
}

# ------ my add ons ------------

function condaInstalation(){
  apt-get install -y curl gpg apt-transport-https 
  echo "Install our public gpg key to trusted store" \
  curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor >  conda.gpg \
  install -o root -g root -m 644 conda.gpg /etc/apt/trusted.gpg.d/ \
  rm conda.gpg \
  echo "Add anaconda repo" \
  echo "deb [arch=amd64] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" > \
       /etc/apt/sources.list.d/conda.list \
  apt-get install -y conda
  # PATH="${PATH}:/opt/conda/bin" 
  apt-get install -y python3-venv python3-pip python3-virtualenv \
  R -e 'install.packages("remotes", repo = "https://cloud.r-project.org")' -e 'remotes::install_github("rstudio/reticulate")' \
    -e 'reticulate::virtualenv_create()'
}


function rest(){
RUN DEPENDENCIES=" \
    apt-utils \
    libxml2-dev \
    libgit2-dev \
    zlib1g-dev \
    libbz2-dev \
    libpcre3-dev \
    libpython3-dev \
    libopenblas-dev \
    pbzip2 \
    libglu1-mesa-dev \
    libpq-dev \
    ocl-icd-opencl-dev" \
  && apt-get install -y --no-install-recommends $DEPENDENCIES 

        
        
# ----  R packages needed -------

RUN   Rscript -e "install.packages(c(\
        'devtools'\
      , 'tidyverse' \
      ))" \
  &&  Rscript -e "install.packages('h2o', type='source', \
        repos=(c('http://h2o-release.s3.amazonaws.com/h2o/latest_stable_R')))" \
  &&  Rscript -e "install.packages(c(\
        'compiler', \
        'corrr',  \
        'data.table',  \
        'DBI',  \
        'doParallel',  \
        'dplyr',  \
        'dtplyr',  \
        'foreach',  \
        'fs',  \
        'ggpubr',  \
        'gpuR',  \
        'h2o',  \
        'ini',  \
        'iterators',  \
        'keras',  \
        'lubridate',  \
        'optparse',  \
        'parallel',  \
        'profvis',  \
        'Quandl',  \
        'rChoiceDialogs',  \
        'recipes',  \
        'rJava',  \
        'rlang',  \
        'rsample',  \
        'RSQLite',  \
        'stringr',  \
        'tcltk',  \
        'tibble',  \
        'tibbletime',  \
        'tidyquant',  \
        'tidyverse',  \
        'timetk',  \
        'tools',  \
        'utils' \
      ), dependencies = T, Ncpus = 16, quiet = F, clean = T)" 
##RUN Rscript -e "keras::install_keras(method = 'auto', tensorflow = 'gpu')"
        
}


cudaInstallation        

