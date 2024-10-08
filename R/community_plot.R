#' Generate Community Composition Plot Based on Tax_summary Object
#' @description Microbial community composition visualization in format of barplot, areaplot and alluvialplot
#' @param taxobj Configured tax summary objects.See in \code{\link{object_config}}.
#' @param taxlevel Character. taxonomy levels used for visualization.Must be one of c("Domain","Phylum","Class","Order","Family","Genus","Species","Base").
#' @param n Numeric. Top n taxa remained according to relative abundance. Default:10
#' @param palette Character. Palette for visualization,default:"Spectral",recommended to use "Paired" for more than 15 tax.
#' @param nrow Numeric. Number of rows when wrap panels,default:NULL.
#' @param rmprefix Numeric. Removed prefix character in taxonomy annotation.Default:NULL. See details in example.
#'
#' @return community_plot2 returns three ggplot objects, two data frame used in visualization and one character of filled mapping colors
#' @export
#' @importFrom ggplot2 ggplot aes geom_col geom_area facet_wrap facet_grid scale_fill_manual scale_y_continuous xlab ylab labs scale_x_discrete
#' @importFrom stringr str_sub str_length
#' @importFrom grDevices colorRampPalette
#' @importFrom ggalluvial geom_flow
#' @importFrom RColorBrewer brewer.pal.info
#' @author  Wang Ningqi<2434066068@qq.com>
#' @examples
#' {
#'   require(magrittr)
#'   ### Data preparation ###
#'   data("Two_group")
#'
#'   ## Use taxonomy summary objects
#'   phylum10 <- community_plot(
#'     taxobj = Two_group,
#'     taxlevel = "Phylum",
#'     n = 10,
#'     rmprefix = "p__"
#'   )
#'
#'   phylum10$barplot  # Check bar plot
#'   phylum10$areaplot  # Check area plot
#'   phylum10$alluvialplot  # Check alluvial plot
#'
#'   phylum10$Top10Phylum %>% head(10)  # Check top taxa data frame
#'   phylum10$Grouped_Top10Phylum %>% head(10)  # Check grouped top taxa data frame
#'   print(phylum10$filled_color)  # Check mapping colors
#'
#'   # Double facet
#'   data("Facet_group")
#'
#'   # Using palette by default
#'   phylum10 <- community_plot(
#'     taxobj = Facet_group,
#'     taxlevel = "Phylum",
#'     n = 10,
#'     rmprefix = " p__"
#'   )
#'   phylum10$barplot
#'   phylum10$areaplot
#'   phylum10$alluvialplot
#'
#'   # Another example
#'   genus20 <- community_plot(
#'     taxobj = Facet_group,
#'     taxlevel = "Genus",
#'     n = 20,
#'     palette = "Paired",
#'     rmprefix = " g__"
#'   )
#'   genus20$alluvialplot
#' }
community_plot=function(taxobj,taxlevel,n=10,palette="Spectral",nrow=NULL,rmprefix=NULL){
  if(is.null(eval(parse(text=paste0("taxobj","$",taxlevel))))){
    warning("Illegal 'taxlevel'!")
    return(NULL)
  }
  if(is.null(taxobj$configuration)){stop("taxonomic summary object not configured yet, call '?object_config' for configuration")}
  color_n<-brewer.pal.info[palette,]$maxcolors
  getPalette <-colorRampPalette(brewer.pal(color_n, palette))
  inputframe=eval(parse(text=paste0("taxobj","$",taxlevel,"_percent")))
  topframe<-Top_taxa(inputframe,n,2,1)
  groupframe=taxobj$Groupfile
  treat_location=taxobj$configuration$treat_location
  facet_location=taxobj$configuration$facet_location
  rep_location=taxobj$configuration$rep_location
  treat_col=taxobj$configuration$treat_col
  treat_order=taxobj$configuration$treat_order
  facet_order=taxobj$configuration$facet_order
  if(!is.null(rmprefix)){topframe[1:n,1]=str_sub(topframe[1:n,1],str_length(rmprefix)+1)}
  long_topframe<-data.frame(topframe[,-1],row.names = topframe[,1]) %>%
    combine_and_translate(groupframe,"tax","rel_abundance",TRUE)
  if(!is.null(treat_order)){long_topframe[,treat_location]<-factor(long_topframe[,treat_location],levels=treat_order)}
  long_topframe$tax<-factor(long_topframe$tax,levels=topframe[,1])
  if(!is.null(facet_order)){long_topframe[,facet_location]=factor(long_topframe[,facet_location],levels=facet_order)}
  output_list=list()
  ##bar##
  plot=ggplot(long_topframe, aes(x=long_topframe[,rep_location], y = long_topframe[,'rel_abundance'], fill = long_topframe[,'tax'] )) +
    geom_col(position = 'stack', width = 0.8)+
    scale_fill_manual(values = getPalette(nrow(topframe)))+
    scale_y_continuous(labels = scales::percent,expand = c(0,0)) +
    xlab("")+ylab("Relative abundance")+labs(fill=taxlevel)+
    theme_zg() +theme(axis.text.x = element_blank(),legend.text = element_text(size=8,face = "bold"),strip.text = element_text(size=8,face = "bold"),
                      axis.ticks.x = element_blank(),panel.background = element_rect(color=NA),
                      axis.line.y = element_line(size=.4,color="black"),axis.ticks.length.y= unit(0.4,"lines"),
                      axis.ticks.y = element_line(color='black',size=.4))
  if(is.null(facet_location)==TRUE){
    plot=plot+facet_wrap(~long_topframe[,treat_location],nrow=nrow,scales = "free_x")
  }else{
    plot=plot+facet_grid(long_topframe[,treat_location]~long_topframe[,facet_location],scales = "free_x")
  }
  output_list=c(output_list,list(plot))
  names(output_list)[1]="barplot"
  message("barplot made successfully(1/4)")
  ###area##
  plot=ggplot(long_topframe, aes(x=as.numeric(long_topframe[,rep_location]), y = long_topframe[,"rel_abundance"] )) +
    geom_area(aes(fill =long_topframe[,"tax"]))+
    facet_wrap(~long_topframe[,treat_location],nrow=nrow,scales = "free_x")+
    scale_fill_manual(values = getPalette(nrow(topframe)))+
    scale_y_continuous(expand = c(0,0),labels = scales::percent)+
    theme_zg() +theme( axis.text.x = element_blank())+
    xlab("")+ylab("Relative abundance")+labs(fill=taxlevel)+theme(axis.text.x = element_blank(),legend.text = element_text(size=8,face = "bold"),strip.text = element_text(size=8,face = "bold"),
                                                                  axis.ticks.x = element_blank(),panel.background = element_rect(color=NA),
                                                                  axis.line.y = element_line(size=.4,color="black"),axis.ticks.length.y= unit(0.4,"lines"),
                                                                  axis.ticks.y = element_line(color='black',size=.4))
  if(is.null(facet_location)==TRUE){
    plot=plot+facet_wrap(~long_topframe[,treat_location],nrow=nrow,scales = "free_x")
  }else{
    plot=plot+facet_grid(long_topframe[,treat_location]~long_topframe[,facet_location],scales = "free_x")
  }
  output_list=c(output_list,list(plot))
  names(output_list)[2]="areaplot"
  message("areaplot made successfully(2/4)")
  ###alluvial###
  if(is.null(facet_location)==TRUE){
    plotframe=aggregate(long_topframe[,ncol(long_topframe)],by=list(long_topframe[,treat_location],long_topframe[,"tax"]),FUN=mean)
    plot=ggplot(plotframe, aes(x=as.factor(plotframe[,"Group.1"]), y = plotframe[,'x'], fill = plotframe[,"Group.2"],stratum = plotframe[,"Group.2"], alluvium = plotframe[,"Group.2"]) )+
      geom_col(position = 'stack', width = 0.8)
  }else{
    meanframe=aggregate(long_topframe[,ncol(long_topframe)],by=list(long_topframe[,treat_location],long_topframe[,"tax"],long_topframe[,facet_location]),FUN=mean)
    plot=ggplot(meanframe, aes(x=as.factor(meanframe[,"Group.1"]), y = meanframe[,'x'], fill = meanframe[,'Group.2'],stratum = meanframe[,'Group.2'], alluvium = meanframe[,'Group.2']) )+
      facet_grid(~meanframe[,3])+
      geom_col(position = 'stack', width = 0.8)

  }
  plot1=plot+
    scale_fill_manual(values = getPalette(nrow(topframe)))+
    scale_y_continuous(labels = scales::percent,expand = c(0,0)) +
    scale_x_discrete(expand = c(0.1,0.1))+
    theme_zg() +
    xlab("Treatment")+ylab("Relative abundance")+labs(fill=taxlevel)+theme(legend.text = element_text(size=8,face = "bold"),strip.text = element_text(size=8,face = "bold"),
                                                                           axis.ticks.x = element_blank(),panel.background = element_rect(color=NA),
                                                                           axis.line.y = element_line(size=.4,color="black"),axis.ticks.length.y= unit(0.4,"lines"),
                                                                           axis.ticks.y = element_line(color='black',size=.4))
  plot=plot+geom_flow(alpha = 0.5,width=0.1)+
    scale_fill_manual(values = getPalette(nrow(topframe)))+
    scale_y_continuous(labels = scales::percent,expand = c(0,0)) +
    scale_x_discrete(expand = c(0.1,0.1))+
    theme_zg() +
    xlab("Treatment")+ylab("Relative abundance")+labs(fill=taxlevel)+theme(legend.text = element_text(size=8,face = "bold"),strip.text = element_text(size=8,face = "bold"),
                                                                           axis.ticks.x = element_blank(),panel.background = element_rect(color=NA),
                                                                           axis.line.y = element_line(size=.4,color="black"),axis.ticks.length.y= unit(0.4,"lines"),
                                                                           axis.ticks.y = element_line(color='black',size=.4))
  output_list=c(output_list,list(plot),list(plot1))
  names(output_list)[3]="alluvialplot"
  names(output_list)[4]="mean_barplot"
  message("alluvialplot made successfully(3/4)")
  message("Grouped barplot made successfully(4/4)")
  #output frame
  topnames=paste0("Top",n,taxlevel)
  framename=paste0("Grouped_",topnames)
  filled_color=getPalette(nrow(topframe))
  names(filled_color)=topframe[,1]
  output_list=c(output_list,list(topframe,long_topframe,filled_color))
  names(output_list)[5:7]=c(topnames,framename,"filled_color")
  message("Top Taxa named as(",topnames,")")
  message("Grouped top Taxa named as(",framename,")")
  message("Color for filling named as(","filled_color",")")
  return(output_list)
}
