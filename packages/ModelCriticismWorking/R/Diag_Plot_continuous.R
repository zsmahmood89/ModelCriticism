library(dplyr)
library(ggplot2)
library(grid)
library(gridExtra)

###########
#Toy data (y = correct forecast of z with normally distributed errors)
###########
z<-rnorm(500)
z2<-rnorm(500)
z.y<-z
z.y<-z.y+rnorm(500,mean=0,sd=.2)

#labels
z.labs<-rep("test",500)

#Dataframe
P=data.frame(f=z,f2=z2,y=z.y,labs=z.labs)


#########
#Define the function
#########
DiagPlot_Continuous <- function(f, y, labels, worstN=10, size_adjust=0,right_margin=7,top_margin=1.5,label_spacing=10,lab_adjust=.5,text_size=10,bw=FALSE,title="Model Diagnostic Plot") {
	
	#################
	#Begin Function
	#################
	
	data <- data.frame(f=f, y=y, labels=labels)
	pdata <- data %>% mutate(y_minus_f=y-f) %>% arrange(y_minus_f) %>% mutate(forecastOrder = row_number())
	#label worstN
	pdata <- pdata %>% mutate(sign=ifelse(y_minus_f<0,"neg","pos"))
	pdata <- pdata %>% group_by(sign) %>% arrange(-abs(y_minus_f)) %>% mutate(label_worst=ifelse(row_number()<=worstN, as.character(labels), " "))
	#need to create var for absolute errors
		#pdata<-pdata%>%mutate(abserr=abs(y_minus_f)) #No, we dont need this.
	#create indicator for worst values
	pdata <- pdata %>% group_by(sign) %>% arrange(-abs(y_minus_f)) %>% mutate(isworstn=ifelse(row_number()<=worstN, 1, 0))
	#for coloring (red = positive; blue = negative)
	pdata<-pdata %>% mutate(coloring=paste(as.character(sign),as.character(isworstn),sep=""))
	#arrange data for plotting
	pdata<-pdata%>%arrange(forecastOrder)
	N=nrow(pdata)
	labbuffer=(nchar(N)-3)*.3
	#Colors for use
	yblue=ifelse(bw==F,'#0862ca','#8b8b8b')
	ybluemarg=ifelse(bw==F,yblue,"#989898")
	ybluelite=ifelse(bw==F,'#cddff4','#d8d8d8')
	ybluelitest=ifelse(bw==F,'#f0f5fb','#f2f2f2')
	yred=ifelse(bw==F,'#fd1205','#000000')
	yredmarg=ifelse(bw==F,yred,yred)
	yredlite=ifelse(bw==F,'#fecfdc','#999999')
	yredlitest=ifelse(bw==F,'#fef0f4','#e5e5e5')
	boolcolors<-as.character(c(
		"neg1"=ybluelite, #this flips with neg0? not sure why.
		"neg0"=yblue, #this flips with neg1? not sure why.
		"pos0"=yredlite,
		"pos1"=yred))
	boolscale<-scale_color_manual(name='coloring',values=boolcolors)
	###################
	#initialize plots.
	#	Object "o2" contains the full plot we care about,
	#		minus the lines & labels. 
	#	Object "margx" is the marginal on the x axis of f|y=0 & f|y=1
	###################
	o1 <- ggplot(pdata, aes(x=y_minus_f,y=forecastOrder,group=sign, color=as.factor(coloring)))+boolscale
	o2 <- o1 + geom_point(aes(alpha=(isworstn)))  +geom_rug(sides="r")+xlim(range(pdata$y_minus_f))+ylim(c(0,N))+theme_bw()+theme(panel.grid.major=element_line(colour='grey'),panel.grid.minor=element_line(colour='grey'),panel.grid.major.y=element_blank(),panel.grid.minor.y=element_blank(),panel.grid.minor.x=element_blank(),axis.text.x=element_blank(),axis.ticks.x=element_blank(),axis.title.x=element_blank(),legend.position='none',plot.margin=unit(c(top_margin,right_margin,-.2,1),"lines")) +labs(y='Observation (ordered by deviation)')+boolscale
	margx<-ggplot(pdata,aes(y_minus_f,fill=factor(sign)))+geom_density(alpha=.4)+scale_fill_manual(values=c(yblue,yredmarg))+xlim(range(pdata$y_minus_f))+labs(x='Deviation from Actual')+theme_bw()+theme(panel.grid.minor=element_blank(),panel.grid.major=element_blank(),axis.title.y=element_blank(),axis.text.y=element_blank(),axis.ticks.y=element_blank(),legend.position="none",plot.margin=unit(c(0,right_margin,0.2,3.35+labbuffer),"lines"))
	
	###################
	#Lines and Labels
	###################	
	z<-o2
	count0=0
	count1=0
	#yblue<-ifelse(bw==F,'blue',yblue)
	#yred<-ifelse(bw==F,'red',yred)
	for (i in 1:length(pdata$label_worst)) {
		
		################################
		#Prepare to position labels
		################################	
		text_spacing<-label_spacing
			
		labeltext<-pdata$label_worst[i]
		if(labeltext == ' '){
			next
		}
		obsy=pdata$sign[i]
		if(obsy=="neg"){
			count0<-count0+text_spacing
		}
		if(obsy=="pos"){
			count1<-count1+text_spacing
		}
		if(count1==text_spacing){
			y1init=pdata$forecastOrder[i]
		}
		if(count0==text_spacing){
			y0init=pdata$forecastOrder[i]
		}
		
		fpos_raw<-pdata$y_minus_f[i]
		xscale<-range(pdata$y_minus_f)
		fpos_num<-fpos_raw-min(xscale)
		fpos_num_vector<-(pdata$y_minus_f)-min(xscale)
		fpos<-fpos_num/max(fpos_num_vector)
		##############################
		#Set the parameters for labels
		##############################
		ycolor<-ifelse(obsy=="neg",yblue,yred)
		ypos_text<-ifelse(obsy=="neg",
			(y0init+(count0-text_spacing)),
			(y1init+(count1-text_spacing))
			)
		ifelse(pdata$forecastOrder[i]>ypos_text,LineSlope<-c(1,0),LineSlope<-c(0,1))
		labjust_left=1.1
		#labjust_right=labjust_left+lab_adjust
		
		###############################
		#Create the labels on plot
		###############################
		adj4sign<-ifelse(fpos<=.5,.05,-.05) #label pointers need flipping
		current<-
			z+
			annotation_custom(
			grob=textGrob(label=labeltext,
				gp=gpar(fontsize=text_size,col=ycolor)),
			ymin=ypos_text,
			ymax=ypos_text,
			xmin=max(xscale)+(.05*diff(xscale)),
			xmax=max(xscale)+(.05*diff(xscale))+lab_adjust
			)+
			annotation_custom(
			grob=linesGrob(
				x=c(1,labjust_left),
				y=LineSlope,
				gp=gpar(col=ycolor)
				),
				ymin=
					ifelse(
					pdata$forecastOrder[i]<=ypos_text,
					pdata$forecastOrder[i],
					ypos_text),
				ymax=
					ifelse(
					pdata$forecastOrder[i]>ypos_text,
					pdata$forecastOrder[i],
					ypos_text)
			)+
			annotation_custom(
			grob=linesGrob(
				x=c(fpos+adj4sign,.97),
				y=0,
				gp=gpar(col=ifelse(obsy=="neg",ybluelitest,yredlitest))
				),
				ymin=pdata$forecastOrder[i],
				ymax=pdata$forecastOrder[i]
			)
		z<-current
		}
		
	#Turn off clipping so we can render the plot
	gt <- ggplot_gtable(ggplot_build(z))
	gt$layout$clip[gt$layout$name == "panel"] <- "off"
	o3<-arrangeGrob(gt,margx,ncol=1,nrow=2,heights=c(4+size_adjust,1-size_adjust),top=textGrob(title,gp=gpar(fontsize=15,font=2),just='top'))
	return(o3)
}


###########
#Run the function
###########
z<-DiagPlot_Continuous(
f=P$f,
y=P$y,
labels=P$labs,
worstN=10,
size_adjust=0,
right_margin=7,
top_margin=1.5,
label_spacing=8,
lab_adjust=.40,
text_size=6,
bw=FALSE,
title="Model Diagnostic Plot"
)

grid.draw(z)
