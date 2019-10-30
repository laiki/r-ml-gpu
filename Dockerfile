FROM rocker/rstudio

# ------ my add ons ------------
RUN apt-get update \
	&& apt-get install -y curl gpg apt-transport-https \
	&& echo "Install our public gpg key to trusted store" \
  && curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor >  conda.gpg \
  && install -o root -g root -m 644 conda.gpg /etc/apt/trusted.gpg.d/ \
  && rm conda.gpg \
  && echo "Add anaconda repo" \
  && echo "deb [arch=amd64] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" > \
     /etc/apt/sources.list.d/conda.list 

ENV PATH="${PATH}:/opt/conda/bin" 
     
RUN apt-get update \
  && apt-get install -y conda \
  && DEPENDENCIES=" \
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

# -------------- cuda stuff ----

RUN   echo "deb  http://deb.debian.org/debian stretch main contrib non-free" >> /etc/apt/sources.list \
  &&  echo "deb-src  http://deb.debian.org/debian stretch main contrib non-free" >> /etc/apt/sources.list \
  &&  apt-get update \
  &&  apt-get install -y --no-install-recommends \
        nvidia-cuda-dev 
        
        
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
        'reticulate',  \
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
        

        

