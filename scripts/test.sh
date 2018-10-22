#!/bin/bash

# set bash flags
set -e
set -u
set -o pipefail

log() {
    printf "%-30s" "$@"
}

logTitle() {
    printf "\e[33;1m%s\e[0m\n" "$@"
}

logOK() {
    printf "\e[32;1m%s\e[0m\n" OK
}

logKO() {
    printf "\e[31;1m%s\e[0m\n" OK
}

logn() {
    echo "$@"
}

cleanup() {
    ec="$?"
    if [ $ec -ne 0 ] && [ -s error.log ]; then
        KEEP_TEST_DIR=YES
        logn ""
        log "Exit code: $ec"
        logn ""
        logn "== START ERROR LOG =="
        cat error.log
        logn "== END ERROR LOG =="
    fi
    if [ -z ${KEEP_TEST_DIR-} ]; then
        rm -rf $TEST_DIR
        logn ""
        logn "Cleaning up!"
        logn ""
    fi
}

# set trap
trap cleanup EXIT

# set data dir
RNASEQ=${1-/rnaseq}

# create temp dir and move there
TEST_DIR=$(mktemp -d)
cp ${RNASEQ}/md5s $TEST_DIR
cd $TEST_DIR
logTitle "Test RNA-seq course hands-on"
logn "----------------------------"
logn "test dir: $TEST_DIR"
logn ""

##################
# Gene Annotation
#
log "Gene annotation"
transcripts=$((zgrep Sec23a $RNASEQ/refs/mm65.long.ok.gtf.gz | awk '$3=="transcript"' | wc -l)  2> error.log)
exons=$((zgrep Sec23a $RNASEQ/refs/mm65.long.ok.gtf.gz | awk '$3=="exon"' | wc -l)  2> error.log)
[ $transcripts -eq 5 ] && [ $exons -eq 47 ]
## count protein-coding genes
pcgenes=$((zcat $RNASEQ/refs/mm65.long.ok.gtf.gz | awk '$3=="gene" && $0~/gene_type "protein_coding"/{ match($0, /gene_id "([^"]+)/, id); print id[1] }' | sort | wc -l)  2> error.log)
[ $pcgenes -eq 22380 ] && logOK

#########
# Mapping
#
log "Mapping"
(mkdir genomeIndex && STAR --runThreadN 2 \
     --runMode genomeGenerate \
     --genomeDir genomeIndex \
     --genomeFastaFiles $RNASEQ/refs/genome.fa \
     --sjdbGTFfile $RNASEQ/refs/anno.gtf \
     --genomeSAindexNbases 11) &> error.log
(mkdir alignments && STAR --runThreadN 2 \
     --genomeDir genomeIndex \
     --readFilesIn $RNASEQ/data/mouse_cns_E18_rep1_1.fastq.gz \
                   $RNASEQ/data/mouse_cns_E18_rep1_2.fastq.gz \
     --outSAMunmapped Within \
     --outFilterType BySJout \
     --outSAMattributes NH HI AS NM MD \
     --readFilesCommand pigz -p2 -dc \
     --outSAMtype BAM SortedByCoordinate \
     --quantMode TranscriptomeSAM \
     --outFileNamePrefix alignments/mouse_cns_E18_rep1_) &> error.log
nreads=$(samtools view -c alignments/mouse_cns_E18_rep1_Aligned.sortedByCoord.out.bam 2> error.log)
[ $nreads -eq 207544 ] && logOK || logKO

#########
# Signal
#
log "Signal"
STAR --runThreadN 2 \
     --runMode inputAlignmentsFromBAM \
     --inputBAMfile alignments/mouse_cns_E18_rep1_Aligned.sortedByCoord.out.bam \
     --outWigType bedGraph \
     --outWigStrand Unstranded \
     --outFileNamePrefix alignments/mouse_cns_E18_rep1_ \
     --outWigReferencesPrefix chr &> error.log
bedGraphToBigWig alignments/mouse_cns_E18_rep1_Signal.Unique.str1.out.bg \
                 /rnaseq/refs/genome.fa.fai \
                 alignments/mouse_cns_E18_rep1_uniq.bw &> error.log
logOK

#################
# Quantifications
#
log "Quantifications"
(mkdir txIndex && rsem-prepare-reference --gtf /rnaseq/refs/anno.gtf \
                      /rnaseq/refs/genome.fa \
                      txIndex/RSEMref) &> error.log
(mkdir quantifications && rsem-calculate-expression --num-threads 2 \
                          --bam \
                          --paired-end \
                          --estimate-rspd \
                          --forward-prob 0 \
                          --no-bam-output \
                          --seed 12345 \
                          alignments/mouse_cns_E18_rep1_Aligned.toTranscriptome.out.bam \
                          txIndex/RSEMref \
                          quantifications/mouse_cns_E18_rep1) &> error.log
