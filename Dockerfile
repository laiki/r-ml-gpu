FROM rocker/ml-gpu

#---- conda suff

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc
ENV PATH="${PATH}:/opt/conda/bin" 

#---- add usefull packages
RUN Rscript -e "install.packages( \
                   c( 'timetk', 'tidyquant', 'Quandl', 'ggpubr' \
                    , 'rsample', 'foreach', 'iterators' \
                    , 'tibletime', 'recipes' \
                    , 'corrr', 'optparse' \
                    , 'doParallel', 'profvis' \
                  ) , \
                  clean = TRUE, Ncpus = 16)"

#--- update h2o
RUN Rscript -e "if ('package:h2o' %in% search()) { detach('package:h2o', unload=TRUE) } ; \
                if ('h2o' %in% rownames(installed.packages())) { remove.packages('h2o') } ;\
                install.packages('h2o', type='source', \
                                  repos=c('http://h2o-release.s3.amazonaws.com/h2o/latest_stable_R'), \
                                  clean=TRUE)"

#---- Keras & Tensorflow
RUN Rscript -e "install.packages( 'keras', clean = TRUE, Ncpus = 16)" && \
    Rscript -e "keras::install_keras(method = 'conda', \
                                     tensorflow = 'gpu', \
                                     conda='/opt/conda/bin/conda')"

#---- OpenCL lib
#RUN wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/430.50/NVIDIA-Linux-#x86_64-430.50.run && \
#    chmod 755 NVIDIA-Linux-x86_64-430.50.run && \
#    ./NVIDIA-Linux-x86_64-430.50.run --accept-license \
#      --no-questions \
#      --no-backup \
#      --no-kernel-module \
#      --no-nouveau-check \
#      --no-distro-scripts \
#      --no-kernel-module-source \
#      --no-check-for-alternate-installs \
#      --no-drm \
#      --skip-depmod 
#    rm NVIDIA-Linux-x86_64-430.50.run 
    
#RUN apt-get update && \
#    apt-get install -y --no-install-recommends \
#        ocl-icd-opencl-dev

#RUN Rscript -e "install.packages('gpuR', clean = TRUE, Ncpus = 16)"


