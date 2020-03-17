FROM tensorflow/tensorflow:2.1.0-gpu-py3

ARG DEBIAN_FRONTEND=noninteractive
## Set a default user. Available via runtime flag `--user docker` 
RUN addgroup rstudio && \
    useradd -g rstudio -m rstudio && \
    echo "rstudio:rstudio" | chpasswd

## 
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-utils ed less littler locales vim-tiny wget git htop net-tools && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.utf8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8
    
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade -y && \    
    apt-get install -y --no-install-recommends \
    r-base-dev && \
    echo "options(repos = 'https://cloud.r-project.org/')" >> /etc/R/Rprofile.site && \
    ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r && \
    ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r && \
    ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r && \
    ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r && \
    install.r docopt && \
    rm -rf /tmp/downloaded_packages/ 
   
#####

RUN apt-get install -y --no-install-recommends \
    gdebi-core && \
    wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.5033-amd64.deb && \
    gdebi -n rstudio-server-1.2.5033-amd64.deb

## automatically link a shared volume for kitematic users
VOLUME /home/rstudio/kitematic


ENTRYPOINT ["/usr/lib/rstudio-server/bin/rserver"]
CMD ["--server-daemonize=0", "--server-app-armor-enabled=0"]
  
#---- conda suff

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    /opt/conda/bin/conda update -n base -c defaults conda
ENV CONDA_ROOT="/opt/conda"
ENV PATH="${PATH}:$CONDA_ROOT/bin" 

RUN conda update -n base -c defaults conda --yes && \
    pip install --upgrade pip && \
    conda init --all

#---- add packages needed 
RUN apt-get update --fix-missing && \
    apt-get install -y \
      default-jre default-jdk \
      libxml2-dev \
       libssh2-1-dev \
      cmake pvm-dev openmpi-bin openmpi-common openmpi-doc libopenmpi-dev \
      libopenblas-dev pbzip2 \
      libcurl4-openssl-dev libssl-dev libxml2-dev

#      ocl-icd-opencl-dev 
#      libcurl4-gnutls-dev libssl-dev 

      
#---- cuda stuff ----
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin && \
    mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600                               && \
    wget http://developer.download.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda-repo-ubuntu1804-10-1-local-10.1.243-418.87.00_1.0-1_amd64.deb && \
    dpkg -i cuda-repo-ubuntu1804-10-1-local-10.1.243-418.87.00_1.0-1_amd64.deb                          && \
    apt-key add /var/cuda-repo-10-1-local-10.1.243-418.87.00/7fa2af80.pub                               && \
    apt-get update                                                                                      && \
    apt-get -y install cuda-10.1
ENV CUDA_HOME="/usr/local/cuda"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$CUDA_HOME/lib64/:$CUDA_HOME/lib/:$CUDA_HOME/extras/CUPTI/lib64"

RUN python3 -m pip install tensorflow-gpu==2.1.0 && \
    python3 -m pip install autokeras
     
#    /opt/conda/bin/conda create -n h2o4gpuenv -c h2oai -c conda-forge h2o4gpu-cuda10 python=3.6 --yes && \
#    su - rstudio -c "conda init --all" 

    

#    pip install h2o4gpu-0.3.2-cp36-cp36m-linux_x86_64.whl
    
#---- usefull R packages 

