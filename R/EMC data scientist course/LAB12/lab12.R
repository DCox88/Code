library('RODBC')

ch<-odbcConnect('Greenplum')
ewma_table <- as.data.frame(sqlFetch(ch,'ewma_cnt_final'))
show(ewma_table)

library(reshape)
library(ggplot2)
ewma_table_plot <- ewma_table[,c("dteday","ewma","ewma_2")]
ewma_table_plot <- melt(ewma_table_plot, id.vars="dteday")
ggplot(ewma_table_plot, aes(dteday,value, col=variable)) + geom_point() + stat_smooth()
                                                          
