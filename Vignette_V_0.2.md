ExomePeak2 Usage Guide
================

1. Package Installation
-----------------------

First, install the exomePeak2 package with the following command.

``` r
if (!requireNamespace("devtools", quietly = TRUE))
    install.packages("devtools")
devtools::install_github("ZhenWei10/exomePeak2")
library(exomePeak2)
```

Second, install the R packages for the annotation and sequence of the genome. At here, we use human genome hg19 as the example.

For R version higher than 3.4.0, use the following code.

``` r
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

if (!requireNamespace(c("TxDb.Hsapiens.UCSC.hg19.knownGene",
                        "BSgenome.Hsapiens.UCSC.hg19"), quietly = TRUE))
    BiocManager::install(c("TxDb.Hsapiens.UCSC.hg19.knownGene",
                           "BSgenome.Hsapiens.UCSC.hg19"), version = "3.8")
```

For R version below 3.4.0, use the following code.

``` r
source("http://www.bioconductor.org/biocLite.R")

biocLite(c("TxDb.Hsapiens.UCSC.hg19.knownGene",
           "BSgenome.Hsapiens.UCSC.hg19"))
```

Load the packages for transcript annotation and genome sequence of hg19.

``` r
library(TxDb.Hsapiens.UCSC.hg19.knownGene)
library(BSgenome.Hsapiens.UCSC.hg19)
```

2. Peak Calling
---------------

Use the code below to conduct peak calling on exon regions defined by the `TxDb` object.

Users need to specify the bam file directories of IP and input samples separately using the arguments of `bam_ip` and `bam_input`, the biological replicates are represented by a character vector of their bam file directories.

The `BSgenome` object is used to conduct GC content bias correction, if the `bsgenome` argument is missing, peak calling will be performed without correcting the GC content bias.

``` r
exomePeak2(bam_ip = c("IP_rep1.bam", 
                      "IP_rep2.bam", 
                      "IP_rep3.bam"), 
           bam_input = c("input_rep1.bam",                 
                         "input_rep2.bam",
                         "input_rep3.bam"),
           txdb = TxDb.Hsapiens.UCSC.hg19.knownGene, 
           bsgenome = Hsapiens)
```

The results include a BED file and a TSV table for the modification peaks, the files will be saved automatically under a folder named by `exomePeak2_output`.

3. Differential Modification Analysis
-------------------------------------

The code below could conduct differential modification analysis on exon regions defined by the `TxDb` object.

It will first perform Peak calling on exon regions using both the control and treated samples, then, the differential modification will be performed on peaks reported from peak calling using an interactive GLM.

At this step, the `BSgenome` object is also necessary to conduct the GC content bias correction, if the bsgenome argument is missing, the differential modification analysis will be performed without GC content bias correction.

``` r
exomePeak2(bam_ip = c("IP_control_rep1.bam", 
                      "IP_control_rep2.bam", 
                      "IP_control_rep3.bam"), 
           bam_input =c("input_control_rep1.bam", 
                        "input_control_rep2.bam", 
                        "input_control_rep3.bam"),
           bam_treated_ip = c("IP_treated_rep1.bam", 
                              "IP_treated_rep2.bam"),
           bam_treated_input = c("input_treated_rep1.bam", 
                                 "input_treated_rep2.bam"), 
           txdb = TxDb.Hsapiens.UCSC.hg19.knownGene, 
           bsgenome = Hsapiens)
```

The results generated here include a BED file and a TSV table for the differentially modified peaks, the files will also be saved automatically under a folder named by `exomePeak2_output`.

4. Quantification and Statistical Analysis with Single Based Modification Annotation
------------------------------------------------------------------------------------

exomePeak2 supports the modification quantification and differential modification analysis on single based modification annotation. The modification sites with single based resolution can provide a more accurate mapping on modification locations compared with the peaks called directly from the MeRIP-seq datasets.

Using the datasets with single based resolution (e.x. data generated by m6A-CLIP-seq or m6A-miCLIP-seq techniques) as the reference sites, exomePeak2 could provide a more accurate and consistent quantification from MeRIP-seq data.

This mode of analysis will be automatically initiated by adding a sigle based annotation file under the argument `mod_annot`.

The single based annotation information should be provided to exomePeak2 function in the format of a `GRanges` object.

``` r
annot_dir <- system.file("extdata", "m6A_hg19_annot.rds", package = "exomePeak2")

m6A_hg19_gr <- readRDS(annot_dir) # m6A_hg19_gr is the GRanges object containing the m6A single based resolution sites on hg19

exomePeak2(bam_ip = c("IP_rep1.bam", 
                      "IP_rep2.bam", 
                      "IP_rep3.bam"), 
           bam_input = c("input_rep1.bam",                 
                         "input_rep2.bam",
                         "input_rep3.bam"),
           txdb = TxDb.Hsapiens.UCSC.hg19.knownGene, 
           bsgenome = Hsapiens,
           mod_annot = m6A_hg19_gr)
```

