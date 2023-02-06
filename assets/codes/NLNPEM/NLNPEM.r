###############################################################
###    MOXstat
###    Author: L. Azzimonti 
###    Title: "Nonlinear nonparametric mixed-effects models for unsupervised classification"
###    In collaboration with: F. Ieva, A.M. Paganoni
###    Reference: "Nonlinear nonparametric mixed-effects models for unsupervised classification"
###	 		accepted on Computational Statistics
###    Date: October 8 2012
###############################################################

rm(list=ls(all=TRUE))
setwd('C:/Users/LaURa/Documents/codici R/NP')

#load data
dati<-read.table('Lineare_2x2 gruppi_0var.txt',header=TRUE)


n=dim(dati)[1] 	#number of longitudinal curves
nt=dim(dati)[2] 	# number of observations for each curve
t=seq(1,nt,length=nt) #abscissa

#plot data
col=rainbow(n)
plot(0,0,type='n',xlim=c(min(t),max(t)),ylim=c(min(dati),max(dati)),xlab='',ylab='')
for(i in 1:n){
points(t,dati[i,],type='l',lty=2,col=col[i])
}

##################
#chose your model#
#linear          #
#logistic        #
#exponential     #
##################

model_name='linear'

########################################
#chose the fixed and the random effects#
########################################
n_ran=2 		#number of random parameters
random_param=1	#which parameter/s is/are random?

###################################
#chose balanced or unbalanced case#
###################################
unbalanced=FALSE	#flag for the balanced/unbalanced case 

#models
#linear model (2 dimensional parameter)
#random 1 or 1 and 2
linear<-function(t,par1,par2){
par1*t+par2
}

#random 2
linear2<-function(t,par2,par1){
par1*t+par2
}

#logistic model (3 dimensional parameter)
#random 1 or 1 and 2 or 1 and 2 and 3
logistic<-function(t,par1,par2,par3){
par1/(1+exp((par2-t)/par3))
}


#random 2 and 2 and 3
logistic2<-function(t,par2,par3,par1){
par1/(1+exp((par2-t)/par3))
}

#random 3 or 3 and 1
logistic3<-function(t,par3,par1,par2){
par1/(1+exp((par2-t)/par3))
}


#exponential model
#random 1 or 1 and 2
esponenziale<-function(t,par1,par2){
return(par1*(1-exp(-par2*t)))
}

#random 2
esponenziale2<-function(t,par2,par1){
return(par1*(1-exp(-par2*t)))
}


#set model
if(model_name=='linear'){
if(random_param==1 | random_param==12){
model=linear
}
if(random_param==2){
model=linear2
}
n_par=2
#model.gr=c(linear.gr_1,linear.gr_2)
}
if(model_name=='logistic'){
if(random_param==1 | random_param==12 | random_param==123){
model=logistic
}
if(random_param==2 |random_param==23){
model=logistic2
}
if(random_param==3 | random_param==31){
model=logistic3
}
n_par=3
#model.gr=c(logistic.gr_1,logistic.gr_2,logistic.gr_3)
}
if(model_name=='exponential'){
if(random_param==1 | random_param==12){
model=esponenziale
}
if(random_param==2){
model=esponenziale2
}
n_par=2
#model.gr=c(esponenziale.gr_1,esponenziale.gr_2)
}

n_fix=n_par-n_ran #number of fixed parameters

#######################################
#chose the starting values for the nls#
#######################################
#########    WARNING!!!    ############
########### important!!!   ############
par1start=1
par2start=1
par3start=1

#inizialization of the fixed effects
dati_vect=as.vector(t(dati))
t_vect=rep(t,n)
if(n_par==2){
NLS<-nls(dati_vect~model(t_vect,par1,par2),start=c(par1=par1start,par2=par2start))
par1=as.numeric(coef(NLS)[1])
par2=as.numeric(coef(NLS)[2])
par3=0
sigma=summary(NLS)$sigma
}
if(n_par==3){
NLS<-nls(dati_vect~model(t_vect,par1,par2,par3),start=c(par1=par1start,par2=par2start,par3=par3start))
par1=as.numeric(coef(NLS)[1])
par2=as.numeric(coef(NLS)[2])
par3=as.numeric(coef(NLS)[3])
sigma=summary(NLS)$sigma
}


#inizialization of the discrete support of the random effects distribution
if(n>100){
nknots=100
}else{
nknots=n
}

