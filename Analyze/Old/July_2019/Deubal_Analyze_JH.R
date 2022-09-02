rm(list = ls())

##################
# LOAD IN LIBRARIES
##################

source("~/Box Sync/POP_IVRY/Analyze/r_functions.R")
call_libraries()
library(ggthemes)

##################
# LOAD IN THEME
##################

th <- theme_tufte()  + theme(panel.grid.major = element_blank(), 
                             panel.grid.minor = element_blank(), 
                             axis.line = element_line(colour = "black", size = 2), 
                             legend.title = element_blank(), 
                             legend.position = "right", 
                             text=element_text(size=20, family="Arial"), strip.text.x = element_text(size=20, face="bold"))

my.colors <- c("#006600", "#0073C2FF", "#FC4E07")

##################
# LOAD IN DATA
##################

pilot_data <- read.table("/Users/newxjy/Box Sync/DEUBAL/Analyze/jh_trial.csv", header=TRUE, sep=",")
pilot_data[c("discrim_dist")] <- lapply(pilot_data[c("discrim_dist")], factor) 

subset(pilot_data, RT == 0)

##################
# BIN RT 
##################

#pilot_data$moveonset_bin <- floor(((pilot_data$RT - pilot_data$discrim_onset) * 1000/50))
pilot_data$moveonset_bin <- floor(((pilot_data$discrim_onset - pilot_data$RT) * 1000/100))

##################
# CALCULATE ACCURACY
##################

# 1 = B = UP
# 2 = D = DOWN
# 3 = P =  LEFT
# 4 = Q = RIGHT

pilot_data$Accuracy <- 0
pilot_data$Accuracy[pilot_data$problem_report == "UpArrow" & pilot_data$stim_type == 1] <- 1
pilot_data$Accuracy[pilot_data$problem_report == "DownArrow" & pilot_data$stim_type == 2] <- 1
pilot_data$Accuracy[pilot_data$problem_report == "LeftArrow" & pilot_data$stim_type == 3] <- 1
pilot_data$Accuracy[pilot_data$problem_report == "RightArrow" & pilot_data$stim_type == 4] <- 1

pilot_data$match <- 1
pilot_data$match[pilot_data$discrim_dist != 0] <- 0

##################
# COUNT TRIAL ASSIGNMENT FOR EACH TARGET LOCATION
##################

theme_set(theme_pubr())

# Compute the frequency
function () {
  stop("This function should not be called directly")
}

library(magrittr)
df <- pilot_data %>% 
  dplyr::group_by(discrim_dist) %>% 
  dplyr::summarise(counts = n())
df

# Create the bar plot. Use theme_pubclean() [in ggpubr]
ggplot(df, aes(x = discrim_dist, y = counts)) +
  geom_bar(fill = "#0073C2FF", stat = "identity") +
  geom_text(aes(label = counts), vjust = -0.3) + 
  theme_pubclean()

##################
# COUNT MOVEONSET INTERVALS
################## 

library(magrittr)
df <- pilot_data %>% 
  dplyr::group_by(moveonset_bin) %>% 
  dplyr::summarise(counts = n())
df

ggplot(df, aes(x = moveonset_bin, y = counts)) +
  geom_bar(fill = "#0073C2FF", stat = "identity") +
  geom_text(aes(label = counts), vjust = -0.3) + 
  theme_pubclean()

plot_chance <- ggplot(pilot_data, aes(x = discrim_dist, y = counts)) + geom_bar(fill = "#0073C2FF") + theme_pubclean() +
  geom_text(aes(label = counts), vjust = -0.3)
print(plot_chance)

##################
# RT DISTRIBUTION 
##################


d<-pilot_data[!(pilot_data$RT > 10),]
ggplot(d, aes(RT)) +
  geom_histogram() + geom_vline(xintercept=0.7, linetype="dashed", color = "black")

##################
# COUNT "Too Slow" Trials
##################

