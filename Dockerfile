FROM laiki/r-ml-gpu-lite:latest

         
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
             -e "install.packages('doMC',             clean = TRUE, Ncpus = 16)" \
             -e "install.packages(c('snow', 'doSNOW'),                           \
                                                      clean = TRUE, Ncpus = 16)" \
             -e "install.packages('profvis',          clean = TRUE, Ncpus = 16)" \
             -e "install.packages('fs',               clean = TRUE, Ncpus = 16)" \
             -e "install.packages('tidyverse',        clean = TRUE, Ncpus = 16)" \
             -e "install.packages('RSQLite',          clean = TRUE, Ncpus = 16)" \
             -e "install.packages('data.table',       clean = TRUE, Ncpus = 16)" \
             -e "install.packages('bestNormalize',    clean = TRUE, Ncpus = 16)" \
             -e "install.packages('dtplyr',           clean = TRUE, Ncpus = 16)" \
             -e "install.packages('ini',              clean = TRUE, Ncpus = 16)" \
             -e "install.packages('RCurl',            clean = TRUE, Ncpus = 16)" \
             -e "install.packages(c('inline', 'ctv', 'Rmpi', 'future', 'doFuture', 'progressr'),        \
                                  clean = TRUE, Ncpus = 16)"         
   
#---- special installation of R packages
RUN wget "https://cran.r-project.org/src/contrib/Archive/gputools/gputools_1.1.tar.gz" && \
    R CMD INSTALL --configure-args='--with-nvcc=/usr/local/cuda/bin/nvcc --with-r-include=/usr/share/R/include' gputools_1.1.tar.gz && \
    rm gputools_1.1.tar.gz

RUN Rscript  -e "install.packages('splitTools',       clean = TRUE, Ncpus = 16)" 
RUN Rscript  -e "install.packages('cloudml',          clean = TRUE, Ncpus = 16)" 
     
EXPOSE 8787 54321

# h2o port 54321 seems only available when starting the image with --network=host
# e.g. docker run --rm    --gpus all   --network=host -v <local source dir>:/home/rstudio/src --name <identifier> laiki/r-ml-gpu:latest
# have fun ;)
