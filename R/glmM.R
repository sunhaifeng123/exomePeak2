#' @title Estimation and Inference on IP/input Log2 Fold Changes with Generalized Linear Model.
#'
#' @param sep a \code{summarizedExomePeak} object.
#'
#' @param glm_type a \code{character} speciefies the type of Generalized Linear Model (GLM) fitted for the purpose of statistical inference during peak calling, which can be one of the \code{c("DESeq2", "NB", "Poisson")}.
#'
#' \describe{
#' \item{\strong{\code{DESeq2}}}{Fit the GLM defined in the function \code{\link{DESeq}}, which is the NB GLM with regulated estimation of the overdispersion parameters.}
#'
#' \item{\strong{\code{NB}}}{Fit the Negative Binomial (NB) GLM.}
#'
#' \item{\strong{\code{Poisson}}}{Fit the Poisson GLM.}
#' }
#'
#' By default, the DESeq2 GLMs are fitted on the data set with > 1 biological replicates for both the IP and input samples, the Poisson GLM will be fitted otherwise.
#'
#' @param LFC_shrinkage a \code{character} for the method of emperical bayes shrinkage on log2FC, could be one of \code{c("apeglm", "Gaussian", "ashr", "none")}; Default \code{= "apeglm"}.
#'
#' see \code{\link{lfcShrink}} for details; if "none" is selected, only the MLE will be returned.
#'
#' @param ... Optional arguments passed to \code{\link{DESeq}}
#'
#' @description \code{glmM} performs inference and estimation on IP/input log2FC.
#'
#' GLMs with the design of an indicator of IP samples are fitted for each peaks/sites:
#'
#' \deqn{log2(Q) = intercept + I(IP)}
#'
#' The log2FC and the associated statistics are based on the coefficient estimate of the dummy variable term： \eqn{I(IP)}.
#'
#' Under default setting, the returned log2FC are the RR estimates with Couchey priors defined in \code{\link{apeglm}}.
#'
#' @import SummarizedExperiment
#'
#' @import DESeq2
#'
#' @docType methods
#'
#' @name glmM
#'
#' @rdname glmM
#'
#' @seealso \code{\link{glmDM}}
#'
#' @examples
#'
#' library(TxDb.Hsapiens.UCSC.hg19.knownGene)
#' library(BSgenome.Hsapiens.UCSC.hg19)
#'
#' aln <- scanMeripBAM(
#' bam_ip = c("IP_rep1.bam",
#'            "IP_rep2.bam",
#'            "IP_rep3.bam"),
#' bam_input = c("input_rep1.bam",
#'               "input_rep2.bam",
#'               "input_rep3.bam"),
#' paired_end = TRUE
#' )
#'
#' sep <- exomePeakCalling(merip_bams = aln,
#'                         txdb = TxDb.Hsapiens.UCSC.hg19.knownGene,
#'                         bsgenome = Hsapiens)
#'
#' sep <- normalizeGC(sep)
#'
#' sep <- glmDM(sep)
#'
#' @export
#'
setMethod("glmM",
          "SummarizedExomePeak",
           function(sep,
                    glm_type = c("auto","Poisson", "NB", "DESeq2"),
                    LFC_shrinkage = c("apeglm", "Gaussian", "ashr"),
                    ...) {

  LFC_shrinkage = match.arg(LFC_shrinkage)

  glm_type = match.arg(glm_type)

  if(glm_type == "auto") {
    if( all( table(colData(sep)$design_IP) > 1  ) ) {
      glm_type <- "DESeq2"
    } else {
      glm_type <- "Poisson"
    }
  }

  if(glm_type == "Poisson") {
    message("Calculating peak statistics with Poisson GLM...")
  }

  if(glm_type == "NB") {
    message("Calculating peak statistics with NB GLM...")
  }

  if(glm_type == "DESeq2") {
    message("Calculating peak statistics with DESeq2...")
  }


  stopifnot((any(sep$design_IP) & any(!sep$design_IP)))

  if(is.null(colData( sep )$sizeFactor)) {

    sep <- estimateSeqDepth(sep)

  }

  indx_mod <- grepl("mod", rownames( sep ) )

  SE_M <- sep

  SE_M$IPinput = "input"

  SE_M$IPinput[SE_M$design_IP] = "IP"

  SE_M$IPinput = factor(SE_M$IPinput)

    if(!is.null(GCsizeFactors( sep ))) {

      gc_na_indx <- rowSums( is.na(GCsizeFactors(sep)) ) > 0

      #Need to deal with the missing values in GC content size factor.
      Cov = ~ IPinput

      dds = suppressMessages( DESeqDataSet(se = SE_M[(!gc_na_indx) & indx_mod,], design = Cov) )

      glm_off_sets <- GCsizeFactors(sep)[(!gc_na_indx) & indx_mod,]

      #normalization to make the row geometric means = 0 (since DESeq2 only cares about the difference).
      #and this norm factor is still under the original scale (not log scale glm off set).
      centered_off_sets <- exp(glm_off_sets) / exp(rowMeans(glm_off_sets))

      normalizationFactors(dds) <- centered_off_sets

      rm(glm_off_sets, centered_off_sets)

      dds$IPinput <- relevel(dds$IPinput, "input")


    } else {

      Cov = ~ IPinput

      dds = suppressMessages( DESeqDataSet(se = SE_M[indx_mod,], design = Cov) )

      dds$IPinput <- relevel( dds$IPinput, "input" )

    }

    if(glm_type == "Poisson"){
      dispersions(dds) = 0
    }

    if(glm_type == "NB"){
      dds = suppressMessages( estimateDispersions( dds, fitType = "mean" ) )
    }

    if(glm_type == "DESeq2"){
      dds = suppressMessages( estimateDispersions( dds ) )
    }

      dds = suppressMessages( nbinomWaldTest( dds ) )

   #Generation of the DESeq2 report.

      DS_result <- as.data.frame( suppressWarnings( suppressMessages( results( dds, altHypothesis = "greater" ) ) ))
      DS_result <- DS_result[,c("log2FoldChange","log2FoldChange","lfcSE","pvalue","padj")]
      colnames(DS_result) <- c("log2FoldChange","log2fcMod.MLE","log2fcMod.MLE.SE","pvalue","padj")

      #Include reads count
      DS_result$ReadsCount.IP <- rowSums( cbind(assay(dds)[,colData(dds)$design_IP]) )
      DS_result$ReadsCount.input <- rowSums( cbind(assay(dds)[,!colData(dds)$design_IP]) )

      #Calculat expression level related estimates
      Expr_design_MLE <- as.data.frame( suppressWarnings( suppressMessages( results( dds, contrast = c(1,0)) ) ))
      DS_result$log2Expr.MLE <- Expr_design_MLE[,"log2FoldChange"]
      DS_result$log2Expr.MLE.SE <- Expr_design_MLE[,"lfcSE"]
      rm(Expr_design_MLE)

      #Calculate additional MAP estimates if LFCs are set != "none"
      if(LFC_shrinkage != "none" & glm_type != "Poisson") {

        #MAP for methylation level
        DS_result$log2fcMod.MAP <- as.data.frame( suppressMessages( lfcShrink( dds=dds, coef = 2, type = LFC_shrinkage  ) ) )$log2FoldChange

        DS_result$log2FoldChange <- DS_result$log2fcMod.MAP

        DS_result <- DS_result[,c("ReadsCount.input","ReadsCount.IP",
                                  "log2Expr.MLE","log2Expr.MLE.SE",
                                  "log2fcMod.MLE","log2fcMod.MLE.SE","log2fcMod.MAP",
                                  "log2FoldChange","pvalue","padj")]
      } else {

        DS_result <- DS_result[,c("ReadsCount.input","ReadsCount.IP",
                                  "log2Expr.MLE","log2Expr.MLE.SE",
                                  "log2fcMod.MLE","log2fcMod.MLE.SE",
                                  "log2FoldChange","pvalue","padj")]
      }


    if (!is.null(GCsizeFactors( sep ))) {

      DS_final_rst <- matrix(NA,nrow = nrow(SE_M[indx_mod,]), ncol = ncol(DS_result))

      colnames(DS_final_rst) <- colnames(DS_result)

      DS_final_rst <- as.data.frame(DS_final_rst)

      DS_final_rst[(!gc_na_indx)[indx_mod],] <- as.data.frame( DS_result )

      rm(DS_result)

    } else {

      DS_final_rst <- DS_result

      rm(DS_result)

    }

  rownames(DS_final_rst) = rownames(SE_M)[indx_mod]

  DESeq2Results( sep ) = as.data.frame( DS_final_rst )

  return(sep)

})
