#'Function to create diagnostic plot for a single model
#'
#'Creates an object to be rendered with "grid.draw()" command
#'
#'@param f N by 1 vector of forecasts f_{i} in (0,1)
#'@param y N by 1 vector of forecasts y_{i} is 0 or 1
#'@param labels N by 1 vector of textual labels (strings)
#'@param worstN How many values to label, given y={0,1}
#'@param size_adjust adjusts distribution of space between density plot and the main plot. Usually values from [0,.7], but you can also go into negative numbers where you need the margx plot (density plot on x axis) to get larger relative to main plot. >0.6 starts getting ugly. Default is 0.5.
#'@param right_margin adjusts the right margin. Tends to be between [5,15]. Default value is 7.
#'@param top_margin	adjusts the top margin of PLOT (not including title). Useful if labels are off the upper end of page. Likely between [1,5]. Default value is 1.5.
#'@param label_spacing Spacing between labels 
#'@param lab_adjust shift label right or left vis-a-vis the line
#'@param text_size font size
#'
#'@return Object to be plotted with "grid.draw() function
#'
#'@import ggplot2
#'@import dplyr
#'@import grid
#'@import gridExtra
#'
#'@export
#'
DiagPlot <- function(f, y, labels, worstN=10, size_adjust=0,right_margin=7,top_margin=1.5,label_spacing=10,lab_adjust=.5,text_size=10,title="Model Diagnostic Plot") {
	
	#################
	#Begin Function
	#################
	
	data <- data.frame(f=f, y=y, labels=labels)
	pdata <- data %>% mutate(y_minus_f=y-f) %>% arrange(f) %>% mutate(forecastOrder = row_number())
	#still need to label worstN
	pdata <- pdata %>% group_by(y) %>% arrange(desc(abs(y_minus_f))) %>% mutate(label_worst=ifelse(row_number()<=worstN, as.character(labels), " "))
	#need to create var for absolute errors
	pdata<-pdata%>%mutate(abserr=abs(y_minus_f))
	#create indicator for worst values
	pdata <- pdata %>% group_by(y) %>% arrange(desc(abs(y_minus_f))) %>% mutate(isworstn=ifelse(row_number()<=worstN, 1, 0))
	#for coloring
	pdata <- pdata %>% mutate(coloring=
		ifelse(y==1 & isworstn==1, '1w',
		ifelse(y==0 & isworstn==1, '0w',
		ifelse(y==1 & isworstn==0, '1',
		'0'))))
	#arrange data for plotting
	pdata<-pdata%>%arrange(forecastOrder)
	N=nrow(pdata)
	labbuffer=(nchar(N)-3)*.3
	boolcolors<-as.character(c(
		'1w'='#cddff4', #very light blue
		'0w'='#0862ca', #bold blue
		'1'='#fecfdc', #very light red
		'0'='#fd1205')) #bold red
	boolscale<-scale_color_manual(name='coloring',values=boolcolors)
	###################
	#initialize plots.
	#	Object "o2" contains the full plot we care about,
	#		minus the lines & labels. 
	#	Object "margx" is the marginal on the x axis of f|y=0 & f|y=1
	###################
	o1 <- ggplot(pdata, aes(x=f,y=forecastOrder,group=y, color=as.factor(coloring)))+boolscale
	o2 <- o1 + geom_point(aes(alpha=(isworstn)))  +geom_rug(side="r")+xlim(c(0,1))+ylim(c(0,N))+theme_bw()+theme(panel.grid.major=element_line(colour='grey'),panel.grid.minor=element_line(colour='grey'),panel.grid.major.y=element_blank(),panel.grid.minor.y=element_blank(),panel.grid.minor.x=element_blank(),axis.text.x=element_blank(),axis.ticks.x=element_blank(),axis.title.x=element_blank(),legend.position='none',plot.margin=unit(c(top_margin,right_margin,-.2,1),"lines")) +labs(y='Observation (ordered by f)')+boolscale
	margx<-ggplot(pdata,aes(f,fill=factor(y)))+geom_density(alpha=.4)+scale_fill_manual(values=c('blue','red'))+xlim(c(0,1))+labs(x='Forecast Value')+theme_bw()+theme(panel.grid.minor=element_blank(),panel.grid.major=element_blank(),axis.title.y=element_blank(),axis.text.y=element_blank(),axis.ticks.y=element_blank(),legend.position="none",plot.margin=unit(c(0,right_margin,0.2,3.35+labbuffer),"lines"))
	
	###################
	#Lines and Labels
	###################	
	z<-o2
	count0=0
	count1=0
	for (i in 1:length(pdata$label_worst)) {
		
		################################
		#Prepare to position labels
		################################	
		text_spacing<-label_spacing
			
		labeltext<-pdata$label_worst[i]
		if(labeltext == ' '){
			next
		}
		obsy=pdata$y[i]
		if(obsy==0){
			count0<-count0+text_spacing
		}
		if(obsy==1){
			count1<-count1+text_spacing
		}
		if(count1==text_spacing){
			y1init=pdata$forecastOrder[i]
		}
		if(count0==text_spacing){
			y0init=pdata$forecastOrder[i]
		}
		
		fpos<-pdata$f[i]
		##############################
		#Set the parameters for labels
		##############################
		ycolor<-ifelse(obsy==0,'blue','red')
		ypos_text<-ifelse(obsy==0,
			(y0init+(count0-text_spacing)),
			(y1init+(count1-text_spacing))
			)
		ifelse(pdata$forecastOrder[i]>ypos_text,LineSlope<-c(1,0),LineSlope<-c(0,1))
		labjust_left=1.1
		labjust_right=labjust_left+lab_adjust
		
		###############################
		#Create the labels on plot
		###############################
		current<-
			z+
			annotation_custom(
			grob=textGrob(label=labeltext,
				gp=gpar(fontsize=text_size,col=ycolor)),
			ymin=ypos_text,
			ymax=ypos_text,
			xmin=labjust_left,
			xmax=labjust_right
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
				x=c(fpos+.05,.95),
				y=0,
				gp=gpar(col=ifelse(obsy==0,'#f0f5fb','#fef0f4'))
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
