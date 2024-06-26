FAMD <- function(base, ncp = 5, graph = TRUE, sup.var=NULL, ind.sup = NULL, axes=c(1,2),row.w=NULL, tab.disj=NULL){
	
    # Function to compute the weighted mean of a table
    moy.ptab <- function(V, poids) {
        as.vector(crossprod(poids/sum(poids),as.matrix(V)))
    }

	# Function to compute the weighted standard deviation of a table
    ec.tab <- function(V, poids) {
        ecart.type <- sqrt(as.vector(crossprod(poids/sum(poids),as.matrix(V^2))))
		ecart.type[ecart.type <= 1e-16] <- 1
        return(ecart.type)
    }

    # Function to compute the weighted eta^2
	fct.eta2 <- function(vec,x,weights) {   ## pb avec les poids
      VB <- function(xx) {
	    return(sum((colSums((tt*xx)*weights)^2)/ni))
      }
      tt <- tab.disjonctif(vec)
      ni <- colSums(tt*weights)
      unlist(lapply(as.data.frame(x),VB))/colSums(x^2*weights)
    }

    # Add a name to columns and rows
    if (is.null(rownames(base))) rownames(base) <- 1:nrow(base)
    if (is.null(colnames(base))) colnames(base) <- paste("V",1:ncol(base),sep="")

    #if (!is.null(sup.var) & !is.numeric(sup.var)) sup.var<- which(colnames(base)%in%sup.var) #sup.var = NULL, it doesn;t work
	
    # Make sure that the data is a data frame
    base <- as.data.frame(base)

    # Transform the data into a level factor(not ordered)
    is.quali <- which(!unlist(lapply(base,is.numeric)))
    base[,is.quali] <- lapply(base[,is.quali,drop=FALSE],as.factor)
	base <- droplevels(base)

    # Set the weights. In our case, we get only get 1 1 1 1 ... So, we can ignore row.w
	row.w.init <- row.w
	if (is.null(row.w)) { row.w.init <- row.w <- rep(1,nrow(base)-length(ind.sup)) }
	row.w <- rep(0,nrow(base))
	row.w[which(!((1:nrow(base))%in%ind.sup))] <- row.w.init
	
	# seperate numeric and cataegorical variables
	numAct <- which(sapply(base,is.numeric)) # Continuous variables
	if (is.null(numAct)) stop("All your variables are quantitative: you should use PCA")
	facAct <- which(!sapply(base,is.numeric)) # Cataegorical variables
    if (is.null(facAct)) stop("All your variables are qualitative: you should use MCA")

    # Initialize the variables to NULL
	facIllu <- numIllu <- tabFacIllu <- tabNumIllu <- NULL
    
	# if (!is.null(sup.var)){ #sup.var = NULL, it doesn;t work
    #   act.var <- (1:ncol(base))[-sup.var]
	#   numIllu <- intersect(sup.var,numAct)
	#   if (length(numIllu)==0) numIllu <- NULL
	#   else numAct <- intersect(act.var,numAct)
	#   facIllu <- intersect(sup.var,facAct)
	#   if (length(facIllu)==0) facIllu <- NULL
	#   else facAct <- intersect(act.var,facAct)
	# }

	if (!is.null(tab.disj)){
	#   aa <- c(0,cumsum(sapply(base,nlevels)+1-(sapply(base,nlevels)>0))) # tab.disj = NULL, it doesn;t work
	#   ll <- list()
	#   for  (i in 1:(length(aa)-1)) ll[[i]] <- (aa[i]+1):aa[i+1]
	#   # QuantiAct <- tab.disj[,unlist(ll[which(sapply(ll,length)==1)])]
	#   # QualiAct <- tab.disj[,unlist(ll[which(sapply(ll,length)!=1)])]
	#   QuantiAct <- tab.disj[,unlist(ll[intersect(numAct,which(sapply(ll,length)==1))]),drop=FALSE]
	#   QualiAct <- tab.disj[,unlist(ll[intersect(facAct,which(sapply(ll,length)!=1))])]
	} else {
      # Make matrix of continuous variables
 	  QuantiAct <- as.matrix(base[,numAct,drop=FALSE])
      # Make matrix of categorical variables as binary table for analysis it's catagory as identity variable # nolint
	  QualiAct <- tab.disjonctif(base[,facAct,drop=FALSE])
	}

    # Normalize the data
	centre <- moy.ptab(QuantiAct,row.w)
	QuantiAct <- t(t(QuantiAct)-centre)
	ecart.type <- ec.tab(QuantiAct,row.w)
	QuantiAct <- t(t(QuantiAct)/ecart.type)

    # Centralize the data
    prop <- colSums(QualiAct*(row.w/sum(row.w)))
	QualiAct <- t(t(QualiAct)- moy.ptab(QualiAct,row.w))
	QualiAct <- t(t(QualiAct)/sqrt(prop))

    # Combine two matrix as columns to make big matrix
	X <- cbind(QuantiAct,QualiAct)

	# if (!is.null(numIllu)){ # numIllu = NULL, it doesn;t work
	#   if (!is.null(tab.disj)){
	#     QuantiIllu <- tab.disj[,unlist(ll[intersect(numIllu,which(sapply(ll,length)==1))]),drop=FALSE]
	#   } else {
	#     QuantiIllu <- as.matrix(base[,numIllu,drop=FALSE])
	#   }
	#   QuantiIllu <- t(t(QuantiIllu)-moy.ptab(QuantiIllu,row.w))
	#   QuantiIllu <- t(t(QuantiIllu)/ec.tab(QuantiIllu,row.w))
	#   tabNumIllu <- (ncol(X)+1):(ncol(X)+ncol(QuantiIllu))
	#   X <- cbind(X,QuantiIllu)
	# }
	# if (!is.null(facIllu)){ # facIllu = NULL, it doesn;t work
	#   if (!is.null(tab.disj)){
	#     QualiIllu <- tab.disj[,unlist(ll[intersect(facIllu,which(sapply(ll,length)!=1))])]
    #     propsup <- colSums(QualiIllu*(row.w/sum(row.w)))
	#     QualiIllu <- t(t(QualiIllu)- moy.ptab(QualiIllu,row.w))
	#     QualiIllu <- t(t(QualiIllu)/sqrt(propsup))
	#     tabFacIllu <- (ncol(X)+1):(ncol(X)+ncol(QualiIllu))
	#     X <- cbind(X,QualiIllu)
	#   } else {
	#     tabFacIllu <- (ncol(X)+1):(ncol(X)+length(facIllu))
	#     X <- cbind.data.frame(X,base[,facIllu,drop=FALSE])
	#   }
    # }
    
    # Set the number of components select one of them (ncp, data row count -1, continuous variable column count + categorical variable column count - cataegorical variable count)
	ncp <- min(ncp,nrow(base)-1,ncol(QuantiAct)+ncol(QualiAct)-length(facAct))

    # Do the PCA same as PCA(X,ncp=ncp) row.w.init is 1 1 1 .. and other parameters are NULL or FALSE
	if (is.null(tab.disj) | is.null(facIllu)) pca <- PCA(X,graph=FALSE,ind.sup=ind.sup,quanti.sup=tabNumIllu,quali.sup=tabFacIllu,scale.unit=FALSE,row.w=row.w.init,ncp=ncp)
	#else pca <- PCA(X,graph=FALSE,ind.sup=ind.sup,quanti.sup=c(tabNumIllu,tabFacIllu),scale.unit=FALSE,row.w=row.w.init,ncp=ncp) # tab.disj = NULL, it doesn;t work
	
    # Get the eigen value from 1 to ncp
    eig <- pca$eig[1:ncp,,drop=FALSE]

    # Get eigen vector of categorical variables
    ind.quali <- which(!(rownames(pca$var$coord)%in%colnames(base)[numAct]))

    # Get the eigen vector of continuous variables and cosine square and contribution
    quanti.var <- list(coord=pca$var$coord[colnames(base)[numAct],,drop=FALSE],cos2=pca$var$cos2[colnames(base)[numAct],,drop=FALSE],contrib=pca$var$contrib[colnames(base)[numAct],,drop=FALSE])
    
    # Function weighted mean of a factor
	tt <- function(v,mat,poids) {
	  res <- matrix(NA,nrow=0,ncol=ncol(mat))
	  for (i in 1:nlevels(v)) {
	    res <- rbind(res,crossprod(poids[v==levels(v)[i]]/sum(poids[v==levels(v)[i]]),as.matrix(mat[v==levels(v)[i],,drop=FALSE])))
      }
	  return(res)
    }
	  
	# aux1 <- lapply(base[,facAct,drop=FALSE],tt,X[,1:(ncol(X)-length(tabNumIllu)-length(tabFacIllu)),drop=FALSE],poids=row.w.init)
	if (is.null(tab.disj)){

      # Get the weighted mean of a each factor's each cataegory
      #     ex) we have cataegory Alpha=['a','b','c'], XYZ=['x','y','z']. 
      #     aux1[0] has the weighted mean of all columns Alpha's 'a','b','c' cataegory
      #     aux1[1] has the weighted mean of all columns XYZ's 'x','y','z' cataegory
 	  aux1 <- lapply(base[,facAct,drop=FALSE],tt,X[,1:(ncol(QuantiAct)+ncol(QualiAct)),drop=FALSE],poids=row.w.init)

      # combine all the weighted mean of each factor's each cataegory
      bary <- NULL
	  for (i in 1:length(aux1)) bary <- rbind(bary,aux1[[i]])
	  rownames(bary) <- unlist(sapply(base[,facAct,drop=FALSE],levels))
	} else {
	#   if (is.null(ind.sup)){ # tab.disj = NULL, it doesn;t work
	# 	auxb <- sweep(tab.disj[,unlist(ll[intersect(facAct,which(sapply(ll,length)!=1))]),drop=FALSE],1,row.w.init,FUN="*")
	#     bary <- crossprod(sweep(auxb,2,apply(auxb,2,sum),FUN="/"),as.matrix(X[,1:(ncol(QuantiAct)+ncol(QualiAct)),drop=FALSE]))
	#   } else{
	# 	auxb <- sweep(tab.disj[-ind.sup,unlist(ll[intersect(facAct,which(sapply(ll,length)!=1))]),drop=FALSE],1,row.w.init,FUN="*")
	#     bary <- crossprod(sweep(auxb,2,apply(auxb,2,sum),FUN="/"),as.matrix(X[-ind.sup,1:(ncol(QuantiAct)+ncol(QualiAct)),drop=FALSE]))
	#   }
	}

    # Get the distance square of each cataegory
	dist2 <- rowSums(bary^2)

    # Get the eigen vector of categorical variables scaled by the square root of the eigen value
    coord.quali.var <- t(t(pca$var$coord[ind.quali,,drop=FALSE]/sqrt(prop))*sqrt(eig[1:ncp,1]))
    # Get the eigen vector of categorical variables and cosine square and contribution
    quali.var <- list(coord=coord.quali.var,cos2=coord.quali.var^2/dist2,contrib=pca$var$contrib[ind.quali,,drop=FALSE])
    # Get the eigen vector of categorical variables
	vtest <- pca$var$coord[ind.quali,,drop=FALSE]

    # Show weighted mean of each factor's each cataegory. in out case, it shows count of each cataegory
	if (sum(row.w.init)>1) nombre <-  prop*sum(row.w.init) 
	else nombre <-  prop*(nrow(base)-length(ind.sup))   ## nombre = n # row.w.init = 1 1 1 1 ... so it doesn;t go
	
    # Get ratio of each cataegory by weighted mean
	if (sum(row.w.init)>1) {
	  nombre <- (sum(row.w.init) - nombre)
	  nombre <- nombre/(sum(row.w.init) - 1)/(sum(row.w.init))
	} else {
	#   nombre <- (nrow(base)-length(ind.sup))- nombre # row.w.init = 1 1 1 1 ... so it doesn;t go
    #   nombre <- nombre / (nrow(base)-length(ind.sup)-1)/(nrow(base)-length(ind.sup))  ## nombre = (N-n)/(N-1)
	}
    # Devide the eigen vector by the square root of the weighted mean
    #   Is this came from MCA?
    vtest <- vtest/sqrt(nombre)
    quali.var$v.test <- vtest

    # Calcualte eta^2 of each factor(cataegoty variable)
	res.var <- list()
    eta2 <- matrix(NA, length(facAct), ncp)
    colnames(eta2) <- paste("Dim", 1:ncp)
    rownames(eta2) <- attributes(base)$names[facAct]
	if (ncp>1) eta2 <- t(sapply(as.data.frame(base[rownames(pca$ind$coord), facAct,drop=FALSE]),fct.eta2,pca$ind$coord,weights=row.w.init/sum(row.w.init)))
	else {
	   eta2 <- as.matrix(sapply(as.data.frame(base[rownames(pca$ind$coord), facAct,drop=FALSE]),fct.eta2,pca$ind$coord,weights=row.w.init/sum(row.w.init)),ncol=ncp)
	}

    # Calculate eigen vector's square and eta^2 of each factor(cataegoty variable) to show the contribution of each eigen vector
    # It can be used as eigen vector
	res.var$coord <- rbind(quanti.var$coord^2,eta2)

    # Levelize by catagoery's total contribution 
	aux <- aggregate(quali.var$contrib,by=list(as.factor(rep.int(1:length(facAct),times=sapply(base[,facAct,drop=FALSE],nlevels)))),FUN=sum)[,-1,drop=FALSE]
	aux <- as.matrix(aux)

    # Add names
	colnames(aux) <- colnames(quanti.var$contrib)
    rownames(aux) <- attributes(base)$names[facAct]

    # Combine contribution from continuous and categorical variables
	res.var$contrib <- rbind(quanti.var$contrib,aux)
    # Combine cosine square from continuous and categorical variables
	res.var$cos2 <- rbind(quanti.var$cos2^2,eta2^2/(sapply(base[,facAct,drop=FALSE],nlevels)-1))
    if (is.null(tab.disj)){
	  # if (!is.null(pca$quanti.sup)&!is.null(pca$quali.sup)) {
	#   if (!is.null(numIllu)&!is.null(facIllu)) { # numIllu = NULL, facIllu = NULL, it doesn;t work
	#     res.var$coord.sup <- rbind(pca$quanti.sup$coord^2,pca$quali.sup$eta2)
	#     res.var$cos2.sup <- rbind(pca$quanti.sup$cos2^2,pca$quali.sup$eta2^2/(sapply(base[,facIllu,drop=FALSE],nlevels)-1))
	#   }
	#   if (is.null(numIllu)&!is.null(facIllu)) {
	#     res.var$coord.sup <- pca$quali.sup$eta2
	#     res.var$cos2.sup <- pca$quali.sup$eta2^2/(sapply(base[,facIllu,drop=FALSE],nlevels)-1)
	#   }
	} else { # tab.disj = NULL, it doesn;t work
    #   if (!is.null(facIllu)){
    #     ## ajout pour sup et tab.disj
	#     # aux1 <- lapply(base[,facIllu,drop=FALSE],tt,X[,1:(ncol(X)-length(tabNumIllu)-length(tabFacIllu)),drop=FALSE],poids=row.w.init)
	#     if (is.null(ind.sup)){
	# 	  auxb <- sweep(tab.disj[,unlist(ll[intersect(facIllu,which(sapply(ll,length)!=1))]),drop=FALSE],1,row.w.init,FUN="*")
	#       barysup <- crossprod(sweep(auxb,2,apply(auxb,2,sum),FUN="/"),as.matrix(X[,1:(ncol(QuantiAct)+ncol(QualiAct)),drop=FALSE]))
	#     } else{
	# 	  auxb <- sweep(tab.disj[-ind.sup,unlist(ll[intersect(facIllu,which(sapply(ll,length)!=1))]),drop=FALSE],1,row.w.init,FUN="*")
	#       barysup <- crossprod(sweep(auxb,2,apply(auxb,2,sum),FUN="/"),as.matrix(X[-ind.sup,1:(ncol(QuantiAct)+ncol(QualiAct)),drop=FALSE]))
	#     }
	# 	dist2sup <- rowSums(barysup^2)

	# 	ind.quali.sup <- (length(numIllu)+1):nrow(pca$quanti.sup$coord)
    #     coord.quali.sup <- t(t(pca$quanti.sup$coord[ind.quali.sup,,drop=FALSE]/sqrt(propsup))*sqrt(eig[1:ncp,1]))
    #     quali.sup <- list(coord=coord.quali.sup,cos2=coord.quali.sup^2/dist2sup)

	#     vtest <- pca$quanti.sup$coord[ind.quali.sup,,drop=FALSE]
	#     if (sum(row.w.init)>1) nombre <-  propsup*sum(row.w.init)
	#     else nombre <-  propsup*(nrow(base)-length(ind.sup))   ## nombre = n
	
    # 	if (sum(row.w.init)>1) {
	#       nombre <- (sum(row.w.init) - nombre)
	#       nombre <- nombre/(sum(row.w.init) - 1)/(sum(row.w.init))
	#     } else {
	#       nombre <- (nrow(base)-length(ind.sup))- nombre
    #       nombre <- nombre / (nrow(base)-length(ind.sup)-1)/(nrow(base)-length(ind.sup))  ## nombre = (N-n)/(N-1)
	#     }
    #     vtest <- vtest/sqrt(nombre)
    #     quali.sup$v.test <- vtest
    #     ## fin ajout pour sup et tab.disj
        
	# 	eta2sup <- matrix(NA, length(facIllu), ncp)
    #     colnames(eta2sup) <- paste("Dim", 1:ncp)
    #     rownames(eta2sup) <- attributes(base)$names[facIllu]
	#     if (ncp>1) eta2sup <- t(sapply(as.data.frame(base[rownames(pca$ind$coord), facIllu,drop=FALSE]),fct.eta2,pca$ind$coord,weights=row.w.init/sum(row.w.init)))
	#     else {
	#      eta2sup <- as.matrix(sapply(as.data.frame(base[rownames(pca$ind$coord), facIllu,drop=FALSE]),fct.eta2,pca$ind$coord,weights=row.w.init/sum(row.w.init)),ncol=ncp)
	#     }
	#     if (!is.null(numIllu)) {
	#       res.var$coord.sup <- rbind(pca$quanti.sup$coord[1:length(numIllu),,drop=FALSE]^2,eta2sup)
	#       res.var$cos2.sup <- rbind(pca$quanti.sup$cos2[1:length(numIllu),,drop=FALSE]^2,eta2sup^2/(sapply(base[,facIllu,drop=FALSE],nlevels)-1))
	#     }
	#     if (is.null(numIllu)) {
	#       res.var$coord.sup <- eta2sup
	#       res.var$cos2.sup <- eta2sup^2/(sapply(base[,facIllu,drop=FALSE],nlevels)-1)
	#     }
	# 	quali.sup$dist <- sqrt(dist2sup)
	# 	quali.sup$eta2 <- eta2sup
	#   }
	}
	# if (!is.null(numIllu)&is.null(facIllu)) { # numIllu = NULL, facIllu = NULL, it doesn;t work
	#   res.var$coord.sup <- pca$quanti.sup$coord^2
	#   res.var$cos2.sup <- pca$quanti.sup$cos2^2
	# }
    
    # Apply results in res
    res <- list(eig=eig,ind=pca$ind)
	if (!is.null(pca$ind.sup)) res$ind.sup <- pca$ind.sup
    res$var <- res.var
	res$quali.var <- quali.var
	res$quanti.var <- quanti.var
    if (is.null(tab.disj)){
      if (!is.null(pca$quanti.sup)) res$quanti.sup <- pca$quanti.sup
	  if (!is.null(pca$quali.sup)) res$quali.sup <- pca$quali.sup
	}else {
    #   if (!is.null(numIllu)){ # tab.disj = NULL, it doesn;t work
	#     res$quanti.sup$coord <- pca$quanti.sup$coord[1:length(numIllu),,drop=FALSE]
	#     res$quanti.sup$cor <- pca$quanti.sup$cor[1:length(numIllu),,drop=FALSE]
	#     res$quanti.sup$cos2 <- pca$quanti.sup$cos2[1:length(numIllu),,drop=FALSE]
	#   }
	#   if (!is.null(facIllu)) res$quali.sup <- quali.sup
	}
	res$svd <- pca$svd
    res$call <- pca$call
	res$call$X <- base
	res$call$centre <- c(centre,prop)
	res$call$ecart.type <- c(ecart.type,rep(0,length(prop)))
	res$call$quali.sup$quali.sup <- base[,c(facAct,facIllu),drop=FALSE]
	res$call$type <- rep("s",ncol(base))
	res$call$type[c(facAct,facIllu)] <- "n"
	res$call$nature.var <- rep("quanti",ncol(base))
	res$call$nature.var[facAct] <- "quali"
	# if (!is.null(facIllu)) res$call$nature.var[facIllu] <- "quali.sup" # facIllu = NULL, it doesn;t work
	# if (!is.null(numIllu)) res$call$nature.var[numIllu] <- "quanti.sup" # numIllu = NULL, it doesn;t work
	res$call$call <- match.call()
	res$call$prop <- prop
	res$call$sup.var <- sup.var
#	res$call$call <- sys.calls()[[1]]
    class(res) <- c("FAMD", "list")
	 if (graph & (ncp>1)){
       print(plot.FAMD(res,choix="ind", axes=axes,habillage="none"))
       print(plot.FAMD(res,choix="ind", invisible=c("quali","quali.sup"),axes=axes,habillage="none",new.plot=TRUE))
       print(plot.FAMD(res,choix="var",axes=axes,new.plot=TRUE))
       print(plot.FAMD(res,choix="quali", axes=axes,habillage="none",new.plot=TRUE))
       print(plot.FAMD(res,choix="quanti",axes=axes,new.plot=TRUE))
     }
	return(res)
}
