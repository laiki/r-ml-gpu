FROM dceoy/rstudio-server

# ---- cuda stuff ----

RUN   apt-get update \
  &&  apt-get install -y --no-install-recommends \
        nvidia-cuda-dev 

# ---- python suff

RUN apt-get -y install wget
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc
ENV PATH="${PATH}:/opt/conda/bin" 
RUN pip install --upgrade pip

RUN R -e 'install.packages("remotes", repo = "https://cloud.r-project.org", clean = TRUE, Ncpus = 16)' -e 'remotes::install_github("rstudio/reticulate")' \
  -e 'reticulate::virtualenv_create()'

# ---- ML stuff

RUN Rscript -e "install.packages('keras', clean = TRUE, Ncpus = 16)"
RUN Rscript -e "keras::install_keras(method = 'conda', tensorflow = 'gpu')"

RUN apt-get -y install default-jdk && \
    apt-get update && \
    apt-get -y upgrade

# ---- additional

RUN Rscript -e "install.packages(c(\
                         'tibbletime',  'corrr', 'h2o',  \
                         'rsample', 'timetk', 'tidyquant', \
                         'Quandl', 'ggpubr', 'rJava', \
                         'rChoiceDialogs', 'optparse', 'dtplyr', \
                         'profvis', 'gpuR' \                         
                        ), clean = TRUE, Ncpus = 16)"