#set the range of fixed and random effects
if(model_name=='linear'){
if(random_param==1 | random_param==12){
range1=c(min(dati[,nt]),max(dati[,nt]))/(max(t)-min(t))
range2=c(min(dati[,1]),max(dati[,1]))-c(range1[1],range1[2])
}
if(random_param==2){
range1=c(min(dati[,1]),max(dati[,1]))-c(range1[1],range1[2])
range2=c(min(dati[,nt]),max(dati[,nt]))/(max(t)-min(t))
}
}
if(model_name=='logistic'){
if(random_param==1 | random_param==12 | random_param==123){
range1=c(min(dati[,nt]),max(dati[,nt]))
range2=c(min(t),max(t))
range3=c(min(t),max(t))/2
}
if(random_param==2 | random_param==23){
range1=c(min(t),max(t))
range2=c(min(t),max(t))/2
}
if(random_param==3 | random_param==31){
range1=c(min(t),max(t))/2
range2=c(min(dati[,nt]),max(dati[,nt]))
}
}
if(model_name=='exponential'){
if(random_param==1 | random_param==12){
range1=c(min(dati[,nt]),max(dati[,nt]))
range2=c(min(t),max(t))/2
}
if(random_param==2){
range1=c(min(t),max(t))/2
range2=c(min(dati[,nt]),max(dati[,nt]))
}
}


range_ran1=range1
range_ran2=range2

#inizialization of random effects
if(n_ran==1){
knots=(range1[2]-range1[1])*runif(nknots)+range1[1]
knots=matrix(knots)
}
if(n_ran==2){
knots=cbind((range1[2]-range1[1])*runif(nknots)+range1[1],(range2[2]-range2[1])*runif(nknots)+range2[1])
}
weights=rep(1/nknots,nknots)

#function definitions for the update
#y is the vector of observations for the curve i

#distance
distE<-function(p1,p2){
return(sqrt(sum((p1-p2)^2)))
}

gaussian<-function(y,mean,sigma){
nn=length(y)
d=(1/(sigma*sqrt(2*pi))^nn)*exp(-sum((y-mean)^2)/(2*sigma^2))
return(d)
}

#computation of the likelihood function
loggaussian<-function(y,mean,sigma){
nn=dim(y)[2]
d=-nn/2*log(sigma^2)-colSums((t(y)-mean)^2)/(2*sigma^2)
return(d)
}

loggaussian.gr_mean<-function(y,mean,sigma){
nn=length(y)
2*sum(y-mean)/(2*sigma^2)
}

loggaussian.gr_sigma<-function(y,mean,sigma){
nn=length(y)
d=-nn/sigma+sum((y-mean)^2)/(sigma^3)
return(d)
}

#function maximized for the estimation of random effects
if(n_par==2){
if(n_ran==1){
change_point<-function(pos){
arg=-W[,index]%*%loggaussian(dati,model(t,pos,par2),sigma)
return(arg)
}
}
if(n_ran==2){
change_point<-function(pos){
arg=-W[,index]%*%loggaussian(dati,model(t,pos[1],pos[2]),sigma)
return(arg)
}
}
}
if(n_par==3){
if(n_ran==1){
change_point<-function(pos){
arg=-W[,index]%*%loggaussian(dati,model(t,pos,par2,par3),sigma)
return(arg)
}
}
if(n_ran==2){
change_point<-function(pos){
arg=-W[,index]%*%loggaussian(dati,model(t,pos[1],pos[2],par3),sigma)
return(arg)
}
}
}

#function maximized for the fixed effects estimation
if(n_par==2){
if(n_ran==1){
fixed_estimate<-function(x){
arg=0
for(index in 1:nknots){
arg=arg-W[,index]%*%loggaussian(dati,model(t,knots[index,1],x[1]),x[2])
}
return(arg)
}
}
if(n_ran==2){
fixed_estimate<-function(x){
arg=0
for(index in 1:nknots){
arg=arg-W[,index]%*%loggaussian(dati,model(t,knots[index,1],knots[index,2]),x)
}
return(arg)
}
}
}
if(n_par==3){
if(n_ran==1){
fixed_estimate<-function(x){
arg=0
for(index in 1:nknots){
arg=arg-W[,index]%*%loggaussian(dati,model(t,knots[index,1],x[1],x[2]),x[3])
}
return(arg)
}
}
if(n_ran==2){
fixed_estimate<-function(x){
arg=0
for(index in 1:nknots){
arg=arg-W[,index]%*%loggaussian(dati,model(t,knots[index,1],knots[index,2],x[1]),x[2])
}
return(arg)
}
}
}

