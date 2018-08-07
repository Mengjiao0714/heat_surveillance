##this function will produce a graph that shows the number of exposure to natural heat in kansas
install.packages("readxl")
library(readxl)
install.packages("ggplot2")
library(ggplot2)
install.packages("janitor")
library(janitor)
install.packages("dplyr")
library(dplyr)
install.packages("ggpubr")
library(ggpubr)

##The raw data is downloaded directly from NSSP ESSENCE after running appropriate queries.
##It should contain two sheets in an excel format: the visit counts due to Heat_Related_Illness V2, and the mean daily temperature
## within the same time range.
heat_plot<-function(File_Name,Count_Sheet_Name,Temp_Sheet_Name){
  visit_count<-read_excel(paste0(File_Name),sheet=paste0(Count_Sheet_Name))[-1,]
  names(visit_count)<-c("date","visits","expected","visit_p_value")
  visit_count$date<-excel_numeric_to_date(as.numeric(visit_count$date))
  
  avg_temp<-read_excel(paste0(File_Name),sheet=paste0(Temp_Sheet_Name))[-1,]
  names(avg_temp)<-c("date","avg_temp","expected","avg_temp_p_value")
  avg_temp$date<-excel_numeric_to_date(as.numeric(avg_temp$date))
  
  
  mydata<-visit_count%>%
    transmute(date,
              visits=as.numeric(visits),
              visit_p_value=as.numeric(visit_p_value),
              avg_temp_p_value=as.numeric(avg_temp$avg_temp_p_value),
              avg_temp=as.numeric(avg_temp$avg_temp),
              status=case_when(visit_p_value<=0.01 ~"Alert",
                               visit_p_value<=0.05 ~"Warning",
                               visit_p_value >0.05 ~ "Normal"),
              avg_temp_status=case_when(avg_temp_p_value<=0.01 ~"Alert",
                                        avg_temp_p_value<=0.05 ~"Warning",
                                        avg_temp_p_value >0.05 ~ "Normal")
    )
  
  ## scattre plot for the mean daily temperature
  p1<-ggplot(mydata,aes(date,avg_temp))+geom_point(aes(colour=avg_temp_status))+
    scale_colour_manual(values=c("red", "blue","yellow"))+
    scale_x_date(date_breaks="1 week",labels=NULL)+
    theme(legend.position="none")+
    xlab("")+ylab("Mean Daily Temperature")+
    ggtitle("Number of Emergency Department Visits Due to Exposure to Natural Heat in Kansas")+
    theme(plot.title = element_text(color="black", size=11, face="bold",vjust=1))
  
  ## bar chart for the visit counts
  p2<-ggplot(mydata,aes(date,visits))+geom_bar(stat="identity",aes(fill=status))+
    scale_fill_manual(values=c("red", "blue","yellow"))+
    scale_x_date(date_breaks ="1 week")+
    theme(legend.position="bottom")+
    xlab("")+ylab("Visit Counts")+
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
  ## arrange two plots vertically
  ggarrange(p1, p2, heights = c(0.9,2),
            ncol = 1, nrow = 2, align = "v")
  ## save the graph to the working directory
  ggsave("Exposure_To_Heat_kansas.jpg")
}


##heat_plot("testdata.xlsx","Original","Overlay")
