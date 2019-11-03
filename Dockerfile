FROM rocker/ml-gpu

#RUN apt-get -y --no-install-recommends install \
#    ....

#RUN Rscript -e "pkgs <- c( 'timetk', 'tidyquant', 'Quandl', 'ggpubr' \
#                          , 'rsample', 'foreach', 'iterators' \
#                          , 'tibletime', 'recipes' \
#                          , 'corrr', 'optparse' \
#                          , 'doParallel', 'profvis' \
#                          , 'gpuR' \
#                        ) ; \
#                 install.packages(pkgs, clean = TRUE, Ncpus = 16)"

# --- update h2o
#RUN Rscript -e "if ('package:h2o' %in% search()) { detach('package:h2o', unload=TRUE) } ; \
#                if ('h2o' %in% rownames(installed.packages())) { remove.packages('h2o') } ;\
#                install.packages('h2o', type='source', \
#                                  repos=c('http://h2o-release.s3.amazonaws.com/h2o/#latest_stable_R'), \
#                                  clean=TRUE)"


