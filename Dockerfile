FROM tensorflow/tensorflow:2.0.0-gpu-py3

ARG DEBIAN_FRONTEND=noninteractive
## Set a default user. Available via runtime flag `--user docker` 
RUN addgroup rstudio && \
    useradd -g rstudio -m rstudio && \
    echo "rstudio:rstudio" | chpasswd

## 
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ed \
    less \
    littler \
    locales \
    r-base-dev \
    vim-tiny \
    wget \
 && ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
 && ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
 && ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
 && ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
 && install.r docopt \
 && rm -rf /tmp/downloaded_packages/

## Set the corresponding MRAN snapshot Repo (2014-09-08is the oldest available snapshot)
RUN echo 'options(repos = list(CRAN = "https://cloud.r-project.org/"))' >> /etc/R/Rprofile.site

## Configure default locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen en_US.utf8 \
 && /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8
   
#####

RUN apt-get install -y --no-install-recommends gdebi-core && \
    wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.5019-amd64.deb && \
    gdebi -n rstudio-server-1.2.5019-amd64.deb


## automatically link a shared volume for kitematic users
VOLUME /home/rstudio/kitematic

EXPOSE 8787

ENTRYPOINT ["/usr/lib/rstudio-server/bin/rserver"]
CMD ["--server-daemonize=0", "--server-app-armor-enabled=0"]
  
#---- conda suff

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc
ENV PATH="${PATH}:/opt/conda/bin" 

#---- add usefull packages
#RUN Rscript -e "install.packages( \
#                   c( 'timetk', 'tidyquant', 'Quandl', 'ggpubr' \
#                    , 'rsample', 'foreach', 'iterators' \
#                    , 'tibletime', 'recipes' \
#                    , 'corrr', 'optparse' \
#                    , 'doParallel', 'profvis' \
#                  ) , \
#                  clean = TRUE, Ncpus = 16)"

#--- update h2o
#RUN apt-get install -y --no-install-recommends \
#               default-sdk && \
#    Rscript -e "if ('package:h2o' %in% search()) { detach('package:h2o', unload=TRUE) } ; \
#                if ('h2o' %in% rownames(installed.packages())) { remove.packages('h2o') } ;\
#                install.packages('h2o', type='source', \
#                                  repos=c('http://h2o-release.s3.amazonaws.com/h2o/latest_stable_R'), \
#                                  clean=TRUE)"

#---- Keras & Tensorflow
#RUN Rscript -e "install.packages( 'keras', clean = TRUE, Ncpus = 16)" && \
#    Rscript -e "keras::install_keras(method = 'conda', \
#                                     tensorflow = '2.0.0-gpu', \
#                                     conda='/opt/conda/bin/conda')"


#RUN Rscript -e "install.packages('gpuR', clean = TRUE, Ncpus = 16)"


