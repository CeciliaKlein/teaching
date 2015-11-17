.. sectnum::

CRG RNAseq Data Analysis Hands-on
=================================

.. image:: assets/crg_blue_logo.jpg
    :height: 160px
    :width: 350px
    :scale: 50 %
    :align: right
    :alt: CRG Barcelona

The default directory is the rnaseq directory in your home, if nothing else is specified.

The RNA-seq data comes from brain samples (CNS) of mouse embryos at day 14 and day 18, done in 2 bioreplicates (1% of the reads are randomly sampled here).

In order to gain time, mapping, bigwig and quantification processes will only be done with one sample, however the analysis will use all 4 samples.

When you are waiting for a job to complete, please look at the input, output and help of the different programs run until that point.

..

  A cheatsheet with basic Linux and Cluster commands is available `here <cheatsheet.html>`_.

Access the CRG cluster
~~~~~~~~~~~~~~~~~~~~~~

Connect to the cluster login node::

    ssh -Y <username>@ant-login.linux.crg.es

RNAseq data
~~~~~~~~~~~

In order to get all the required files for the hands-on you need to run the following command in your terminal::

    /no_backup_isis/rg/projects/courses/rnaseq/setup2015nov

The setup script copies all the required files into the ``rnaseq`` folder under your ``HOME``. You can see the contents of the directory in a tree-like format as follows::

    tree ~/rnaseq

And this should be the output::

    /users/<group>/<username>/rnaseq
    ├── bin
    │   ├── BAMstats.py
    │   ├── dashboard2tsv.py
    │   ├── DESeq.analysis.R
    │   ├── edgeR.analysis.R
    │   ├── gff2gff.awk
    │   ├── ggheatmap.R
    │   ├── GO_enrichment.R
    │   ├── matrix_to_dist.R
    │   ├── normalize.matrix.R
    │   ├── retrieve_element_rpkms.py
    │   ├── rpkm_distribution.R
    │   ├── selectMatrixRows.sh
    │   ├── terrain.colors.3.txt
    │   ├── TrtoGn_RPKM.sh
    │   └── VennDiagram.R
    ├── data
    │   ├── mouse_cns_E14_rep1_1.fastq.gz
    │   ├── mouse_cns_E14_rep1_2.fastq.gz
    │   ├── mouse_cns_E14_rep2_1.fastq.gz
    │   ├── mouse_cns_E14_rep2_2.fastq.gz
    │   ├── mouse_cns_E18_rep1_1.fastq.gz
    │   ├── mouse_cns_E18_rep1_2.fastq.gz
    │   ├── mouse_cns_E18_rep2_1.fastq.gz
    │   ├── mouse_cns_E18_rep2_2.fastq.gz
    │   ├── quantifications.index.tsv
    │   └── quantifications.index.txt
    └── refs
        ├── mm65.long.ok.gtf
        ├── mouse_genome_mm9.fa.fai
        ├── mouse_genome_mm9_RSEM_index
        │   ├── RSEMref.chrlist
        │   ├── RSEMref.grp
        │   ├── RSEMref.idx.fa
        │   ├── RSEMref.n2g.idx.fa
        │   ├── RSEMref.seq
        │   ├── RSEMref.ti
        │   └── RSEMref.transcripts.fa
        └── mouse_genome_mm9_STAR_index -> /no_backup_isis/rg/projects/courses/rnaseq/refs/mouse_genome_mm9_STAR_index

    5 directories, 34 files

..

  **STAR** index folder has been soft linked because of its size

Reference gene annotation
~~~~~~~~~~~~~~~~~~~~~~~~~

Look at the mouse gene annotation (ensembl v65, long genes)::

    more ~/rnaseq/refs/mm65.long.ok.gtf

Type ``q`` to exit the view.

Store information about gene Sec23a in a separate file::

    grep Sec23a ~/rnaseq/refs/mm65.long.ok.gtf > Sec23a.gff

Count the number of transcripts of this gene::

    awk '$3=="transcript"' Sec23a.gff | wc -l

Count the number of exons of this gene::

    awk '$3=="exon"' Sec23a.gff | wc -l

What is the biotype of the gene?

What is the biotype of each transcript of this gene?


Writing and editing files
~~~~~~~~~~~~~~~~~~~~~~~~~

There are several ways to write and edit files.
The most commonly used text editors are vi, emacs and gedit.

gedit
-----

To create a new file in the current folder just call ``gedit`` with the name of the file::

    gedit file.txt

Then save and close the file.

vi
--

To create a new file in the current folder just call ``vi`` with the name of the file::

    vi file.txt

