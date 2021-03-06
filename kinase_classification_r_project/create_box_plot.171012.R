##generates box/violin plot of features 
##supplemental figure 1 
library(tidyverse)
library(readxl)
library(scales)
library(clusterSim)
library(randomForest)
library(ggplot2)
library(ggthemes)
library(plotly)
##set seed for randomforest 
set.seed(42)
##read data 
dat = as.data.frame(read.csv("../../1_manual_classes/stdy_kinase.param.171009.264anno.csv",
                                head = T))
#get training data and relevant data columns; row 2:3 are duplicate for internal checking
dat.2 = as.data.frame(data.matrix(dat[2:265, c(18,19,20,21,22,25,26,27,28,29,30,31,32,33,34,35,36)]))
#dat.2 = data.matrix(dat[2:265, c(7,8,9,10,11,12,13,14,15,16)])

##impute missing data 
dat.2.impute = as.data.frame(rfImpute(
  x = dat.2,
  y = as.factor(dat$Group[2:265]) ,
  ntree = 1000))
dat.2.impute$y = NULL

##normalize data to fit -1 to 1  
dat.2.normal = data.Normalization(dat.2, type = "n5", normalization = "column" )
dat.2.scaled = dat.2.normal
#dat.2.scaled = as.data.frame(rescale(data.matrix(dat.2.normal), to=c(-1,1)))

##add "Conformation Class" to normalized data 
dat.2.scaled$clust = dat$Group[2:265]
##add "pdb_id" to normalized data 
row.names(dat.2) = dat$pdb_id[2:265]
##format data for ggplot 
dat.2.scaled.split = split(dat.2.scaled, f = dat.2.scaled$clust)
complete.df = data.frame()
for (i in dat.2.scaled.split) 
{
    c = unique(as.character(i$clust))
    i$clust = NULL
    i.st = stack(i)
    i.st$clust = rep(c, nrow(i.st))
    complete.df.l = as.data.frame(rbind(complete.df, i.st))
    complete.df = complete.df.l
}
##fill colors for classes 
colors = c("#CAF270","#73D487","#30B096","#40607A", "#453B52")
##plot box/violin plot 

colors = c("#443333","#cc5522","#00ccff","#AA96DA", "grey50")
ggplot(complete.df, aes(clust , values, fill = clust)) + geom_boxplot() +
       geom_violin(color = "lightgrey",scale = "width", trim =T, alpha = .8) +
       scale_fill_manual(values =  colors ) +  facet_wrap(~ind) +
       theme_light(base_size = 20) + ylim(-1.1,1.1) + 
       theme(legend.position = "none", 
       strip.text = element_text(colour = 'black', size = 20) ,
                    axis.title.x = element_blank() , 
       strip.background = element_rect(fill = "grey",colour = "lightgrey"), 
       axis.text = element_text(size = 16)) + ylab(label = "Normalized Score")
plot(p)
##interactive figure 
ggplotly(p)
       