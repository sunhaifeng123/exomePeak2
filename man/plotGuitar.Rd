% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/plotGuitar.R
\docType{methods}
\name{plotGuitar}
\alias{plotGuitar}
\title{Plot the distribution of the peaks/sites on travis coordinate.}
\usage{
plotGuitar(sep, txdb = NULL, save_pdf_prefix = NULL,
  include_control_regions = TRUE, guitar_coordinate = NULL,
  save_dir = ".")

\S4method{plotGuitar}{SummarizedExomePeak}(sep, txdb = NULL,
  save_pdf_prefix = NULL, include_control_regions = TRUE,
  guitar_coordinate = NULL, save_dir = ".")
}
\arguments{
\item{sep}{a \code{\link{SummarizedExomePeaks}} object.}

\item{txdb}{a \code{\link{TxDb}} object containing the transcript annotation.}

\item{save_pdf_prefix}{a \code{character}, if provided, a pdf file with the given name will be saved under the current directory.}

\item{include_control_regions}{a \code{logical} for whether to plot the control regions together with the modification regions.}

\item{guitar_coordinate}{optional, the guitar coordinate of the transcript annotation.}

\item{save_dir}{optional, a \code{character} indicating the directory to save the plot; default ".".}
}
\value{
a \code{ggplot} object
}
\description{
\code{plotGuitar} provides visualization of the peaks/sites' distribution on travis coordinate for the \code{\link{SummarizedExomePeaks}} object.
}
\details{
If the SummarizedExomePeaks object contains quantification results for modification, the significantly modified peaks
with IP to input log2FC > 0 and DESeq2 Wald test padj < 0.05 will be plotted.

If the SummarizedExomePeaks object contains quantification results for differential modification, both the hyper modification
and hypo modification peaks with DESeq2 Wald test p values < 0.05 will be plotted.
}
\examples{
\dontrun{
sep #a SummarizedExomePeak object
txdb #a TxDb object
plotExonLength(sep,txdb)
}

}