(cat $RNASEQ/data/quantifications.index.txt \
| retrieve_element_rpkms.py --output encode \
                            --organism mouse \
                            --element gene \
                            --value FPKM \
                            --output_dir quantifications) 2> error.log
(cat $RNASEQ/data/quantifications.index.txt \
| retrieve_element_rpkms.py --output encode \
                            --organism mouse \
                            --element gene \
                            --value expected_count \
                            --output_dir quantifications) 2> error.log
logOK

##########
# Analysis
#
mkdir -p analysis
# RPKM distribution
log "RPKM distribution"
rpkm_distribution.R --input_matrix quantifications/encode.mouse.gene.FPKM.idr_NA.tsv \
                    --log --pseudocount 0 --metadata $RNASEQ/data/quantifications.index.tsv \
                    --fill_by age --palette $RNASEQ/palettes/cbbPalette.8.txt \
                    --outdir analysis &> error.log
logOK

# Clustering
log "Clustering"
matrix_to_dist.R --input_matrix quantifications/encode.mouse.gene.FPKM.idr_NA.tsv --log10 \
                 --cor pearson --output stdout | ggheatmap.R --input_matrix stdin \
                 --row_metadata $RNASEQ/data/quantifications.index.tsv \
                 --col_dendro --row_dendro --base_size 10 \
                 --matrix_palette $RNASEQ/palettes/terrain.colors.3.txt --rowSide_by age \
                 --matrix_fill_limits 0.85,1 --output analysis/cns.heatmap.pdf &> error.log
logOK

# DGE analysis
log "Differential gene expression"
edgeR.analysis.R --input_matrix quantifications/encode.mouse.gene.expected_count.idr_NA.tsv \
                 --metadata $RNASEQ/data/quantifications.index.tsv --fields age --output_dir analysis &> error.log
(awk '$NF<0.01 && $4>2{print $1"\tover18"}' analysis/edgeR.cpm1.n2.out.tsv \
    > analysis/edgeR.0.01.overE18.txt) 2> error.log
(awk '$NF<0.01 && $4<-2 {print $1"\tover14"}' analysis/edgeR.cpm1.n2.out.tsv \
    > analysis/edgeR.0.01.overE14.txt) 2> error.log
[ $((wc -l analysis/edgeR.0.01.overE14.txt | cut -d' ' -f1) 2> error.log) -eq 79 ]
[ $((wc -l analysis/edgeR.0.01.overE18.txt | cut -d' ' -f1) 2> error.log) -eq 82 ]
(join.py --file1 <((zcat $RNASEQ/refs/mm65.long.ok.gtf.gz | awk 'BEGIN{OFS="\t"}$3=="gene"{ match($0, /gene_id "([^"]+).+gene_type "([^"]+)/, var); print var[1],var[2]  }') 2> error.log) \
         --file2 <(cat analysis/edgeR.0.01.over*.txt 2> error.log) | sed '1igene\tedgeR\tgene_type' \
         > analysis/gene.edgeR.tsv) 2> error.log
(cut -f1 analysis/gene.edgeR.tsv | tail -n+2 | selectMatrixRows.sh - \
    quantifications/encode.mouse.gene.FPKM.idr_NA.tsv | ggheatmap.R --width 5 --height 9 \
    --col_metadata $RNASEQ/data/quantifications.index.tsv --colSide_by age \
    --col_labels labExpId --row_metadata analysis/gene.edgeR.tsv --merge_row_mdata_on gene \
    --rowSide_by edgeR,gene_type --row_labels none --log --pseudocount 0.1 --col_dendro --row_dendro \
    --matrix_palette $RNASEQ/palettes/terrain.colors.3.txt --output analysis/heatmap.edgeR.pdf) \
    &> error.log
logOK

# GO enrichment
log "GO enrichment"
(zcat $RNASEQ/refs/mm65.long.ok.gtf.gz | awk '{split($10,a,"\""); print a[2]}' | sort -u \
    > analysis/universe.txt) 2> error.log
(cut -f1 analysis/edgeR.0.01.overE14.txt | GO_enrichment.R --universe analysis/universe.txt \
    --genes stdin --categ BP --output analysis/edgeR.overE14 --species mouse) 2> error.log
(cut -f1 analysis/edgeR.0.01.overE14.txt | GO_enrichment.R --universe analysis/universe.txt \
    --genes stdin --categ MF --output analysis/edgeR.overE14 --species mouse) 2> error.log
(cut -f1 analysis/edgeR.0.01.overE14.txt | GO_enrichment.R --universe analysis/universe.txt \
    --genes stdin --categ CC --output analysis/edgeR.overE14 --species mouse) 2> error.log
logOK

# Validate md5 checksums
log "Validate MD5SUMs"
md5sum -c md5s &> error.log
logOK