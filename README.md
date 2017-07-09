# Model Criticism

# Packages (For R)

-RobotModelCriticism

	Frozen version in order to replicate "Do the Robot" paper

	This version will not be updated any longer. 
	DO NOT USE, unless replicating paper. 
	The replication code for the JPR paper calls package automatically.

-ModelCriticism (See notes on usage below)

	Version of "ModelCriticism" that will be continuously updated.
	Use this one for any general use.
	Please cite "Do the Robot" paper when using.

#### *Citation*

Colaresi, Michael., & Mahmood, Zuhaib. (2017). Do the robot: Lessons from machine learning to improve conflict forecasting. Journal of Peace Research.

# Usage

### *ModelCriticism*

These plots are very flexibe, with the goal of making it as broadly applicable as possible.
This means, however, that they require a lot of user input. 

I have tested and confirmed (as of 6/30/2017) this package's ability to run under the following specifications:

```{r}
#################
#x86_64-apple-darwin13.4.0 (64-bit)
#OSX Yosemite 10.10.5
#	R 3.3.3
#		dplyr(0.7.1)
#		ggplot2(2.2.1)
#		gridExtra(2.2.1)
#		grid(base)
#	
#x86_64-w64-mingw32/x64 (64-bit)
#Windows >=8 (note: windows 10) x64 (build 9200)
#Microsoft Surface Pro
#	R 3.3.1
#		dplyr(0.7.1)
#		ggplot2(2.2.1)
#		gridExtra(2.2.1)
#		grid(base)	
##################
```

### Making sure it can run
1. You must make sure you have installed dplyr, ggplot2, and gridExtra. grid package should come with base R. NOTE THE VERSIONS ABOVE.
	If you use different versions of these packages, you can still use the functions but I haven't confirmed that it runs.
2. You can use the "Model Criticism Diagnostic" script to see if you can make the plots. It should generate similar plots as you see in the paper. 
3. If this produces plots, you should be able to run the script. Proceed to the next section. Otherwise, continue below.
4. If it does not produce plots, check sessionInfo() in R to make sure you've met the above specifications (especially R 3.3.x and the package versions).
5. If it still does not produce plots, try a clean (or virtual) install of R with these specs. 
6. At that point, don't hesitate to reach out for help. You can contact me at **mahmoo21@msu.edu**. 

### Using the functions
There are a few important parameters you'll need to use when you render these plots. Otherwise, they will look terrible.

1. *label_spacing* is an integer value to adjust the spacing between labels. If your labels overlap above and below the text, you can increase the spacing. If they're too far apart, you can decrease this value.
2. *lab_adjust* is an option to move the label closer to or further from the pointer line. If you have long labels, for example, you can increase this value to shift the start of the label text away from the end of the pointer line. 
	
		NOTE: This value is generally very, very small. The Default is around 0.02 or 0.03. Try adjusting in 0.01 increments before moving higher.

		NOTE 2: On the "BicepPlot()" function, the adjustments can be made for *right_lab_adjust* or *bottom_lab_adjust*. For the "DiagPlot()" function, since there's only one set of labels, it is simply *lab_adjust*. 

3. *_margin* is an option to make the margins smaller or larger. This is useful, for example, if you have an extremely long label and it's not showing up fully on your plot, or if your labels are running off one side of the page. 

		NOTE: This value is generally a smaller integer value between 1-15. See the documentation for default values.

		NOTE 2: The "DiagPlot()" function allows *right_margin* and *top_margin*. The "BicepPlot()" function adds *bottom_margin* since there's labels on the bottom as well. 

4. *rare* is a True/Fase option on BicepPlot() to make the blue zero markers lighter relative to the red 1 markers. This is useful if the sea of blue zeros is overwhelming the rare red ones in your data visually.

There are other options as well, but these are the most important ones. Again, the goal here is to allow the user to adapt the visualizations to their own data, which can vary a lot in scope. 


