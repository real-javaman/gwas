# gwas
Workflow to view and query Broad's [epigwas](http://archive.broadinstitute.org/mpg/epigwas/).

### data/
#### Epigwas - Crohn's disease

- crohns_epigwasIndexSNP.rda: Processed data of epigwas
- crohns_epigwasIndexSNP_enhanced.rda: 
- crohns_epigwasIndexSNP_enhanced2.rda

#### LD results

- bigLDResults.txt - combination of snp ld block results

#### H3K4me3 
 
- cd_gwas.phenores.H3K4me3.*: expression data

### scripts

- ldBlockGenes.R: using data from crohns_epigwasIndexSNP.rda, get genes in ld block of each snp and create a new column for that list
- app.R: simple Shiny app to query the data