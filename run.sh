docker run --rm -e PASSWORD=mysecret -p 8997:8787 \
  -v "$(pwd)":/home/rstudio/project aero
