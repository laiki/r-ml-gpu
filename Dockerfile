FROM rocker/ml-gpu

#RUN apt-get -y --no-install-recommends install \
#    libbz2-dev libpcre3-dev  ocl-icd-opencl-dev 

RUN Rscript -e "pkgs <- c( 'timetk', 'tidyquant', 'Quandl', 'ggpubr' \
                          , 'rsample', 'foreach', 'iterators' \
                          , 'tibletime', 'recipes' \
                          , 'corrr', 'optparse' \
                          , 'doParallel', 'profvis' \
                          , 'gpuR' \
                        ) ; \
                 install.packages(pkgs, clean = TRUE, Ncpus = 16)"


