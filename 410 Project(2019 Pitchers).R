install.packages("ggplot2")
install.packages("devtools")
install.packages("dplyr")
install.packages("ggcorrplot")
library(devtools)
library(dplyr)


#2019 pitchers data

pitchers = read.csv("C:/Users/014497819/Downloads/stats (4).csv")
row.names(pitchers) = pitchers$Full.Name


  

pitcher_stats = pitchers[,4:11]

#Covariance Matrix
plot(pitcher_stats)




#PCA Analysis
pca = prcomp(pitcher_stats, scale=TRUE)

plot(pca, type='l')
summary(pca)
#choose to use three principal components by the "elbow" in the plot and that using three 
#gets the cumulative proportion of variance to .91474.

pca$rotation
#The first PC is an overall stat. The higher the value the better the pitcher and vicce versa
#The second PC is contrasting launch angle, barrell% rate, and xiso, xobp and xba. Looks to be grouball pitchers have a low PC2
#and flyball pitchers have a higher value. 
#PC 3 is contrasting exit velocity with launch angle, High value good low value bad


#PCA plot
biplot(pca, cex=c(.45,.95))



# First for principal components
comps = data.frame(pca$x[,1:3])
# Plot
par(mfrow=c(1,1))
plot(comps, pch=16, col=rgb(0,0,0,0.5))







# Determine number of clusters
wss = (nrow(comps)-1)*sum(apply(comps,2,var))

for (i in 2:15) wss[i] <- sum(kmeans(comps,centers=i)$withinss)

plot(1:15, wss, type="b", xlab="Number of Clusters", ylab="Within groups sum of squares")

#By this plot use 4 clusters


# Apply k-means with k=4
k = kmeans(comps, 4, nstart=25, iter.max=1000)
#palette(alpha(brewer.pal(9,'Set1'), 1))


#Plot all three PC used
plot(comps, col=k$clust, pch=16)


#Plot just PC1 and PC2
par(mfrow=c(1,2))
plot(comps$PC1, comps$PC2, col=k$clust, pch=16)


plot(comps$PC1, comps$PC2, col=k$clust, pch=16)
#text(comp, labels=rownames(pitchers), cex=.7)
text(comps, labels=rownames(pitchers), cex=.75)




#Plot just PC1 and PC3
par(mfrow=c(1,2))
plot(comps$PC1, comps$PC3, col=k$clust, pch=16)


plot(comps$PC1, comps$PC3, col=k$clust, pch=16)
#text(comp, labels=rownames(pitchers), cex=.7)
text(comps, labels=rownames(pitchers), cex=.75)
#I can not figure out why the names wont plot on the points like it did on the other graph I had with the same exact code just
#change the plot from PC1 and PC2 to PC1 and PC3.




# Cluster sizes
sort(table(k$clust))
clust = names(sort(table(k$clust)))
clust

# First cluster
row.names(pitchers[k$clust==clust[1],]) # Points in the top right of plot
# Second Cluster
row.names(pitchers[k$clust==clust[2],]) # Points in the bottom right of the plot
# Third Cluster
row.names(pitchers[k$clust==clust[3],]) # Points on the left of the plot
# Fourth Cluster
row.names(pitchers[k$clust==clust[4],]) # Points sandwiched in the middle of the plot


#cluster 1 seems to be the good fly ball pitchers
#cluster 2 are the good groundball pitchers
#cluster 3 are the below average pitchers
#cluster 4 look to be he middle of the road pitchers