The results generated here include the BED file and the TSV table with rows correspond to the input annotation sites, the files will also be saved under a folder named by `exomePeak2_output`.

5. Peak Calling and Visualization in Multiple Steps
---------------------------------------------------

The exomePeak2 package can achieve peak calling and peak statistics calulation using multiple functions.

**1. Check the bam files of MeRIP-seq data before peak calling.**

``` r
MeRIP_Seq_Alignment <- scanMeripBAM(
    bam_ip = c("IP_rep1.bam", 
               "IP_rep2.bam", 
               "IP_rep3.bam"), 
    bam_input = c("input_rep1.bam",                 
                  "input_rep2.bam",
                  "input_rep3.bam"),
    paired_end = TRUE
  ) 
```

For MeRIP-seq experiment with interactive design (contain control and treatment groups), use the following code.

``` r
MeRIP_Seq_Alignment <- scanMeripBAM(
    bam_ip = c("IP_rep1.bam", 
               "IP_rep2.bam", 
               "IP_rep3.bam"), 
    bam_input = c("input_rep1.bam",                 
                  "input_rep2.bam",
                  "input_rep3.bam"),
    bam_treated_ip = c("IP_treated_rep1.bam", 
                       "IP_treated_rep2.bam"),
    bam_treated_input = c("input_treated_rep1.bam", 
                          "input_treated_rep2.bam"), 
    paired_end = TRUE
  ) 
```

**2. Conduct peak calling analysis on exons using the provided bam files.**

``` r
SummarizedExomePeaks <- exomePeakCalling(merip_bams = MeRIP_Seq_Alignment,
                                         txdb = TxDb.Hsapiens.UCSC.hg19.knownGene,
                                         bsgenome = Hsapiens) 
```

Alternatively, use the following code to quantify MeRIP-seq data on single based modification annotation.

``` r
SummarizedExomePeaks <- exomePeakCalling(merip_bams = MeRIP_Seq_Alignment,
                                         txdb = TxDb.Hsapiens.UCSC.hg19.knownGene,
                                         bsgenome = Hsapiens,
                                         mod_annot = m6A_hg19_gr) 
```

**3. Estimate size factors that are required for GC content bias correction.**

``` r
SummarizedExomePeaks <- normalizeGC(SummarizedExomePeaks)
```

**4. Report the statistics of modification peaks using Generalized Linear Model (GLM).**

``` r
SummarizedExomePeaks <- glmM(SummarizedExomePeaks) 
```

Alternatively, If the treated IP and input bam files are provided, `glmDM` function could be used to conduct differential modification analysis on modification Peaks with interactive GLM.

``` r
SummarizedExomePeaks <- glmDM(SummarizedExomePeaks)
```

**5. Generate plots for the linear relationships between GC content and reads abundence.**

``` r
plotReadsGC(SummarizedExomePeaks)
```

**6. Generate the scatter plot between GC content and log2 Fold Change (LFC).**

``` r
plotLfcGC(SummarizedExomePeaks) 
```

**8. Generate the bar plot for the sequencing depth size factors.**

``` r
plotSizeFactors(SummarizedExomePeaks)
```

**8. Export the modification peaks and the peak statistics with user decided format.**

``` r
exportResults(SummarizedExomePeaks, format = "BED") 
```

**9. Generate plots for the genomic features analysis.**

Plot the distribution of the lengths of exons.

``` r
plotExonLength(SummarizedExomePeaks,txdb = TxDb.Hsapiens.UCSC.hg19.knownGene)
```

Plot the distribution of modification peaks on travis coordinate.

``` r
plotGuitar(SummarizedExomePeaks, txdb = TxDb.Hsapiens.UCSC.hg19.knownGene)
```

Contact
-------

Please contact the maintainer of exomePeak2 if you have encountered any problems:

**ZhenWei**: <zhen.wei@xjtlu.edu.cn>

Please visit the github page of exomePeak2:

<https://github.com/ZhenWei10/exomePeak2>

Session Info
------------

``` r
sessionInfo()
```

    ## R version 3.5.3 (2019-03-11)
    ## Platform: x86_64-apple-darwin15.6.0 (64-bit)
    ## Running under: macOS Sierra 10.12.6
    ## 
    ## Matrix products: default
    ## BLAS: /Library/Frameworks/R.framework/Versions/3.5/Resources/lib/libRblas.0.dylib
    ## LAPACK: /Library/Frameworks/R.framework/Versions/3.5/Resources/lib/libRlapack.dylib
    ## 
    ## locale:
    ## [1] zh_CN.UTF-8/zh_CN.UTF-8/zh_CN.UTF-8/C/zh_CN.UTF-8/zh_CN.UTF-8
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] compiler_3.5.3  magrittr_1.5    tools_3.5.3     htmltools_0.3.6
    ##  [5] yaml_2.2.0      Rcpp_1.0.1      stringi_1.4.3   rmarkdown_1.12 
    ##  [9] knitr_1.22      stringr_1.4.0   xfun_0.6        digest_0.6.18  
    ## [13] evaluate_0.13
