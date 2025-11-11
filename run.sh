docker run --rm \
  -e PASSWORD=mysecret \
  -p 8997:8787 \
  -p 8181:8181 \
  -v "$(pwd)":/home/rstudio/project \
  aero
