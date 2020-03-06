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
    echo 'options(repos = "https://cloud.r-project.org/")' >> /etc/R/Rprofile.site && \
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
ENV PATH="${PATH}:/opt/conda/bin" 

#---- add packages needed 
RUN apt-get update --fix-missing && \
    apt-get install -y \
      ocl-icd-opencl-dev \
      libcurl4-gnutls-dev libssl-dev \
      default-jre default-jdk \
      libxml2-dev \
      cuda-toolkit-10-1 libgit2-dev libssh2-1-dev \
      cmake pvm-dev openmpi-bin openmpi-common openmpi-doc libopenmpi-dev 
      
RUN pip install --upgrade pip && \
    pip install tensorflow-gpu==2.1.0

#---- usefull R packages 
# RUN "Rscript -e 'dir.create(path = Sys.getenv(\"R_LIBS_USER\"), recursive = T, showWarnings = F)' \
# -e 'install.packages(  \
#                      c(\"xml2\"             \
#                      , \"readr\"            \
#                      , \"timetk\"           \
#                      , \"tidyquant\"        \
#                      , \"remotes\"          \                                                                             
#                      , \"ggpubr\"           \
#                      , \"rsample\"          \
#                      , \"foreach\"          \
#                      , \"iterators\"        \
#                      , \"tibbletime\"       \
#                      , \"recipes\"          \
#                      , \"corrr\"            \
#                      , \"optparse\"         \
#                      , \"doParallel\"       \
#                      , \"snow\"             \
#                      , \"doSNOW\"           \
#                      , \"profvis\"          \
#                      , \"fs\"               \
#                      , \"tidyverse\"        \
#                      , \"RSQLite\"          \
#                      , \"data.table\"       \
#                      , \"bestNormalize\"    \
#                      , \"dtplyr\"           \
#                      , \"devtools\"         \
#                      , \"ini\"              \
#                      , \"RCurl\"            \
#                      , \"reticulate\"       \
#                      , \"keras\"            \
#                      , \"autokeras\"        \
#                      , \"inline\"           \
#                      , \"ctv\"              \
#                      , \"Rmpi\"             \
#                      , \"future\"           \
#                      , \"doFuture\"         \
#                      , \"progressr\"        \
#                      , \"h2o4gpu\" )        \
#                      , clean = TRUE         \
#                      , Ncpus = 16)'         \
# -e 'keras::install_keras( method = \"conda\",                                      \
#                         version = \"default\",                                     \
#                         tensorflow = \"2.1.0-gpu\",                                \
#                         conda = \"/opt/conda/bin/conda\")'                         \
# -e 'autokeras::install_autokeras( method = \"conda\",                              \
#                                 conda = \"/opt/conda/bin/conda\",                  \
#                                 tensorflow = \"2.1.0-gpu\",                        \
#                                 version = \"default\" )'                           \
# -e 'install.packages(\"h2o\", lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16,   \
#                     type=\"source\",                                                       \
#                     repos=c(\"http://h2o-release.s3.amazonaws.com/h2o/latest_stable_R\"))' "
#                                                   
#                     , lib=Sys.getenv(\"R_LIBS_USER\")  \


#                              -e 'install.packages(\"remotes\",         lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
#                              -e 'remotes::install_version(\"cowplot\", version = \"0.9.4\",                                        \
#                                                                        lib=Sys.getenv(\"R_LIBS_USER\"), build_vignettes = TRUE)'   \


RUN su - rstudio -c "Rscript -e 'dir.create(path = Sys.getenv(\"R_LIBS_USER\"), recursive = T, showWarnings = F)'                  \
                             -e 'install.packages(\"xml2\",            lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"readr\",           lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"timetk\",          lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"tidyquant\",       lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"ggpubr\",          lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"rsample\",         lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"foreach\",         lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"iterators\",       lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"tibbletime\",      lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"recipes\",         lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"corrr\",           lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"optparse\",        lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"doParallel\",      lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(c(\"snow\", \"doSNOW\"),                                                         \
                                                                       lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"profvis\",         lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"fs\",              lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"tidyverse\",       lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"RSQLite\",         lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"data.table\",      lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"bestNormalize\",   lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"dtplyr\",          lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"devtools\",        lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"ini\",             lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"RCurl\",           lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"reticulate\",      lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"keras\",           lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'keras::install_keras(method = \"conda\",                                                          \
                                                                 version = \"default\",                                            \
                                                                 tensorflow = \"2.1.0-gpu\",                                       \
                                                                 conda = \"/opt/conda/bin/conda\")'                                \
                             -e 'install.packages(\"autokeras\",       lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'autokeras::install_autokeras( method = \"conda\",                                                 \
                                                                         conda = \"/opt/conda/bin/conda\",                         \
                                                                         tensorflow = \"2.1.0-gpu\",                               \
                                                                         version = \"default\" )'                                  \
                             -e 'install.packages(\"inline\",          lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"ctv\",             lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"Rmpi\",            lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(c(\"future\", \"doFuture\"),                                                     \
                                                                       lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"progressr\",       lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' \
                             -e 'install.packages(\"h2o\",             lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16,  \
                                                                       type=\"source\",                                            \
                                                                       repos=c(\"http://h2o-release.s3.amazonaws.com/h2o/latest_stable_R\"))' \
                             -e 'install.packages(\"h2o4gpu\",         lib=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)' "
#                              -e 'update.packages(ask=FALSE,            lib.loc=Sys.getenv(\"R_LIBS_USER\"), clean = TRUE, Ncpus = 16)'  "



#---- special installation of R packages
RUN "wget https://cran.r-project.org/src/contrib/Archive/gputools/gputools_1.1.tar.gz" && \
    "R CMD INSTALL --configure-args='--with-nvcc=/usr/local/cuda/bin/nvcc --with-r-include=/usr/share/R/include' gputools_1.1.tar.gz" && \
    "rm gputools_1.1.tar.gz"

    
EXPOSE 8787 54321

#
#---- usefull R packages 
## RUN Rscript -e 'ctv::install.views(\"HighPerformanceComputing\",  clean = TRUE, Ncpus = 16)' 
#                             -e 'remotes::install_version(\"cowplot\", version = \"0.9.4\",                             \
# RUN Rscript -e 'ctv::install.views(\"HighPerformanceComputing\",  clean = TRUE, Ncpus = 16)' 