Vi has several modes which are specified in the bottom part of screen.
When you just open the editor you cannot write on the file, because it is the command mode.
To start writing, type ``i``, and you will notice that the status in the bottom of the screen changed to ``INSERT``.
Now you can paste the text by right-click with the mouse and paste, or by pressing ``SHIFT+Insert``.
To go back to command mode press ``ESC``.
To save, make sure you are in command mode and type::

    :wq

To undo, press ``u`` when you are in command mode.



RNAseq data processing
~~~~~~~~~~~~~~~~~~~~~~

Have a look at the ``.rnaseqenv`` file to see how the environment for the course has been configured. We will use the ``rnaseq`` folder under your ``HOME`` as the base folder for the tutorial. Be sure you are inside that folder before doing any processing. Use the ``pwd`` command to check your current folder and ``cd`` to move to the ``rnaseq`` folder, e.g.::

    bash-4.1$ pwd
    /users/rg/epalumbo
    bash-4.1$ cd ~/rnaseq
    bash-4.1$ pwd
    /users/rg/epalumbo/rnaseq

Once you are inside the ``rnaseq`` folder, create a folder for storing the log files::

    mkdir logs


Fastq files and read QC
-----------------------
Have a look at one of our fastq files::

   zcat ~/rnaseq/data/mouse_cns_E14_rep1_1.fastq.gz | head -4

Create a folder for the fastqc output::

    mkdir fastqc

Create a bash script called ``run_fastqc.sh``.

This script should contain the following command::

    #!/bin/bash -e

    # load env
    . ~/rnaseq/.rnaseqenv

    # load module
    module load FastQC/0.11.2

    # run fastqc
    fastqc -o fastqc -f fastq ~/rnaseq/data/mouse_cns_E18_rep1_1.fastq.gz

Submit the job to the cluster::

    qsub -cwd -q RNAseq -l virtual_free=8G -N fastqc_rnaseq_course -e logs -o logs ./run_fastqc.sh

To monitor the status of the job, type ``qstat``.

You are able to display the fastqc results on the browser. Type the following in the terminal to open a browser showing your FastQC results::

    firefox ~/rnaseq/fastqc/mouse_cns_E18_rep1_1_fastqc.html

If you have an instance of firefox running in your local machine you need to modify the command as follows in order to be able to open the file::

    firefox --new-instance ~/rnaseq/fastqc/mouse_cns_E18_rep1_1_fastqc.html

Mapping
-------
Create a folder for the alignment steps::

    mkdir alignments

Create a bash script called ``run_star.sh`` with the following::

    #!/bin/bash -e

    # load env
    . ~/rnaseq/.rnaseqenv

    # load modules
    module load pigz/2.3.1-goolf-1.4.10-no-OFED
    module load STAR/2.4.2a-goolf-1.4.10-no-OFED

    # run the mapping step
    STAR --runThreadN 2 --genomeDir ~/rnaseq/refs/mouse_genome_mm9_STAR_index --readFilesIn ~/rnaseq/data/mouse_cns_E18_rep1_1.fastq.gz ~/rnaseq/data/mouse_cns_E18_rep1_2.fastq.gz --outSAMunmapped Within --outFilterType BySJout --outSAMattributes NH HI AS NM MD --readFilesCommand pigz -p2 -dc --outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM --outFileNamePrefix alignments/mouse_cns_E18_rep1_

Submit the job to the cluster::

    qsub -cwd -q RNAseq -l virtual_free=32G -pe smp 2 -N mapping_rnaseq_course -e logs -o logs ./run_star.sh

When finished we can look at the bam file::

    samtools view -h ~/rnaseq/alignments/mouse_cns_E18_rep1_Aligned.sortedByCoord.out.bam | more

or at the mapping statistics that come with STAR::

    cat ~/rnaseq/alignments/mouse_cns_E18_rep1_Log.final.out

::

                                 Started job on |       Sep 15 17:12:35
                             Started mapping on |       Sep 15 17:16:32
                                    Finished on |       Sep 15 17:17:38
       Mapping speed, Million of reads per hour |       40.91

                          Number of input reads |       750067
                      Average input read length |       202
                                    UNIQUE READS:
                   Uniquely mapped reads number |       646593
                        Uniquely mapped reads % |       86.20%
                          Average mapped length |       200.63
                       Number of splices: Total |       335381
            Number of splices: Annotated (sjdb) |       330288
                       Number of splices: GT/AG |       331908
                       Number of splices: GC/AG |       2842
                       Number of splices: AT/AC |       399
               Number of splices: Non-canonical |       232
                      Mismatch rate per base, % |       0.20%
                         Deletion rate per base |       0.01%
                        Deletion average length |       1.93
                        Insertion rate per base |       0.01%
                       Insertion average length |       1.44
                             MULTI-MAPPING READS:
        Number of reads mapped to multiple loci |       26254
             % of reads mapped to multiple loci |       3.50%
        Number of reads mapped to too many loci |       887
             % of reads mapped to too many loci |       0.12%
                                  UNMAPPED READS:
       % of reads unmapped: too many mismatches |       0.00%
                 % of reads unmapped: too short |       10.04%
                     % of reads unmapped: other |       0.14%

