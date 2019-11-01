FROM nvidia/cuda:10.1-base

#FROM dceoy/rstudio-server
# run it with docker run --gpus all r_ml nvidia-smi

ARG DEBIAN_FRONTEND=noninteractive

# ---- common stuff

RUN apt-get update && \
    apt-get -y install \
      wget software-properties-common

# ---- R base
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
      r-base-dev r-recommended

# ---- R server
ENV CRAN_URL https://cloud.r-project.org/

ADD https://s3.amazonaws.com/rstudio-server/current.ver /tmp/ver

RUN set -e \
      && ln -sf /bin/bash /bin/sh

RUN set -e \
      && apt-get -y update \
      && apt-get -y install --no-install-recommends --no-install-suggests \
        apt-transport-https apt-utils ca-certificates gnupg \
      && echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" \
        > /etc/apt/sources.list.d/r.list \
      && apt-key adv --keyserver keyserver.ubuntu.com \
        --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
      && apt-get -y update \
      && apt-get -y dist-upgrade \
      && apt-get -y install --no-install-recommends --no-install-suggests \
        curl libapparmor1 libclang-dev libedit2 libssl1.0.0 lsb-release \
        psmisc r-base sudo \
      && apt-get -y autoremove \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*
    
# ---- python suff

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc
ENV PATH="${PATH}:/opt/conda/bin" 
#RUN pip install --upgrade pip

RUN R -e 'install.packages("remotes", repo = "https://cloud.r-project.org", clean = TRUE, Ncpus = 16)' -e 'remotes::install_github("rstudio/reticulate")' \
  -e 'reticulate::virtualenv_create()'

# ---- ML stuff

RUN Rscript -e "install.packages('keras', clean = TRUE, Ncpus = 16)" && \
    Rscript -e "keras::install_keras(method = 'conda', tensorflow = 'gpu')"


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