RUN Rscript  -e "install.packages('xml2',             clean = TRUE, Ncpus = 16)" \
             -e "install.packages('readr',            clean = TRUE, Ncpus = 16)" \
             -e "install.packages('timetk',           clean = TRUE, Ncpus = 16)" \
             -e "install.packages('tidyquant',        clean = TRUE, Ncpus = 16)" \
             -e "install.packages('ggpubr',           clean = TRUE, Ncpus = 16)" \
             -e "install.packages('rsample',          clean = TRUE, Ncpus = 16)" \
             -e "install.packages('foreach',          clean = TRUE, Ncpus = 16)" \
             -e "install.packages('iterators',        clean = TRUE, Ncpus = 16)" \
             -e "install.packages('tibbletime',       clean = TRUE, Ncpus = 16)" \
             -e "install.packages('recipes',          clean = TRUE, Ncpus = 16)" \
             -e "install.packages('corrr',            clean = TRUE, Ncpus = 16)" \
             -e "install.packages('optparse',         clean = TRUE, Ncpus = 16)" \
             -e "install.packages('doParallel',       clean = TRUE, Ncpus = 16)" \
             -e "install.packages(c('snow', 'doSNOW'),                           \
                                                      clean = TRUE, Ncpus = 16)" \
             -e "install.packages('profvis',          clean = TRUE, Ncpus = 16)" \
             -e "install.packages('fs',               clean = TRUE, Ncpus = 16)" \
             -e "install.packages('tidyverse',        clean = TRUE, Ncpus = 16)" \
             -e "install.packages('RSQLite',          clean = TRUE, Ncpus = 16)" \
             -e "install.packages('data.table',       clean = TRUE, Ncpus = 16)" \
             -e "install.packages('bestNormalize',    clean = TRUE, Ncpus = 16)" \
             -e "install.packages('dtplyr',           clean = TRUE, Ncpus = 16)" \
             -e "install.packages('devtools',         clean = TRUE, Ncpus = 16)" \
             -e "install.packages('ini',              clean = TRUE, Ncpus = 16)" \
             -e "install.packages('RCurl',            clean = TRUE, Ncpus = 16)" \
             -e "install.packages('reticulate',       clean = TRUE, Ncpus = 16)" \
             -e "install.packages(c('inline', 'ctv', 'Rmpi', 'future', 'doFuture', 'progressr'),        \
                                  clean = TRUE, Ncpus = 16)"                                            \
             -e "install.packages('h2o',  clean = TRUE, Ncpus = 16,                                     \
                                   type='source',                                                       \
                                   repos=c('http://h2o-release.s3.amazonaws.com/h2o/latest_stable_R'))" \
             -e "reticulate::use_python(python = '/opt/conda/bin/python')"                              \
             -e "install.packages('tensorflow',       clean = TRUE, Ncpus = 16)"                        \
             -e "tensorflow::install_tensorflow(version = '2.1.0', method = 'conda', conda = '/opt/conda/bin/conda')" \
             -e "devtools::install_github('rstudio/keras', force=T)"                                    \
             -e "keras::install_keras(method = 'conda',                                                 \
                                      version = 'default',                                              \
                                      tensorflow = '2.1.0-gpu',                                         \
                                      conda = '/opt/conda/bin/conda')"                                  \
             -e "install.packages('autokeras',        clean = TRUE, Ncpus = 16)"                        \
             -e "autokeras::install_autokeras( method = 'conda',                                        \
                                               conda = '/opt/conda/bin/conda',                          \
                                               tensorflow = '2.1.0-gpu',                                \
                                               version = 'default' )"                                   
#             -e "remotes::install_version('cowplot', version = '0.9.4', clean = TRUE, Ncpus = 16)                       

#---- usefull R stuff
# RUN Rscript -e "ctv::install.views('HighPerformanceComputing',  clean = TRUE, Ncpus = 16)" 

#---- special installation of R packages
RUN wget "https://cran.r-project.org/src/contrib/Archive/gputools/gputools_1.1.tar.gz" && \
    R CMD INSTALL --configure-args='--with-nvcc=/usr/local/cuda/bin/nvcc --with-r-include=/usr/share/R/include' gputools_1.1.tar.gz && \
    rm gputools_1.1.tar.gz

#RUN Rscript -e "devtools::install_github('h2oai/h2o4gpu', subdir = 'src/interface_r',          clean = TRUE, Ncpus = 16)"  \

    
EXPOSE 8787 54321

# h2o port 54321 seems only available when starting the image with --network=hoat
# e.g. docker run --rm    --gpus all   --network=host -v <local source dir>:/home/rstudio/src --name <identifier> laiki/r-ml-gpu:latest
# have fun ;)