And get some general statistics about mapping::

    # load env
    source ~/rnaseq/.rnaseqenv

    # load pysam module
    module load pysam

    # get mapping statistics
    BAMstats.py -i ~/rnaseq/alignments/mouse_cns_E18_rep1_Aligned.sortedByCoord.out.bam

    # unload all modules
    module purge


Transcript and gene expression quantification
---------------------------------------------

Create a folder for the quantifications::

    mkdir quantifications

Create a bash script called ``run_rsem.sh`` with the following::

    #!/bin/bash -e

    # load env
    . ~/rnaseq/.rnaseqenv

    # load module
    module load RSEM/1.2.21-goolf-1.4.10-no-OFED

    # get quantifications with RSEM
    rsem-calculate-expression --bam --estimate-rspd --no-bam-output --seed 12345 -p 2 --paired-end --forward-prob 0 alignments/mouse_cns_E18_rep1_Aligned.toTranscriptome.out.bam ~/rnaseq/refs/mouse_genome_mm9_RSEM_index/RSEMref quantifications/mouse_cns_E18_rep1

Submit the job to the cluster::

    qsub -cwd -q RNAseq -l virtual_free=16G -pe smp 2 -N isoforms_rnaseq_course -e logs -o logs ./run_rsem.sh

To obtain a matrix of gene FPKM values::

    cat ~/rnaseq/data/quantifications.index.txt | retrieve_element_rpkms.py -o encode -O mouse -e gene -v FPKM -d quantifications

To obtain a matrix of gene read counts::

    cat ~/rnaseq/data/quantifications.index.txt | retrieve_element_rpkms.py -o encode -O mouse -e gene -v expected_count -d quantifications


RNA-seq data analysis
~~~~~~~~~~~~~~~~~~~~~

Create a directory dedicated to the analyses::

    mkdir analysis

And move into it::

    cd analysis

Load the environment::

    . ~/rnaseq/.rnaseqenv

RPKM distribution
-----------------

Have a look at the distribution of RPKM values::

    rpkm_distribution.R -i ../quantifications/encode.mouse.gene.FPKM.idr_NA.tsv -l -p 0 -m ../data/quantifications.index.tsv -f age

To look at the plot::

    evince boxplot.log_T.psd_0.out.pdf

Clustering analysis
-------------------

Perform hierarchical clustering to check replicability::

    matrix_to_dist.R -i ../quantifications/encode.mouse.gene.FPKM.idr_NA.tsv --log10 -c pearson -o stdout | ggheatmap.R -i stdin --row_metadata ../data/quantifications.index.tsv --col_dendro --row_dendro -B 10 --matrix_palette=~/rnaseq/bin/terrain.colors.3.txt --rowSide_by age --matrix_fill_limits 0.85,1 -o cns.heatmap.pdf

Look at the clustering.

Differential gene expression
----------------------------

Run the DE with the edgeR package (be careful takes read counts and not rpkm values as input)::

    edgeR.analysis.R -i ../quantifications/encode.mouse.gene.expected_count.idr_NA.tsv -m ../data/quantifications.index.tsv -f age

Write a list of the genes overexpressed after 18 days, according to edgeR analysis::

    awk '$NF<0.01 && $4>2{print $1"\tover18"}' edgeR.cpm1.n2.out.tsv > edgeR.0.01.overE18.txt

Write a list of the genes overexpressed after 14 days, according to edgeR analysis::

    awk '$NF<0.01 && $4<-2 {print $1"\tover14"}' edgeR.cpm1.n2.out.tsv > edgeR.0.01.overE14.txt

Count how many overexpressed genes there are in each stage::

    wc -l edgeR.0.01.over*.txt

Show the results in a heatmap::

    (echo -e "gene\tedgeR"; cat edgeR.0.01.over*.txt) > gene.edgeR.tsv
    cut -f1 gene.edgeR.tsv | tail -n+2 | selectMatrixRows.sh - ../quantifications/encode.mouse.gene.FPKM.idr_NA.tsv | ggheatmap.R -W 5 -H 9 --col_metadata ../data/quantifications.index.tsv --colSide_by age --col_labels labExpId --row_metadata gene.edgeR.tsv --merge_row_mdata_on gene --rowSide_by edgeR --row_labels none -l -p 0.1 --col_dendro --row_dendro -o heatmap.edgeR.pdf

GO enrichment
-------------

Prepare a file with the list of all the genes in the annotation::

    awk '{split($10,a,"\""); print a[2]}' ~/rnaseq/refs/mm65.long.ok.gtf | sort -u > universe.txt