# subj as 
# pilot_data$too_slow <- pilot_data$RT
# pilot_data$too_slow[pilot_data$too_slow > 0.4] <- "late"
# pilot_data$too_slow[pilot_data$too_slow <= 0.4] <- "early"
# pilot_data$too_slow <- factor(pilot_data$too_slow, levels = c("early", "late"))

pilot_data$too_slow <- pilot_data$RT
pilot_data$too_slow[pilot_data$too_slow > 0.7] <- "late"
pilot_data$too_slow[pilot_data$too_slow <= 0.7] <- "early"
pilot_data$too_slow <- factor(pilot_data$too_slow, levels = c("early", "late"))

slow_accurary <- data_summary_grp(data = pilot_data, varname = "Accuracy", groupnames = c("match", "too_slow"))
plot_slowacc <- ggplot(data = slow_accurary, aes(x = match, y = Accuracy, color = too_slow)) + geom_bar(stat = "identity", fill = "white") + facet_grid(.~ too_slow) + 
  geom_errorbar(aes(ymin = Accuracy - sem, ymax = Accuracy + sem), width = 0) + 
  scale_color_manual(values = my.colors) +
  labs(x = "Match", y = "Accuracy", color = "Speed") + th
print(plot_slowacc)

ggplot(pilot_data, aes(too_slow)) +
  geom_bar(fill = "#0073C2FF")

##################
# PLOT MATCH ~ ACCURACY
##################

accurary_summary <- data_summary(data = pilot_data, varname = "Accuracy", groupnames = c("match"))
plot_main <- ggplot(data = accurary_summary, aes(x = match, y = Accuracy)) + geom_bar(stat = "identity") + th +
  geom_hline(yintercept=0.25, linetype="dashed", color = "black") +
  geom_text(aes(label = Accuracy), vjust = -0.3)
print(plot_main)


ggplot(accurary_summary, aes(x = match, y = Accuracy)) +
  geom_bar(aes(y = (Accuracy)/sum(Accuracy), fill=match), stat= "identity") +
  geom_hline(yintercept=0.25, linetype="dashed", color = "black") +
  scale_color_manual(values = my.colors) +
  geom_text(aes(label = scales::percent(round((Accuracy)/sum(Accuracy),2)),
                y= ((Accuracy)/sum(Accuracy))), stat="identity",
            vjust = -.25)

##################
# PLOT DIST ~ ACCURACY
##################

dist_summary <- data_summary(data = pilot_data, varname = "Accuracy", groupnames = c("match", "discrim_dist"))
plot_dist <- ggplot(data = dist_summary, aes(x = discrim_dist, y = Accuracy)) + geom_bar(stat = "identity") + th +
  geom_hline(yintercept=0.25, linetype="dashed", color = "black") +
  labs(x = "Discrimination Distance")
print(plot_dist)


##################
# DEUBAL PLOT
##################

# altogether
d<-pilot_data[!(pilot_data$RT > 10),]
d[c("discrim_dist")] <- lapply(d[c("discrim_dist")], factor)
d[c("match")] <- lapply(d[c("match")], factor)
levels(d$match) <- c("match", "non-match")

move_onset_summary <-  data_summary_grp(data = d, varname = "Accuracy", groupnames = c("moveonset_bin", "match"))
plot_move <- ggplot(data = move_onset_summary, aes(x = moveonset_bin, y = Accuracy, group = match, color = match))  + geom_point() + geom_line() + th +
  geom_errorbar(aes(ymin = Accuracy - sem, ymax = Accuracy + sem), width = 0, size = 1) +
  scale_color_manual(values = my.colors) +
  labs(x = "Time from Probe to Move Onset (ms/100) (discrim = all)", y = "Accuracy")
print(plot_move)


# # movement onset separated by discrim_onset 
# pilot_data$bi[pilot_data$discrim_onset == 0.1] <- "100"
# pilot_data$bi[pilot_data$discrim_onset == 0.2] <- "200"
# pilot_data$bi[pilot_data$discrim_onset == 0.3] <- "300"
# pilot_data$bi <- factor(pilot_data$bi, levels = c("100", "200", "300"))


