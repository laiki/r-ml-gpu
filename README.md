# r-ml-gpu

Just another RStudio image.
Using Ubuntu distribution referenced by the Tensorflow gpu enabled base image.

run it by e.g.
  docker run \
    --gpus all \
    -p 8787:8787 \
    -v ~/:/home/rstudio \
    -w /home/rstudio \
    laiki/r-ml-gpu
  
and open localhost:8787 to access the RStudio server instance.
The credentials are 
  user:     rstudio
  password: rstudio
  
enjoy :)
