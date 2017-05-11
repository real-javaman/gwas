# gwas/app.R
# Author: Immanuel Utomo (iutomo@celgene.com)

# library(yaml)
library(DT)
library(shinythemes)
library(shinyBS)
# library(ggplot2)
# library(VennDiagram)
# library(ontologyIndex)
# library(plyr)
# library(stringr)
# library(dplyr)
# library(tidyr)

# Debugging purposes only
# options(shiny.sanitize.errors = FALSE, shiny.trace = TRUE, shiny.autoreload = TRUE)

# Global variables --------------------------------------------------------
# Config file
# cfg <<- yaml.load_file('../config/20170309.yml')

# Load global variables
# load("data/gwas_catalog_v101.Rda") # Original datasets
load("data/crohns_epigwasIndexSNP.Rda")
percentile <- read.csv('data/cd_gwas.phenores.H3K4me3.percentile.txt', sep = '\t')
snpScoresFlag <- read.csv('data/cd_gwas.phenores.H3K4me3.snpScoresFlag.txt', sep = '\t') # Use this one
snpScores <- read.csv('data/cd_gwas.phenores.H3K4me3.snpScores.txt', sep = '\t')
tissueScores <- read.csv('data/cd_gwas.phenores.H3K4me3.tissueScores.txt', sep = '\t')

# Define the UI -----------------------------------------------------------
ui <- bootstrapPage( 
  tags$head(tags$script(src="helper.js")),
  h3("GWAS Catalog"),
  # tags$style(HTML(".popover { max-width: 550px; width: 550px; }")),
  tags$nav(class="navbar navbar-default", 
           tags$a(class = "navbar-brand", href="#", "GWAS"),
           tags$p(class = "navbar-text", id="credits", "I&I TCoE")),
  tags$div(
    class = "col-md-12",
    tabsetPanel(
      id = "mainTabset", 
      tabPanel("Crohn's Disease", 
               value = "geneLookupTab", 
               class = "col-md-12",
               # selectInput(inputId = "diseaseTraitDD",
               #             label = "Search Disease/Trait", 
               #             choices = unique(cd$`DISEASE/TRAIT`), 
               #             multiple = T),
               # uiOutput('geneMappingHeader'),
               dataTableOutput("gwasTable"),
               br(),
               hr(),
               uiOutput('gwasHeader'),
               tabsetPanel(
                 id = "drilldownTabset",
                 tabPanel(
                   title = 'Expression specificity',
                   dataTableOutput("expressionTable")
                   ),
                 tabPanel(
                   title = 'Promoter specificity',
                   dataTableOutput("promoterTable")
                 )
               ),
               div(id = 'drilldownAnchor')
               )
    )
  ),
  br(),
  br(),
  tags$div(class="row",
           tags$footer("GWAS v0.1 (5/1/2017)",
                       align = "right",
                       class = "col-md-12 site-footer",
                       style = "position:fixed;bottom:0;height:20px;background:#fcfcfc;")),
  theme = shinytheme("cosmo")
)

# Define the server code --------------------------------------------------
server <- function(input, output, session) {
  # output$geneMappingHeader <- renderUI(expr = {
  #   if(is.null(input$diseaseTraitDD)) {
  #     return(HTML(''))
  #   }
  #   
  #   return(h4('Gene Mapping'))
  # })
  
  # Tabs:
  # - LD Block
  # - Promoted specificity
  output$gwasTable <- renderDataTable({
    # if(is.null(input$diseaseTraitDD)) {
    #   return(data.frame())
    # }
    # TODO: Make SNP id cickable and link to GTex and Blueprint (immune cells) - TS Scores
    # TODO: Genes + TS Scores
    # TODO: Look at cd_gwas_phenores.H3K4 to find the correct SNP id
    # TODO: Might need an index SNP instead
    curtbl <- cd
    
    # for (d in input$diseaseTraitDD) {
    #   curtbl <- rbind(cd[cd$`DISEASE/TRAIT` == input$diseaseTraitDD,])
    # }
    
    curtbl$snpLink <- sapply(curtbl$epigwas_snp, function (x) {
      snps <- strsplit(x, split = '\\|')
      paste0(
        '<a id="',
        snps[[1]],
        '", onclick="clickSNP(this.id); return false;" target="_blank" href="#"',
        ' class="action-button shiny-bound-input">',
        snps[[1]],
        '</a>', collapse = '|'
      )
    })
    
    curtbl <- curtbl[,c("snpLink", "PUBMEDID", "DISEASE/TRAIT", "INITIAL.SAMPLE.SIZE", "REPLICATION.SAMPLE.SIZE",
                       "MAPPED_GENE", "CONTEXT", "RISK.ALLELE.FREQUENCY",
                       "P-VALUE","OR.or.BETA")]
    names(curtbl) <- c("Risk SNP", "Pubmed ID", "Disease/Trait", "Initial Sample Size", "Replication Sample Size",
                       "Gene", "Context", "Allele Frequency", "p-value", "OR/Beta")
    return (curtbl)
  },
  escape = FALSE,
  selection = 'none',
  rownames = FALSE
  )
  
  output$gwasHeader <- renderUI({
    req(input$snpIDClicked)
    browser()
    return(h3(input$snpIDClicked))
  })
  
  output$expressionTable <- renderDataTable({
    req(input$snpIDClicked)
    # browser()
    tsScores <- snpScoresFlag[snpScoresFlag$IndexSNP == input$snpIDClicked,]
    tsScores[order(tsScores$Score, decreasing = T),]
  },
  escape = FALSE,
  selection = 'none',
  rownames = FALSE
  )
  
  # TODO: Get list of genes on the same ld block
  # TODO: Get the tissue of interest and create tissue spec bar chart for genes that express in that tissue
  # Drilldown tabs: Promoter specificity + Expression specificity
}

# Return a Shiny app object
shinyApp(ui = ui, server = server)
