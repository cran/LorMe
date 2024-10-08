% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/network_analysis2.R
\name{network_analysis2}
\alias{network_analysis2}
\title{Conduct Network analysis}
\usage{
network_analysis2(
  input,
  inputtype,
  n,
  threshold,
  method = "spearman",
  display = TRUE,
  input2,
  input2type
)
}
\arguments{
\item{input}{Input dataframe with otu/gene/taxa in row and sample ID in column,at least 5 replicates(more than 8 replicates are recommened).}

\item{inputtype}{Input dataframe type

1:dataframe with first column of OTUID and last column of taxonomy

2:dataframe with first column of OTUID/taxonomy

3:dataframe of all numeric}

\item{n}{Only keep otu/gene/taxa appearing in n sample size}

\item{threshold}{Threshold of correlation r value}

\item{method}{A character string indicating which correlation coefficient  is to be computed. One of "pearson" or "spearman"}

\item{display}{If display a preview plot of network based on igraph. FALSE for the first attempt is recommended in case of too many vertices and edges.}

\item{input2}{A second input data frame with otu/gene/taxa in row and sample ID in column. Default:NULL}

\item{input2type}{The second input data frame type. Details the same as above. Default:NULL}
}
\value{
One list contains a statistics table of network vertices/nodes and an adjacency table. One preview plot of network in the plot interface and an igraph object(named \code{igraph1}) in global environment.
}
\description{
A convenient and fast network analysis function, with output results suitable for cytoscape and gephi
}
\details{
\enumerate{
\item We had optimized the correlation algorithm to achieve a faster running speed. It takes less than 2 minute to calculate dataframe correlation and p value which more than 400 samples and 10000 OTUs for computer with dual Core i5 processor.
However, too many vertices(>2000) or links(>10000) may slow the statistical process and visualization,so we recommend that in your first attempt,set \code{display} paramter as \code{F} to have a preview.
Then you can adjust your n/threshold/method paramter to generate a suitable visualization network
\item We display a preview plot so as to adjusting your network. Generally a global figure (like we show in examples) with less than 1000 vertices and 5000 edges/links
is recommended. Further more,we recommend you to output the statistics and adjacency table and use software like cytoscape or gephi for better visualization.
}
}
\note{
\enumerate{
\item Replicates should be at least 5,more than 8 is recommend.
\item In case of too many edges/links or not a global network plot, you can stop the process immediately to provent wasting too much time.
}
}
\examples{
\donttest{
{
  ### Data preparation ###
  data(testotu)
  rownames(testotu) <- testotu[, 1]
  inputotu <- testotu[, -c(1, ncol(testotu))]
  head(inputotu)
  set.seed(999)
  ### One input network analysis ###
  network_result <- network_analysis2(
    inputotu,
    3,
    10,
    0.9,
    "spearman",
    TRUE
  )

  # Nodes information table
  network_nodes <- network_result$Nodes_info
  head(network_nodes)

  # Adjacency table
  network_adjacency <- network_result$Adjacency_column_table
  head(network_adjacency)

  # Complete adjacency matrix
  network_matrix <- network_result$Adjacency_matrix
  print(network_matrix[1:10, 1:10])

  # igraph object
  igraph_object <- network_result$Igraph_object
  network_stat(igraph_object)  # In case you want to see statistics again
  # or do other analysis based on igraph.

  ### Two inputs network analysis ###
  inputotu1 <- inputotu[1:456, ]
  inputotu2 <- inputotu[524:975, ]
  network_result <- network_analysis2(
    input = inputotu1,
    inputtype = 3,
    input2 = inputotu2,
    input2type = 3,
    n = 10,
    threshold = 0.85,
    method = "spearman",
    display = TRUE
  )

  #### Incorrect demonstration !! ###
  {
     network_result <- network_analysis2(inputotu, 3, 3, 0.8, "spearman", TRUE)
  }
  # Total edges/links: 10199
  # Total vertices: 826
  # Too many edges and not a global network

}
}
}
\author{
Wang Ningqi \href{mailto:2434066068@qq.com}{2434066068@qq.com}
}
