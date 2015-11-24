
require(ggplot2, lib.loc="/home/ubuntu/projects/Rlibs")

args <- commandArgs(TRUE)
rCharts <- args[1]
ts <- args[2]

dir <- paste0(rCharts, ts, sep="")
dir.create(dir)
filename <- paste0(dir, "/chart1.png", sep="")

df <- data.frame(x=c(1,2,3,4,5))
df$y <- df$x^2

plot <- ggplot(df, aes(x=x,y=y))
plot <- plot + geom_point(colour="blue")
plot <- plot + ggtitle("Test")
plot <- plot + labs(x="Radius in KM", y="Mean Business Review Score (stars)")

ggsave(filename=filename, width=8, height=6, units="in", dpi=72, plot=plot)