Launch the GO enrichment script for the Biological Processes, Molecular Function and Cellular Components in the set of genes overexpressed in E14::

    cut -f1 edgeR.0.01.overE14.txt | GO_enrichment.R -u universe.txt -G stdin -c BP -o edgeR.overE14 -s mouse
    cut -f1 edgeR.0.01.overE14.txt | GO_enrichment.R -u universe.txt -G stdin -c MF -o edgeR.overE14 -s mouse
    cut -f1 edgeR.0.01.overE14.txt | GO_enrichment.R -u universe.txt -G stdin -c CC -o edgeR.overE14 -s mouse

The results can be visualized in the browser, pasting the following paths in the search line::

    firefox ~/rnaseq/analysis/edgeR.overE14.BP.html
    firefox ~/rnaseq/analysis/edgeR.overE14.MF.html
    firefox ~/rnaseq/analysis/edgeR.overE14.CC.html

You can repeat the same for the genes overexpressed in E18::

    cut -f1 edgeR.0.01.overE18.txt | GO_enrichment.R -u universe.txt -G stdin -c BP -o edgeR.overE18 -s mouse
    cut -f1 edgeR.0.01.overE18.txt | GO_enrichment.R -u universe.txt -G stdin -c MF -o edgeR.overE18 -s mouse
    cut -f1 edgeR.0.01.overE18.txt | GO_enrichment.R -u universe.txt -G stdin -c CC -o edgeR.overE18 -s mouse


.. |ucsc_genome_browser| raw:: html

  <a href="http://genome.ucsc.edu/" target="_blank" style='padding:10px;font-weight:bold;font-family:Monaco,Menlo,Consolas,"Courier New",monospace;'>http://genome.ucsc.edu/</a>

Make bigWig file with RNAseq signal
-----------------------------------

Create a bash script called ``run_bigwig.sh`` with the following::

    #!/bin/bash -e

    # load env
    . ~/rnaseq/.rnaseqenv

    # load module
    module load BEDTools/2.21.0-goolf-1.4.10-no-OFED
    module load KentUtils/308-goolf-1.4.10-no-OFED


    # create bedgraph from mappings
    genomeCoverageBed -split -bg -ibam alignments/mouse_cns_E18_rep1_Aligned.sortedByCoord.out.bam > alignments/mouse_cns_E18_rep1_bedGraph.bed
    # generate bigwig from bedgraph
    bedGraphToBigWig alignments/mouse_cns_E18_rep1_bedGraph.bed ~/rnaseq/refs/mouse_genome_mm9.fa.fai alignments/mouse_cns_E18_rep1.bw

Submit the job to the cluster::

    qsub -cwd -q RNAseq -N bigwig_rnaseq_course -e logs -o logs ./run_bigwig.sh


Visualize your results in the UCSC genome browser
-------------------------------------------------

Add the gene expression track to the genome browser in bigWig format.
The bigWig files must be either uploaded or linked (if they are present somewhere online)

Go to the USCS genome browser web page:

|ucsc_genome_browser|

On the lefthand panel, click on ``Genomes``.
Click on ``Add custom track``.
Make sure the assembly information is as follows::

    group: Mammal, genome: Mouse, assembly: July 2007 (NCBI/mm9)

Paste the track specifications for each file in the box "Paste URLs or data"::

    track name=mouse_cns_E14_rep1.bw type=bigWig visibility=2 autoScale=off maxHeightPixels=30 color=0,149,347 viewLimits=0:30 bigDataUrl=http://genome.crg.es/~epalumbo/rnaseq/2015nov/mouse_cns_E14_rep1_Aligned.sortedByCoord.out.bw
    track name=mouse_cns_E14_rep2.bw type=bigWig visibility=2 autoScale=off maxHeightPixels=30 color=0,149,347 viewLimits=0:30 bigDataUrl=http://genome.crg.es/~epalumbo/rnaseq/2015nov/mouse_cns_E14_rep2_Aligned.sortedByCoord.out.bw
    track name=mouse_cns_E18_rep1.bw type=bigWig visibility=2 autoScale=off maxHeightPixels=30 color=69,139,0 viewLimits=0:30 bigDataUrl=http://genome.crg.es/~epalumbo/rnaseq/2015nov/mouse_cns_E18_rep1_Aligned.sortedByCoord.out.bw
    track name=mouse_cns_E18_rep2.bw type=bigWig visibility=2 autoScale=off maxHeightPixels=30 color=69,139,0 viewLimits=0:30 bigDataUrl=http://genome.crg.es/~epalumbo/rnaseq/2015nov/mouse_cns_E18_rep2_Aligned.sortedByCoord.out.bw

Click "Submit"
Go to the genome browser to look at some genes and their RNA-seq signal
