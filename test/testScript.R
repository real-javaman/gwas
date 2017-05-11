library(curl)
library(biomaRt)

# load datasets
load("data/crohns_epigwasIndexSNP.Rda")
percentile <- read.csv('/root/avalomics_platform/shiny/gwas/data/cd_gwas.phenores.H3K4me3.percentile.txt', sep = '\t')
snpScoresFlag <- read.csv('/root/avalomics_platform/shiny/gwas/data/cd_gwas.phenores.H3K4me3.snpScoresFlag.txt', sep = '\t') # Use this one
snpScores <- read.csv('/root/avalomics_platform/shiny/gwas/data/cd_gwas.phenores.H3K4me3.snpScores.txt', sep = '\t')
tissueScores <- read.csv('/root/avalomics_platform/shiny/gwas/data/cd_gwas.phenores.H3K4me3.tissueScores.txt', sep = '\t')
ldResults <- read.csv('/root/avalomics_platform/shiny/gwas/data/bigLDResults.txt', sep = '\t', header = F)


# get the snp ids where snp index column has 2 or more ids
# snps <- strsplit('rs11465804|rs11209026', split = '\\|') # for example
# View(snps)

# get the snp scores
# tsScores <- snpScoresFlag[snpScoresFlag$IndexSNP == 'rs11465804',]
# View(tsScores)

# get the ld bloc location
ldBlock <- ldResults[ldResults$V2 == 'rs11465804',]
# ldBlock <- ldResults[ldResults$V2 == 'rs9858542',]
# View(ldBlock[with(ldBlock, order(V1, V5)),])
chrs <- unique(ldBlock$V1)
ensemblResults <- data.frame(stringsAsFactors = F)

attributes <- c("ensembl_gene_id","start_position","end_position","strand","hgnc_symbol","chromosome_name","entrezgene","ucsc","band")
mart <- useDataset("hsapiens_gene_ensembl", useMart('ensembl'))
filters <- c("chromosome_name","start","end")

for (chr in chrs) {
  ldChr <- ldBlock[ldBlock$V1 == chr,]
  r <- sub('^chr(\\d*).*',replacement = '\\1', chr)
  startPos <- min(ldChr$V5)
  endPos <- max(ldChr$V5)
  values <- list(chromosome=r, start=startPos, end=endPos)
  all.genes <- getBM(attributes=attributes, filters=filters, values=values, mart=mart)
  unique(all.genes$hgnc_symbol)
  ensemblResults <- cbind(ensemblResults, all.genes)
}
View(ensemblResults)
