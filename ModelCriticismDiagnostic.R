#############
#Confirmed on 6/30/2017 to run with:
# 
#	x86_64-apple-darwin13.4.0 (64-bit)
#	OSX Yosemite 10.10.5
#		R 3.3.3
#			dplyr(0.7.1)
#			ggplot2(2.2.1)
#			gridExtra(2.2.1)
#			grid(base)
#
#	x86_64-w64-mingw32/x64 (64-bit)
#	Windows >=8 (note: windows 10) x64 (build 9200)
#	Microsoft Surface Pro
#		R 3.3.1
#			dplyr(0.7.1)
#			ggplot2(2.2.1)
#			gridExtra(2.2.1)
#			grid(base)	
##############

{
#install.packages("devtools")
library(devtools)

#install.packages("dplyr")
library(dplyr)

#install.packages("ggplot2")
library(ggplot2)

#install.packages("gridExtra")
library(gridExtra)

#install.packages("grid")
library(grid)

#Install ModelCriticism
install_github("zsmahmood89/ModelCriticism/packages/ModelCriticism")
library(ModelCriticism)

##########
#Assertions
##########
assert.R<-R.Version()$minor=="3.3"
assert.dplyr<-packageVersion("dplyr")=="0.7.1"
assert.ggplot2<-packageVersion("ggplot2")=="2.2.1"
assert.gridExtra<-packageVersion("gridExtra")=="2.2.1"

if(assert.R==F){warning("This script is ideally run in R 3.3.x")}
if(assert.dplyr==F){warning("dplyr version possibly not supported")}
if(assert.ggplot2==F){warning("ggplot2 version possibly not supported")}
if(assert.gridExtra==F){warning("gridExtra version possibly not supported")}


##########
#Run ModelCriticism
##########

#number of obserations
nobs<-1000

#Pretend data; "z" should be decisively better
z<-runif(nobs)
z2<-runif(nobs)
z.y<-z
z.y<-z.y+runif(nobs,min=-0.2,max=-0.2)
z.y<-abs(z.y)
z.y<-round(z.y)

#pretend labels
z.labs<-rep("test",nobs)

#Data frame
P=data.frame(f=z,f2=z2,y=z.y,labs=z.labs)

#You can store plots, but runnin plot command will have a plot show up so you'll need dev.off()
z.bicepplot<-BicepPlot(P$f,P$f2,P$y,P$labs,label_spacing=12,transp_adjust=10)
dev.off()
grid.draw(z.bicepplot)

z.diagplot<-DiagPlot(P$f2,P$y,P$labs,label_spacing=20,lab_adjust=.2)
dev.off()
grid.draw(z.diagplot)

#############
#Tweak the commands as needed to adjust labels, etc.
#############
}

