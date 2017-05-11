library(curl)
library(biomaRt)
library(parallel)

# load Crohn's datasets from epigwas
load("/root/avalomics_platform/shiny/gwas/data/crohns_epigwasIndexSNP.Rda")

# load ld results file of all the snps (combined from multiple files from 
# /cmbnfs/Research/Projects/IBD/epigwas_results/ld_files)
ldResults <- read.csv('/root/avalomics_platform/shiny/gwas/data/bigLDResults.txt', sep = '\t', header = F)

# biomaRt parameters
attributes <- c("ensembl_gene_id","start_position","end_position","strand","hgnc_symbol","chromosome_name","entrezgene","ucsc","band")
# mart <- useDataset("hsapiens_gene_ensembl", useMart('ensembl')) # Default is using GRCh38
mart <- useEnsembl(biomart="ensembl", dataset="hsapiens_gene_ensembl", GRCh=37)
filters <- c("chromosome_name","start","end")

# Given a snp id(s), returns a list of genes in it's ld block according to 
# Ensembl using biomaRt
# snpIds = '[rs123456[|rs234567]]'
getAllGenes <- function(snpIds) {
  if (snpIds == '') {
    return ('')
  }
  
  genes <- c()
  
  # Split the snpids with | if exists 
  for (snp in str_split(snpIds, '\\|')[[1]]) {
    ldBlock <- ldResults[ldResults$V2 == snp,]
    chrs <- unique(ldBlock$V1)
    
    # Take multiple chromosome locations into consideration
    for (chr in chrs) {
      # Get the ld block information 
      ldChr <- ldBlock[ldBlock$V1 == chr,]
      
      # Extract chromosome name, start and end position
      r <- sub('^chr(\\d*).*',replacement = '\\1', chr)
      startPos <- min(ldChr$V5)
      endPos <- max(ldChr$V5)
      
      # Query using biomaRt
      values <- list(chromosome=r, start=startPos, end=endPos)
      all.genes <- getBM(attributes=attributes, filters=filters, values=values, mart=mart)
      genes <- append(genes, unique(all.genes$hgnc_symbol))
    }
  }
  
  genes <- unique(genes[genes != ''])
  genes <- ifelse(is.null(genes), 
                  '', 
                  paste0(genes, collapse = '; '))
  return (genes)
}

# Test
# getAllGenes('rs11465804|rs11209026')
# getAllGenes('rs11465804')

enhanceCD <- function(cd) {
  foo <- c()
  
  for(snpIds in cd$epigwas_snp) {
    if (snpIds == '') {
      foo <- append(foo, '')
    }
    else {
      foo <- append(foo, getAllGenes(snpIds))
    }
  }
  
  browser()
  return (cbind(cd, foo))
}

cd3 <- enhanceCD(cd)
save(cd3, file = '/root/avalomics_platform/shiny/gwas/data/crohns_epigwasIndexSNP_enhanced2.Rda')
