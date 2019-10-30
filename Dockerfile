#FROM dceoy/rstudio-server

FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive
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

RUN set -e \
      && ln -s /dev/stdout /var/log/syslog \
      && curl -S -o /tmp/rstudio.deb \
        https://download2.rstudio.org/server/bionic/amd64/rstudio-server-$(cut -f 1 -d - /tmp/ver)-amd64.deb \
      && apt-get -y install /tmp/rstudio.deb \
      && rm -rf /tmp/rstudio.deb /tmp/ver

RUN set -e \
      && useradd -m -d /home/rstudio -g rstudio-server rstudio \
      && echo rstudio:rstudio | chpasswd \
      && echo "r-cran-repos=${CRAN_URL}" >> /etc/rstudio/rsession.conf

EXPOSE 8787

ENTRYPOINT ["/usr/lib/rstudio-server/bin/rserver"]
CMD ["--server-daemonize=0", "--server-app-armor-enabled=0"]



# ---- common stuff

RUN apt-get update && \
    apt-get -y install \
      wget software-properties-common

# ---- NVIDIA stuff ----

RUN   wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin && \
  sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
  sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub && \
  sudo add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/ /" && \
  sudo apt-get update && \
  sudo apt-get install -y --no-install-recommends \
        cuda ##nvidia-cuda-dev

# ---- python suff

RUN apt-get -y install wget
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


