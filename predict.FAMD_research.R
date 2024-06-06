predict.FAMD <- function(object, newdata, ...){
    if (!inherits(object, "FAMD")) print("object should be a FAMD object")
    if (!is.null(colnames(newdata))) {
	  if (any(!(rownames(object$var$coord)%in%colnames(newdata)))) warning("The names of the variables is not the same as the ones in the active variables of the FAMD result")
	}
#	object <- object$call$object   ## ne pas utiliser les noms des variables comme dans les autres fonctions car les variables sont reordonnees

    ecart.type <- object$call$ecart.type
	# mean of the variables
    centre <- object$call$centre
	# mean of the categories
    prop <- object$call$prop
	# coord of the variables(not dummied)
	ncp <- ncol(object$var$coord)
	illu <- object$call$sup.var # NULL
    if (length(illu)>0) object$call$X <- object$call$X[,-illu]
	newdata <- newdata[,colnames(object$call$X)]
	if (length(unlist(mapply(setdiff, lapply(newdata,levels), lapply(object$call$X,levels)))) > 0){
	  cat("The following categories are not in the active dataset:\n")
	  for (i in 1:ncol(newdata)) {
	    if (sum(!levels(newdata[,i])%in%levels(object$call$X[,i]))>0) cat("Categori(es):",levels(newdata[,i])[which(!levels(newdata[,i])%in%levels(object$call$X[,i]))]," from variable",colnames(newdata)[i],"\n")
	  }
	  stop("Modify your object newdata")
	}
	# Combine the newdata and the old data
	newdata <- rbind.data.frame(object$call$X,newdata)[-(1:nrow(object$call$X)),,drop=FALSE]
	if (!is.null(object$call$sup.var)) { # It doesn;t work. sup.var is NULL
	  numAct <- which((object$call$type=="s")[-object$call$sup.var])
	  facAct <- which((object$call$type=="n")[-object$call$sup.var])
	}
	else {
	  numAct <- which(object$call$type=="s") # get the index of the numerical variables
	  facAct <- which(object$call$type=="n") # get the index of the categorical variables
	}
    if (is.null(ecart.type)) ecart.type <- rep(1, length(centre)) # it doesn;t work. ecart.type is NULL
	# Standarize the numerical variables by old data's mean and standard deviation
    QuantiAct <- as.matrix(newdata[,numAct,drop=FALSE])
	QuantiAct <- t(t(QuantiAct)-centre[1:length(numAct)])
	QuantiAct <- t(t(QuantiAct)/ecart.type[1:length(numAct)])
	
	# Centralize the dummied variables by the old data's mean
	QualiAct <- tab.disjonctif(newdata[,facAct,drop=FALSE])
	QualiAct <- t(t(QualiAct)- prop)
	QualiAct <- t(t(QualiAct)/sqrt(prop))

	# combine the numerical and dummied variables
	tab.newdata <- cbind(QuantiAct,QualiAct)
    marge.col <- object$call$marge.col # NULL
	
	# Multiply new data and V for get coordiantes
    coord <- crossprod(t(as.matrix(tab.newdata)),object$svd$V)

	# Get analysis of the new data
    dist2 <- rowSums(tab.newdata^2)
    cos2 <- coord^2/dist2
    coord <- coord[, 1:ncp,drop=FALSE]
    cos2 <- cos2[, 1:ncp,drop=FALSE]
	# Set the names of the columns and rows
    colnames(coord) <- colnames(cos2) <- paste("Dim", 1:ncp)
    rownames(coord) <- rownames(cos2) <- rownames(newdata)
    result <- list(coord = coord, cos2 = cos2, dist2 = sqrt(dist2))
	return(result)
}
