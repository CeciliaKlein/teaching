FROM continuumio/miniconda

# install some utilities
RUN apt-get update --fix-missing && \
    apt-get install -y vim nano gawk pigz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# configure bioconda
RUN conda config --add channels bioconda && \
    conda config --add channels conda-forge 

# install required software
RUN conda create -y -n rnaseq \
    python=2 \
    samtools=1.3.1 \
    rsem=1.3.1 \
    star=2.6.1b \
    salmon=0.11.2

# install R packages
RUN conda install -y -n rnaseq \
    r-ggplot2=2.2.1 \
    r-optparse=1.6.0 \
    r-ggdendro=0.1_20 \
    bioconductor-edger=3.22.5 \
    bioconductor-gostats=2.44.0 \
    bioconductor-go.db=3.4.1 \
    bioconductor-org.mm.eg.db=3.4.1

# add analysis scripts
ADD scripts/* /opt/conda/envs/rnaseq/bin/

# Update bash.bashrc
RUN echo $'\n\
    # Activate rnaseq conda environment\n\
    . /opt/conda/etc/profile.d/conda.sh\n\
    conda activate rnaseq\n'\
    >> /etc/bash.bashrc