# # bi = 100ms
d<-pilot_data[!(pilot_data$RT > 2),]
d1 <- subset(d, discrim_onset == 0.1)
d1[c("discrim_dist")] <- lapply(d1[c("discrim_dist")], factor)
d1[c("match")] <- lapply(d1[c("match")], factor)
levels(d1$match) <- c("match", "non-match")

move_onset_summary1 <-  data_summary_grp(data = d1, varname = "Accuracy", groupnames = c("moveonset_bin", "match"))
plot_move_100 <- ggplot(data = move_onset_summary1, aes(x = moveonset_bin, y = Accuracy, group = match, color = match))  + geom_point() + geom_line() + th +
  geom_errorbar(aes(ymin = Accuracy - sem, ymax = Accuracy + sem), width = 0, size = 1) +
  scale_color_manual(values = my.colors) +
  labs(x = "Time from Probe to Move Onset (ms/100) (discrim = 100ms)", y = "Accuracy")
print(plot_move_100)

# bi = 200ms

d<-pilot_data[!(pilot_data$RT > 2),]
d2 <- subset(d, discrim_onset == 0.2)
d2[c("discrim_dist")] <- lapply(d2[c("discrim_dist")], factor)
d2[c("match")] <- lapply(d2[c("match")], factor)
levels(d2$match) <- c("match", "non-match")

move_onset_summary2 <-  data_summary_grp(data = d2, varname = "Accuracy", groupnames = c("moveonset_bin", "match"))
plot_move_200 <- ggplot(data = move_onset_summary2, aes(x = moveonset_bin, y = Accuracy, group = match, color = match))  + geom_point() + geom_line() + th +
  geom_errorbar(aes(ymin = Accuracy - sem, ymax = Accuracy + sem), width = 0, size = 1) +
  scale_color_manual(values = my.colors) +
  labs(x = "Time from Probe to Move Onset (ms/100) (discrim = 200ms)", y = "Accuracy")
print(plot_move_200)

# bi = 300ms 

d<-pilot_data[!(pilot_data$RT > 2),]
d3 <- subset(d, discrim_onset == 0.3)
d3[c("discrim_dist")] <- lapply(d3[c("discrim_dist")], factor)
d3[c("match")] <- lapply(d3[c("match")], factor)
levels(d3$match) <- c("match", "non-match")

move_onset_summary3 <-  data_summary_grp(data = d3, varname = "Accuracy", groupnames = c("moveonset_bin", "match"))
plot_move_300 <- ggplot(data = move_onset_summary3, aes(x = moveonset_bin, y = Accuracy, group = match, color = match))  + geom_point() + geom_line() + th +
  geom_errorbar(aes(ymin = Accuracy - sem, ymax = Accuracy + sem), width = 0, size = 1) +
  scale_color_manual(values = my.colors) +
  labs(x = "Time from Probe to Move Onset (ms/100) (discrim = 300ms)", y = "Accuracy")
print(plot_move_300)

ggarrange(plot_move, plot_move_100, plot_move_200, plot_move_300, nrow = 4)


##################
# INDIVIDUAL BLOCK ANALYSIS
##################

pilot_data$block[pilot_data$TN < 201] <- "1"
pilot_data$block[pilot_data$TN < 401 & pilot_data$TN >= 201] <- "2"
pilot_data$block[pilot_data$TN <= 540 & pilot_data$TN >= 401] <- "3"

block_accurary <- data_summary_grp(data = pilot_data, varname = "Accuracy", groupnames = c("match", "block"))
plot_block <- ggplot(data = block_accurary, aes(x = match, y = Accuracy, color = block)) + geom_bar(stat = "identity", fill = "white") + facet_grid(.~ block) + 
  geom_errorbar(aes(ymin = Accuracy - sem, ymax = Accuracy + sem), width = 0) + 
  scale_color_manual(values = my.colors) +
  geom_hline(yintercept=0.25, linetype="dashed", color = "black") +
  labs(x = "Match", y = "Accuracy", color = "Block") + th
print(plot_block)