#fixed_estimate.gr<-function(x){
#arg1=0
#arg2=0
#arg3=0
#id=which.max(W[i,])
#for(i in 1:n){
#arg1=arg1-loggaussian.gr_mean(dati[i,],logistic(t,knots[group[i],1],knots[group[i],2],x[2]),x[3])*logistic.gr_A(t,knots[group[i],1],knots[group[i],2],x[2])
#arg2=arg2-loggaussian.gr_mean(dati[i,],logistic(t,knots[group[i],1],knots[group[i],2],x[1]),x[2])*logistic.gr_s(t,knots[group[i],1],knots[group[i],2],x[1])
#arg3=arg3-loggaussian.gr_sigma(dati[i,],logistic(t,knots[group[i],1],knots[group[i],2],x[1]),x[2])
#}
#return(c(arg2,arg3))
#}

#computation of W_ij
if(n_par==2){
if(n_ran==1){
computeW<-function(){
W=matrix(0,n,nknots)
W_temp=matrix(0,n,nknots)
for(i in 1:n){
for(j in 1:nknots){
W_temp[i,j]=weights[j]*gaussian(dati[i,],model(t,knots[j,1],par2),sigma)
}
}
W_sum=rowSums(W_temp)
for(i in 1:n){
W[i,]=W_temp[i,]/W_sum[i]
}
return(W)
}
}
if(n_ran==2){
computeW<-function(){
W=matrix(0,n,nknots)
W_temp=matrix(0,n,nknots)
for(i in 1:n){
for(j in 1:nknots){
W_temp[i,j]=weights[j]*gaussian(dati[i,],model(t,knots[j,1],knots[j,2]),sigma)
}
}
W_sum=rowSums(W_temp)
for(i in 1:n){
W[i,]=W_temp[i,]/W_sum[i]
}
return(W)
}
}
}
if(n_par==3){
if(n_ran==1){
computeW<-function(){
W=matrix(0,n,nknots)
W_temp=matrix(0,n,nknots)
for(i in 1:n){
for(j in 1:nknots){
W_temp[i,j]=weights[j]*gaussian(dati[i,],model(t,knots[j,1],par2,par3),sigma)
}
}
W_sum=rowSums(W_temp)
for(i in 1:n){
W[i,]=W_temp[i,]/W_sum[i]
}
return(W)
}
}
if(n_ran==2){
computeW<-function(){
W=matrix(0,n,nknots)
W_temp=matrix(0,n,nknots)
for(i in 1:n){
for(j in 1:nknots){
W_temp[i,j]=weights[j]*gaussian(dati[i,],model(t,knots[j,1],knots[j,2],par3),sigma)
}
}
W_sum=rowSums(W_temp)
for(i in 1:n){
W[i,]=W_temp[i,]/W_sum[i]
}
return(W)
}
}
}

#random effects estimation
if(n_ran==1){
position<-function(){
posizione=optimize(change_point,interval=range1)
return(posizione$minimum)
}
}
if(n_ran==2){
position<-function(){
posizione=optim(knots[index,],change_point)
return(posizione$par)
}
}

#fixed effects estimation
if(n_par==2){
if(n_ran==1){
fixed_optim<-function(){
fixed=optim(c(par2_old,sigma_old),fixed_estimate)#,fixed_estimate.gr)
par2=fixed$par[1]
sigma=fixed$par[2]
return(c(par1,par2,par3,sigma))
}
}
if(n_ran==2){
fixed_optim<-function(){
fixed=optimize(fixed_estimate,interval=c(0,max(dati)))#,fixed_estimate.gr)
sigma=fixed$minimum
return(c(par1,par2,par3,sigma))
}
}
}
if(n_par==3){
if(n_ran==1){
fixed_optim<-function(){
fixed=optim(c(par2_old,par3_old,sigma_old),fixed_estimate)#,fixed_estimate.gr)
par2=fixed$par[1]
par3=fixed$par[2]
sigma=fixed$par[3]
return(c(par1,par2,par3,sigma))
}
}
if(n_ran==2){
fixed_optim<-function(){
fixed=optim(c(par3_old,sigma_old),fixed_estimate)#,fixed_estimate.gr)
par3=fixed$par[1]
sigma=fixed$par[2]
return(c(par1,par2,par3,sigma))
}
}
}

#global control parameters
K=30 #30 # total number of iterazions
K1=20 #20 #numeber of interation for the support reduction. From le iteration K1 to the end the support reduction is performed

#control parameters for the random effects distribution
if(unbalanced){
tollweight=0.005 #tolerance on the weight of the discrete distribution
}else{
tollweight=0.05
}
toll=0.05 #distance between 2 points for make them collapse
tollR=10^-3 #tolerance for the iterative estimation of random effects support points

#control parameters for the fixed effects estimate
tollF=10^-3 #tolerance for the iterative estimation of fixed effects
itmax=20 #maximum number of iterations for the fixed effects estimate


