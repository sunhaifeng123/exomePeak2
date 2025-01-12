% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/exomePeak2.R
\docType{methods}
\name{exomePeak2}
\alias{exomePeak2}
\title{Peak Calling and Peak Statistics Quantification on MeRIP-seq Dataset.}
\usage{
exomePeak2(bam_ip = NULL, bam_input = NULL, bam_treated_ip = NULL,
  bam_treated_input = NULL, txdb = NULL, bsgenome = NULL,
  genome_assembly = NA, gff_dir = NULL, mod_annot = NULL,
  paired_end = FALSE, library_type = c("unstranded", "1st_strand",
  "2nd_strand"), fragment_length = 100, binding_length = 25,
  step_length = binding_length, peak_width = fragment_length/2,
  pc_count_cutoff = 5, bg_count_cutoff = 50, p_cutoff = 1e-04,
  p_adj_cutoff = NULL, logFC_cutoff = 0, parallel = FALSE,
  background = c("Gaussian_mixture", "m6Aseq_prior", "manual", "all"),
  manual_background = NULL, correct_GC_bg = TRUE, qtnorm = TRUE,
  glm_type = c("DESeq2", "Poisson", "NB"), LFC_shrinkage = c("apeglm",
  "ashr", "Gaussian", "none"), export_results = TRUE,
  export_format = c("CSV", "BED", "RDS"), table_style = c("bed",
  "granges"), save_plot_GC = TRUE, save_plot_analysis = FALSE,
  save_plot_name = "", save_dir = "exomePeak2_output",
  peak_calling_mode = c("exon", "full_tx", "whole_genome"))
}
\arguments{
\item{bam_ip}{a \code{character} vector for the BAM file directories of the (control) IP samples.}

\item{bam_input}{a \code{character} vector for the BAM file directories of the (control) input samples.}

\item{bam_treated_ip}{a \code{character} vector for the BAM file directories of the treated IP samples.}

\item{bam_treated_input}{a \code{character} vector for the BAM file directories of the treated input samples.

If the bam files do not contain treatment group, user should only fill the arguments of \code{BAM_ip} and \code{BAM_input}.}

\item{txdb}{a \code{\link{TxDb}} object for the transcript annotation,
If the \code{TxDb} object is not available, it could be a \code{character} string of the UCSC genome name which is acceptable by \code{\link{makeTxDbFromUCSC}}, example: \code{"hg19"}.}

\item{bsgenome}{a \code{\link{BSgenome}} object for the genome sequence information,
If the \code{BSgenome} object is not available, it could be a \code{character} string of the UCSC genome name which is acceptable by \code{\link{getBSgenome}}, example: \code{"hg19"}.}

\item{gff_dir}{optional, a \code{character} which specifies the directory toward a gene annotation GFF/GTF file, it is applied when the \code{TxDb} object is not available, default \code{= NULL}.}

\item{mod_annot}{a \code{\link{GRanges}} object for user provided single based RNA modification annotation.

If user provides the single based RNA modification annotation, this function will perform reads count on the provided annotation flanked by length \code{= floor(fragment_length - binding_length/2)}.}

\item{paired_end}{a \code{logical} of whether the data comes from the Paired-End Library, \code{TRUE} if the data is Paired-End sequencing; default \code{FALSE}.}

\item{library_type}{a \code{character} specifying the protocal type of the RNA-seq library, can be one in \code{c("unstranded", "1st_strand", "2nd_strand")}; default \code{= "unstranded"}.

\describe{
\item{\strong{unstranded}}{The randomly primed RNA-seq library type, i.e. both the strands generated during the first and the second strand sythesis are sequenced; example: Standard Illumina.}
\item{\strong{1st_strand}}{The first strand-specific RNA-seq library, only the strand generated during the first strand sythesis is sequenced; examples: dUTP, NSR, NNSR.}
\item{\strong{2nd_strand}}{The second strand-specific RNA-seq library, only the strand generated during the second strand sythesis is sequenced; examples: Ligation, Standard SOLiD.}
}}

\item{fragment_length}{a positive integer number for the expected fragment length in nucleotides; default \code{= 100}.}

\item{binding_length}{a positive integer number for the expected binding length of the anti-modification antibody in IP samples; default \code{= 25}.}

\item{step_length}{a positive integer number for the shift distances of the sliding window; default \code{= binding_length}.}

\item{peak_width}{a \code{numeric} value for the minimum width of the merged peaks; default \code{= fragment_length} .}

\item{pc_count_cutoff}{a \code{numeric} value for the cutoff on average window's reads count in peak calling; default \code{= 5}.}

\item{bg_count_cutoff}{a \code{numeric} value for the cutoff on average window's reads count in background identification; default \code{= 50}.}

\item{p_cutoff}{a \code{numeric} value for the cutoff on p values in peak calling; default \code{= NULL}.}

\item{p_adj_cutoff}{a \code{numeric} value for the cutoff on Benjamini Hochberg adjusted p values in peak calling; default \code{= 0.05}.}

\item{logFC_cutoff}{a \code{numeric} value for the cutoff on log2 IP over input fold changes in peak calling; default \code{= 0}.}

\item{parallel}{a \code{logical} value indicating whether to use parallel computation, it will require > 16GB memory if \code{parallel = TRUE}; default \code{= FALSE}.}

\item{background}{a \code{character} specifies the method for the background finding, i.e. to identify the windows without modification signal. It could be one of \code{c("Gaussian_mixture", "m6Aseq_prior", "manual", "all")};  default \code{= "Gaussian_mixture"}.

In order to accurately account for the technical variations, it is often neccessary to estimate the sequencing depth and GC content linear effects on windows without modification signals.

The following methods are supported in \code{ExomePeak2} to differentiate the no modification background windows from the modification containig windows.

\describe{
 \item{\strong{\code{Gaussian_mixture}}}{The background is identified by Multivariate Gaussian Mixture Model (MGMM) with 2 mixing components on the vectors containing methylation level estimates and GC content, the background regions are predicted by the Bayes Classifier on the learned GMM.}

 \item{\strong{\code{m6Aseq_prior}}}{The background is identified by the prior knowledge of m6A topology, the windows that are not overlapped with long exons (exon length >= 400bp) and 5'UTR are treated as the background windows.

 This type of background should not be used if the MeRIP-seq data is not targetting on m6A methylation.

 }

 \item{\strong{\code{manual}}}{The background regions are defined by the user manually at the argument \code{manual_background}.}

 \item{\strong{\code{all}}}{Use all windows as the background. This is equivalent to not differentiating background and signal.
 It can lead to biases on the estimation of the technical factors.
 }
}}

\item{manual_background}{a \code{\link{GRanges}} object for the user provided unmodified background; default \code{= NULL}.}

\item{correct_GC_bg}{a \code{logical} value of whether to estimate the GC content linear effect on background regions; default \code{= TRUE}.

If \code{= TRUE}, it could lead to a more accurate estimation of GC content bias for the RNA modifications that are highly biologically related to GC content.}

\item{qtnorm}{a \code{logical} of whether to perform subset quantile normalization after the GC content linear effect correction； default \code{= TRUE}.

If \code{qtnorm = TRUE}, subset quantile normalization will be applied within the IP and input samples seperately to account for the inherent differences between the marginal distributions of IP and input samples.}

\item{glm_type}{a \code{character} speciefies the type of Generalized Linear Model (GLM) fitted for the purpose of statistical inference during peak calling, which can be one of the \code{c("DESeq2", "NB", "Poisson")}.

\describe{
\item{\strong{\code{DESeq2}}}{Fit the GLM defined in the function \code{\link{DESeq}}, which is the NB GLM with regulated estimation of the overdispersion parameters.}

\item{\strong{\code{NB}}}{Fit the Negative Binomial (NB) GLM.}

\item{\strong{\code{Poisson}}}{Fit the Poisson GLM.}
}

By default, the DESeq2 GLMs are fitted on the data set with > 1 biological replicates for both the IP and input samples, the Poisson GLM will be fitted otherwise.}

\item{LFC_shrinkage}{a \code{character} for the method of emperical bayes shrinkage on log2FC, could be one of \code{c("apeglm", "ashr", "Gaussian", "none")}; Default \code{= "apeglm"}.

see \code{\link{lfcShrink}} for more details; if "none" is selected, only the MLE will be returned.}

\item{export_results}{a \code{logical} of whether to save the results on disk; default \code{= TRUE}.}

\item{export_format}{a \code{character} vector for the format(s) of the result being exported, could be the subset of \code{c("CSV","BED","RDS")}; Default \code{= c("CSV","BED","RDS")}.}

\item{table_style}{a \code{character} for the style of the table being exported, could be one of \code{c("bed", "granges")}; Default \code{= "bed"}.}

\item{save_plot_GC}{a \code{logical} of whether to generate the plots for GC content bias assessment; default \code{= TRUE}.}

\item{save_plot_analysis}{a \code{logical} of whether to generate the plots for genomic analysis on modification sites; default \code{= FALSE}.}

\item{save_plot_name}{a \code{character} for the name of the plots being saved; Default \code{= "Plot"}.}

\item{save_dir}{a \code{character} for the name of the directory being saved; Default \code{= "exomePeak2_output"}.}

\item{peak_calling_mode}{a \code{character} specifies the scope of peak calling on genome, can be one of \code{c("exon", "full_transcript", "whole_genome")}; Default \code{= "exon"}.

\describe{
\item{\strong{\code{exon}}}{generate sliding windows on exon regions.}

\item{\strong{\code{full_transcript}}}{generate sliding windows on the full transcripts (include both introns and exons).}

\item{\strong{\code{whole_genome}}}{generate sliding windows on the whole genome (include introns, exons, and the intergenic regions).}
}

P.S. The full transcript mode and the whole genome mode demand big memory size (> 4GB) for large genomes.}

\item{bp_param}{optional, a \code{\link{BiocParallelParam}} object that stores the configuration parameters for the parallel execution.}
}
\value{
a \code{\link{SummarizedExomePeak}} object.
}
\description{
\code{\link{exomePeak2}} conduct peak calling and peak statistics calculation from BAM files of a MeRIP-seq experiment.
The function integrates the following steps of a standardized MeRIP-seq pipeline in one step.

\enumerate{
\item Check and index the BAM files with \code{\link{scanMeripBAM}}.
\item Call modification peaks on exons with \code{\link{exomePeakCalling}}.
\item Calculate GC content bias correction factors on the background regions with \code{\link{normalizeGC}}.
\item Calculate (differential) modification statistics with generalized linear model (GLM) with \code{\link{glmM}} and \code{\link{glmDM}}
\item Export the peak/site statistics with user defined format by \code{\link{exportResults}}.
}

See the help pages of the corresponding functions for the complete documentations at each step.
}
\details{
\code{\link{exomePeak2}} call RNA modification peaks and calculate peak statistics from BAM files of a MeRIP-seq experiment.
The transcript annotation (from either the \code{\link{TxDb}} object or the GFF file) must be provided to perform analysis on exons.

The \code{\link{BSgenome}} object is also required to perform the GC content bias adjustment.
If the \code{bsgenome} argument is not provided (\code{= NULL}), the downstream analysis will proceed without GC content bias corrections.

If the BAM files in treated samples are provided at the arguments \code{bam_treated_ip} and \code{bam_treated_input}, the statistics of differential modification analysis will be reported.

Under default setting, \code{\link{exomePeak2}} will save the results of (differential) modification analysis under a folder named by \code{'exomePeak2_output'}.
The results generated include a BED file and a CSV table that store the locations and statistics of (differential) modified peaks/sites.
}
\examples{
# Load packages for the genome sequence and transcript annotation

library(TxDb.Hsapiens.UCSC.hg19.knownGene)
library(BSgenome.Hsapiens.UCSC.hg19)

# Peak Calling

exomePeak2(bam_ip = c("IP_rep1.bam",
                      "IP_rep2.bam",
                      "IP_rep3.bam"),
           bam_input = c("input_rep1.bam",
                         "input_rep2.bam",
                         "input_rep3.bam"),
           txdb = TxDb.Hsapiens.UCSC.hg19.knownGene,
           bsgenome = Hsapiens)

# Differential Modification Analysis

exomePeak2(bam_ip = c("IP_rep1.bam",
                      "IP_rep2.bam",
                      "IP_rep3.bam"),
           bam_input = c("input_rep1.bam",
                         "input_rep2.bam",
                         "input_rep3.bam"),
           bam_treated_ip = c("IP_treated_rep1.bam",
                              "IP_treated_rep2.bam"),
           bam_treated_input = c("input_treated_rep1.bam",
                                 "input_treated_rep2.bam"),
           txdb = TxDb.Hsapiens.UCSC.hg19.knownGene,
           bsgenome = Hsapiens)

# Modification Quantification with Single Based Modification Annotation

annot_dir <- system.file("extdata", "m6A_hg19_annot.rds", package = "exomePeak2")

m6A_hg19_gr <- readRDS(annot_dir)

exomePeak2(bam_ip = c("IP_rep1.bam",
                      "IP_rep2.bam",
                      "IP_rep3.bam"),
           bam_input = c("input_rep1.bam",
                         "input_rep2.bam",
                         "input_rep3.bam"),
           txdb = TxDb.Hsapiens.UCSC.hg19.knownGene,
           bsgenome = Hsapiens,
           mod_annot = m6A_hg19_gr)

# Differential Modification Analysis with Single Based Modification Annotation

exomePeak2(bam_ip = c("IP_rep1.bam",
                      "IP_rep2.bam",
                      "IP_rep3.bam"),
           bam_input = c("input_rep1.bam",
                         "input_rep2.bam",
                         "input_rep3.bam"),
           bam_treated_ip = c("IP_treated_rep1.bam",
                              "IP_treated_rep2.bam"),
           bam_treated_input = c("input_treated_rep1.bam",
                                 "input_treated_rep2.bam"),
           txdb = TxDb.Hsapiens.UCSC.hg19.knownGene,
           bsgenome = Hsapiens,
           mod_annot = m6A_hg19_gr)


}
\seealso{
\code{\link{exomePeakCalling}}, \code{\link{glmM}}, \code{\link{glmDM}}, \code{\link{normalizeGC}}, \code{\link{exportResults}}, \code{\link{plotLfcGC}}
}
