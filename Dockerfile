# Software installation, no database files
FROM condaforge/miniforge3:23.3.1-1

# build and run as root users since micromamba image has 'mambauser' set as the $USER
USER root

# set workdir to default for building; set to /data at the end
WORKDIR /

# Version arguments
# ARG variables only persist during build time
ARG HMAS_VERSION="1.2.0"
ARG HMAS_SRC_URL=https://github.com/ncezid-biome/HMAS-QC-Pipeline2/archive/refs/tags/v${HMAS_VERSION}.zip

# metadata labels
LABEL base.image="condaforge/miniforge3:23.3.1-1"
LABEL dockerfile.version="1"
LABEL software="HMAS-QC-Pipeline2"
LABEL software.version=${HMAS_VERSION}
LABEL description="A WDL wrapper around ncezid-biome/HMAS-QC-Pipeline2 for Terra.bio"
LABEL website="https://github.com/ncezid-biome/HMAS-QC-Pipeline2"
LABEL license="https://github.com/ncezid-biome/HMAS-QC-Pipeline2/blob/sample_base/LICENSE"
LABEL maintainer1="Inês Mendes"
LABEL maintainer.email1="ines.mendes@theiagen.com"

# install base dependencies; cleanup apt garbage
RUN apt-get update && apt-get install -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    curl \
    git \
    gnupg2 \
    squashfs-tools \
    unzip \
    wget && \
    apt-get autoclean && \
    rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log

# get the HMAS-QC-Pipeline2 latest commit
# remove build numbers and OSX specific packages from environment.yaml
# create conda environment
RUN wget --quiet "${HMAS_SRC_URL}" && \
    unzip v${HMAS_VERSION}.zip && \
    rm v${HMAS_VERSION}.zip && \
    mv -v HMAS-QC-Pipeline2-${HMAS_VERSION} /HMAS-QC-Pipeline2

RUN ls /HMAS-QC-Pipeline2/bin/

RUN mamba create -y --name hmas -c conda-forge -c bioconda -c defaults \
    python=3.9 \
    pandas=1.5.3 \
    cutadapt=3.5 \
    pear \
    vsearch=2.22.1 \
    multiqc=1.21 \
    fastqc=0.12.1 \
    nextflow=22.10.6 && \
    mamba clean -a -y

# set locale settings to UTF-8
# set the environment, put new hmas conda env in PATH by default
ENV PATH /opt/conda/envs/hmas/bin:$PATH \
    LC_ALL=C.UTF-8

# set final working directory to /data
WORKDIR /data

# run test profile
# RUN cd /HMAS-QC-Pipeline2/ && \
#     nextflow run /HMAS-QC-Pipeline2/hmas2.nf -profile test