#iterations
for(k in 1:K){
#support reduction of the discrete distribution support points based on the distance
D=matrix(0,nknots,nknots)
for(i in 1:(nknots-1)){
for(j in (i+1):nknots){
temp=distE(knots[i,],knots[j,]) 
D[i,j]=temp
D[j,i]=temp
}
}
knots_new=knots
weights_new=weights

while(sum(D<toll)>nknots){
i=0
while(sum(D[i,(i+1):nknots]<toll)==0){
i=i+1
}
id=which(D[i,(i+1):nknots]<toll)+i
for(j in 1:length(id)){
knots_new[i,]=colMeans(rbind(knots_new[i,],knots_new[id[j],]))
knots_new[id[j],]=rep(NA,n_ran)
weights_new[i]=weights_new[i]+weights_new[id[j]]
weights_new[id[j]]=NA
}
nknots=sum(!is.na(knots_new[,1]))
knots_new=matrix(knots_new[!is.na(knots_new[,1]),],nknots,n_ran,byrow=FALSE)
weights_new=weights_new[!is.na(weights_new)]


D=matrix(0,nknots,nknots)
for(i in 1:(nknots-1)){
for(j in (i+1):nknots){
temp=distE(knots_new[i,],knots_new[j,])
D[i,j]=temp
D[j,i]=temp
}
}

}
weights=weights_new
knots=knots_new

#support reduction based on the weights
if(k>=K1){
group=rep(0,n)
for(i in 1:n){
group[i]=which.max(W[i,])
}
for(i in 1:nknots){
if(weights[i]<tollweight & sum(group==i)==0){
knots[i,]=rep(NA,n_ran)
weights[i]=NA
}
}
nknots=sum(!is.na(knots[,1]))
knots=matrix(knots[!is.na(knots[,1]),],nknots,n_ran,byrow=FALSE) 
weights=weights[!is.na(weights)]
}
# si dovrebbe ridistribuire la massa persa

#computation of W_ij
W=computeW()

#estimation of the weights in the discrete random effects distribution
weights_old=weights
weights=colMeans(W)

#estimation of the random effects support points and fixed effects
#iterative procedure
it=0
par1_old=par1
par2_old=par2
par3_old=par3
sigma_old=sigma
knots_old=knots

#estimation of random effects support points
for(index in 1:nknots){
knots[index,]=position()
}
#fixed effects estimation
fixed_temp=fixed_optim()
par1=fixed_temp[1]
par2=fixed_temp[2]
par3=fixed_temp[3]
sigma=fixed_temp[4]

while((abs(par1_old-par1)>tollF | abs(par2_old-par2)>tollF | abs(par3_old-par3)>tollF | abs(sigma_old-sigma)>tollF | sum(abs(knots_old-knots)>tollR)>0) & it<itmax ){
it=it+1
par1_old=par1
par2_old=par2
par3_old=par3
sigma_old=sigma
knots_old=knots
#estimation of random effects support points
for(index in 1:nknots){
knots[index,]=position()
}
#fixed effects estimation
fixed_temp=fixed_optim()
par1=fixed_temp[1]
par2=fixed_temp[2]
par3=fixed_temp[3]
sigma=fixed_temp[4]
}

#estimation of group
group=rep(0,n)
for(i in 1:n){
group[i]=which.max(W[i,])
}

print(k)
print(par1-par1_old)
print(par2-par2_old)
print(par3-par3_old)
print(sigma-sigma_old)
knots
}

#data plot
windows()
plot(knots[,2],knots[,1],lwd=100*weights,xlim=c(min(t),max(t)),ylim=c(min(dati),max(dati)),xlab='m',ylab='A')

windows()
col=rainbow(nknots)
plot(0,0,type='n',xlim=c(min(t),max(t)),ylim=c(min(dati),max(dati)),xlab='',ylab='')
for(i in 1:n){
points(t,dati[i,],type='l',lty=2,col=col[group[i]])
if(n_par==2){
if(n_ran==1){
points(t,model(t,knots[group[i],1],par2),type='l',col=col[group[i]],lwd=2)
}
if(n_ran==2){
points(t,model(t,knots[group[i],1],knots[group[i],2]),type='l',col=col[group[i]],lwd=2)
}
}
if(n_par==3){
if(n_ran==1){
points(t,model(t,knots[group[i],1],par2,par3),type='l',col=col[group[i]],lwd=2)
}
if(n_ran==2){
points(t,model(t,knots[group[i],1],knots[group[i],2],par3),type='l',col=col[group[i]],lwd=2)
}
}
}
