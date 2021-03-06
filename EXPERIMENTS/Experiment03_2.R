## Experiment03_2.R
## vc = C2, m=2
## Power of transition variable selection procedure, table 3
## author: Yukai Yang
## CORE, Université catholique de Louvain
## April 2014

rm(list=ls(all=TRUE))
source("PSTR.R")

## initialization part

# number of nonlinear components
ir = 1
ikk = ir+2

# the seed for random number generator
seed = 1

vT = c(5,10,20)
vN = c(20,40,80,160)

# number of replications
iM = 10000

# 
msigma = 10

## parameters

kappa = c(0.2, 0.2, rep(2.45,ir))
Theta = diag(c(0.5, 0.4, rep(0.3,ir)), ir+2)
mR = diag(1, ir+2); mR[mR==0] = 1/3
mD = diag(sqrt(0.3), ir+2)
mSigma = mD%*%mR%*%t(mD)
chS = chol(mSigma)

B01 = c(1,1)

# parameters in the nonlinear part
B1 = c(0.7,0.7)
GA = 4; C1 = 3.5; C2 = c(3,4)

## some temporary functions

# rho
rho = c(0, 0.2, 0.5, 0.9)

# heteroskedastic
ftmp2 <- function(inn){
  mXX = matrix(0,iT+1,ikk); vY = NULL
  for(itt in 2:(iT+1)){
    mXX[itt,] = Theta%*%mXX[itt-1,] + kappa + c(rnorm(ikk) %*% chS)
    tmp = fTF(vx=rep(mXX[itt,3],length(vc)),gamma=GA,vc=vc)
    vY = c(vY, mu[inn] + (B02[,inn] + B1*tmp)%*%c(mXX[itt,1:2]) + rnorm(1) )
  }
  for(iter in 1:length(rho)){
    tmp = rho[iter]/sqrt(1-rho[iter]*rho[iter])
    mXX = cbind(mXX, tmp*mXX[,ikk]+rnorm(iT+1)*sqrt(3/9.1))
  }
  return(cbind(vY,mXX[2:(iT+1),]))
}

set.seed(seed)

## experiment

# order T N type
aRet = array(0, dim=c(length(vT),length(vN),iM,5))

cat("Experiment 03_2 starts!\n")
ptm <- proc.time()

for(tter in 1:length(vT)) for(nter in 1:length(vN)){

  iT = vT[tter]; iN = vN[nter]

  for(mter in 1:iM){

    # different from 03_1
    vc = C2

    mu = rnorm(iN)*msigma
    B02 = matrix(rnorm(iN*2),2,iN) + B01

    ret = sapply(1:iN,ftmp2)
    mX2 = array(ret,c(iT,ikk+1+length(rho),iN))

    RET0 = LinTest(aDat=mX2,im=3)
    RET1 = LinTest(aDat=mX2,im=3,iq=5)
    RET2 = LinTest(aDat=mX2,im=3,iq=6)
    RET3 = LinTest(aDat=mX2,im=3,iq=7)
    RET4 = LinTest(aDat=mX2,im=3,iq=8)

    aRet[tter,nter,mter,5] = RET0[[3]]$PV2_F
    aRet[tter,nter,mter,1] = RET1[[3]]$PV2_F
    aRet[tter,nter,mter,2] = RET2[[3]]$PV2_F
    aRet[tter,nter,mter,3] = RET3[[3]]$PV2_F
    aRet[tter,nter,mter,4] = RET4[[3]]$PV2_F

  }

  cat(">")

}

save.image("RESULTS/EXPERIMENT03_2.RData")

proc.time() - ptm
cat("Done!\n")