# docker container image for UCSL
[![](https://images.microbadger.com/badges/version/mohitsharma44/ucsl-image.svg)](https://microbadger.com/images/mohitsharma44/ucsl-image)
[![Build Status](https://travis-ci.org/Mohitsharma44/ucsl-image.svg?branch=master)](https://travis-ci.org/Mohitsharma44/ucsl-image)
[![](https://images.microbadger.com/badges/image/mohitsharma44/ucsl-image.svg)](https://microbadger.com/images/mohitsharma44/ucsl-image "Get your own image badge on microbadger.com")

## Two ways to run the container
#### Directly using docker:
- docker run -it --rm --name ucsl -p 8888:8888 mohitsharma44/ucsl-image

#### Cloning this repo:
- git clone https://github.com/hk1953/ucsl-image
- cd ucsl-image
**To "build" the image from ground up:**
  - make build
**To "run" the image:**
  - make run
**To "test" the working:**
  - make test
**To "pull" the most recent image:**
  - make refresh
  
