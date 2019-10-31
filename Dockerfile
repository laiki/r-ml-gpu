FROM nvidia/cuda:10.1-base

#FROM dceoy/rstudio-server

#ARG DEBIAN_FRONTEND=noninteractive

# ---- common stuff

#RUN apt-get update && \
#    apt-get -y install \
#      wget software-properties-common

# ---- R stuff
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
      r-base-dev r-recommended
    
# ---- NVIDIA stuff ----

#RUN   wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin && \
#  sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
#  sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub && \
#  sudo add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/ /" && \
#  sudo apt-get update && \
#  sudo apt-get install -y --no-install-recommends \
#        cuda 

# ---- python suff

#RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh -O ~/#anaconda.sh && \
#    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
#    rm ~/anaconda.sh && \
#    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
#    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
#    echo "conda activate base" >> ~/.bashrc
#ENV PATH="${PATH}:/opt/conda/bin" 
##RUN pip install --upgrade pip

#RUN R -e 'install.packages("remotes", repo = "https://cloud.r-project.org", clean = TRUE, Ncpus = 16)' -e 'remotes::install_github("rstudio/reticulate")' \
#  -e 'reticulate::virtualenv_create()'

# ---- ML stuff

#RUN apt-get update && \
#    apt-get -y upgrade

#RUN Rscript -e "install.packages('keras', clean = TRUE, Ncpus = 16)"
#RUN Rscript -e "keras::install_keras(method = 'conda', tensorflow = 'gpu')"


# ---- additional

#RUN apt-get -y --no-install-recommends install \
#    libbz2-dev libpcre3-dev  ocl-icd-opencl-dev 

#RUN Rscript -e "install.packages(c(\
#                         'tibbletime',  'corrr', 'h2o',  \
#                         'rsample', 'timetk', 'tidyquant', \
#                         'Quandl', 'ggpubr', \
#                         'optparse', 'dtplyr', \
#                         'profvis' \                         
#                        ), clean = TRUE, Ncpus = 16)"
#                  


