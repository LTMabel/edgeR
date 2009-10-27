calcNormFactors <- function(dataMatrix, refColumn=1, logratioTrim=.3, sumTrim=0.05) {
  if( !is.matrix(dataMatrix) )
    stop("'dataMatrix' needs to be a matrix")
  if( refColumn > ncol(dataMatrix) )
    stop("Invalid 'refColumn' argument")
  apply(dataMatrix,2,.calcFactorWeighted,ref=dataMatrix[,refColumn], logratioTrim=logratioTrim, sumTrim=sumTrim)
}

.calcFactorWeighted <- function(obs, ref, logratioTrim=.3, sumTrim=0.05) {

  if( all(obs==ref) )
    return(1)

  nO <- sum(obs)
  nR <- sum(ref)
  logR <- log2((obs/nO)/(ref/nR))         # log ratio of expression, accounting for library size
  absE <- log2(obs/nO) + log2(ref/nR)     # absolute expression
  v <- (nO-obs)/nO/obs + (nR-ref)/nR/ref  # estimated asymptotic variance
  
  fin <- is.finite(logR) & is.finite(absE)
  
  logR <- logR[fin]
  absE <- absE[fin]
  v <- v[fin]

  # taken from the original mean() function
  n <- sum(fin)
  loL <- floor(n * logratioTrim) + 1
  hiL <- n + 1 - loL
  loS <- floor(n * sumTrim) + 1
  hiS <- n + 1 - loS
  
  keep <- (rank(logR) %in% loL:hiL) & (rank(absE) %in% loS:hiS)
  2^( sum(logR[keep]/v[keep], na.rm=TRUE) / sum(1/v[keep], na.rm=TRUE) )
}
  
