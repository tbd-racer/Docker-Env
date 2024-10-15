# Docker-Env
Docker environments used for the project

There are two common environements that this project uses:
* Deploy
* Develop

The image the user intends to use can be built using the following command:
``` #!/bin/bash
python3 ./build_image.py <environment> <addtional args>

```
where `<envirnonment>` is replaced by `develop` or `deploy`

## Deploy Environment
This environment is based on the `dustynv/cudnn:8.9-r36.2.0` image. The image is based on Jetpack 6 (Ubuntu 22.04) with CUDA 12.2.2 and CUDNN support enabled. **This container is only availiable in an arm64 variant**

## Develop Environment
This environment is based on the `cuda:12.2.2-devel-ubuntu22.04` image. The image is an ubuntu 22.04 environment with cuda 12.2.2 installed and exists for both arm and x86 
