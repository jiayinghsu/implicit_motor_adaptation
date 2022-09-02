rm(list = ls())

######################
#LOAD IN LIBRARIES 
######################

source("/Users/newxjy/Dropbox/VICE/JT/DEUBAL/Functions/r_functions.R")
call_libraries()
text_size <- 25
axis_text <- 18
th <- theme_pubclean(base_family = "Helvetica")  + theme(panel.grid.major = element_blank(), 
                                                         panel.grid.minor = element_blank(), 
                                                         strip.background = element_blank(), 
                                                         panel.spacing.x=unit(1.5, "lines"),
                                                         axis.line = element_line(colour = "black", size = 1), 
                                                         legend.position = "right", 
                                                         text=element_text(size= text_size, family="Helvetica"), 
                                                         strip.text.x = element_text(size=text_size, face="bold"), 
                                                         axis.text.x = element_text(size = axis_text), 
                                                         axis.text.y = element_text(size = axis_text), 
                                                         axis.title.y = element_text(margin = margin(t = 0, r = 8, b = 0, l = 0)), 
                                                         axis.title.x = element_text(vjust=-0.3), 
                                                         axis.ticks.length=unit(0.25,"cm"))


######################
# PLAN
######################

# Load data and define variables 
subj1 <- read.table('/Users/newxjy/Dropbox/VICE/JT/DEUBAL/Analyze/gradual_subj1.csv', header=TRUE, sep=",")
subj2 <- read.table('/Users/newxjy/Dropbox/VICE/JT/DEUBAL/Analyze/gradual_subj2.csv', header=TRUE, sep=",")
pilot_data <- rbind(subj1, subj2)
pilot_data$SN[661:1320] <- 2

# Baseline substraction
pilot_data$hand <- pilot_data$hand_theta
targets <- unique(pilot_data$ti)
num.tar <- length(targets)
num.sub <- length(unique(pilot_data$SN))

for (si in 1:num.sub){
  for(tar in 1:num.tar){
    idx <- pilot_data$SN == si & pilot_data$ti == targets[tar] & pilot_data$CN >= 1 & pilot_data$CN <= 5
    hand_mean <- mean(pilot_data$hand[idx], na.rm = TRUE)
    print(hand_mean)
    
    idx_ti <- pilot_data$SN == si & pilot_data$ti == targets[tar]
    pilot_data$hand[idx_ti] <- pilot_data$hand[idx_ti] - hand_mean
  }
}

#Plot hand angle
## Single subject
ggplot(pilot_data, aes(x = TN, y = hand, color = factor(SN))) + 
  geom_line() + 
  #facet_grid(.~ti) +
  labs(color = "SN") +
  xlab("Trial Number") +
  ylab("Hand") +
  geom_hline(yintercept=-30, linetype="dashed", color = "black") +
  geom_vline(xintercept= 85, linetype="dashed", color = "black") +
  geom_vline(xintercept= 25, linetype="dashed", color = "black") +
  ggtitle("Gradual Rotation") 

# Parcellate the discrimination trials
discrim_trial <- pilot_data[!(pilot_data$discrim==0),]

# Plot Accuracy ~ Time at movement target location and hand location 
## factorize discrim_onset 
levels(factor(discrim_trial$discrim_onset))

# separate MT and HT
discrim_trial$match <- 0 
discrim_trial$match[discrim_trial$discrim_tar- discrim_trial$ti == 30] <- "Other"
discrim_trial$match[discrim_trial$discrim_tar == discrim_trial$ti] <- "MT"
discrim_trial$match[discrim_trial$ti- discrim_trial$discrim_tar == 30] <- "HT"

## calculate accuracy 
discrim_trial$Accuracy <- 0
discrim_trial$Accuracy[discrim_trial$problem_report == "UpArrow" & discrim_trial$stim_type == 1] <- 1
discrim_trial$Accuracy[discrim_trial$problem_report == "DownArrow" & discrim_trial$stim_type == 2] <- 1
discrim_trial$Accuracy[discrim_trial$problem_report == "LeftArrow" & discrim_trial$stim_type == 3] <- 1
discrim_trial$Accuracy[discrim_trial$problem_report == "RightArrow" & discrim_trial$stim_type == 4] <- 1

# plot accuracy ~ discrim_onset at HT and MT
discrim_HTMT <- discrim_trial[!discrim_trial$match == 0,] 
main_count <- data_summary_count(discrim_HTMT, varname = c("Accuracy"), groupnames = c('discrim_onset', 'match') )
main_sum   <- data_summary(discrim_HTMT, varname = c("Accuracy"), groupnames = c('discrim_onset', 'match', 'SN') )
main_plot  <- ggplot(main_sum[main_count$Accuracy > 5, ], aes(x = discrim_onset, y  = Accuracy, group = match, color = match)) + 
  geom_point(size = 3) + 
  geom_line() + 
  labs(color = "Location") +
  xlab("Discrimination Onset") + 
  ylab("Accuracy Rate") + 
  geom_hline(yintercept=0.25, linetype="dashed", color = "black") + 
  facet_grid(.~SN) +
  ggtitle("Gradual Rotation")
#geom_errorbar(aes(ymin = Accuracy - sd, ymax = Accuracy + sd), width = 0.01, size = 1) +  th
print(main_plot)
meanMT1 <- mean(discrim_trial$MT[discrim_trial$SN == 1]) #0.07662854
meanMT2 <- mean(discrim_trial$MT[discrim_trial$SN == 2]) #0.1615683
meanRT1 <- mean(discrim_trial$RT[discrim_trial$SN == 1]) #0.3842373
meanRT2 <- mean(discrim_trial$RT[discrim_trial$SN == 2]) #0.3120135

sd(discrim_trial$RT) #0.08420526
mean(discrim_trial$RT) #0.373851
range(discrim_trial$RT) #0.07013612 0.98072933
sd(discrim_trial$discrim_onset) #0.05611558
mean(discrim_trial$discrim_onset) #0.2254386
range(discrim_trial$discrim_onset) #0.15 0.30
sd(main_sum$Accuracy) #0.2181573
mean(main_sum$Accuracy) #0.5337882
range(main_sum$Accuracy) #0.1000000 0.8571429
sd(discrim_trial$discrim_dist) #1.037001
mean(discrim_trial$discrim_dist) #1.28538
range(discrim_trial$discrim_dist) #0 3

# plot accuracy ~ distance
## recalculate distance
discrim_trial$distance <- 0 
discrim_trial$distance[discrim_trial$discrim_tar- discrim_trial$ti == 60] <- -2
discrim_trial$distance[discrim_trial$discrim_tar- discrim_trial$ti == 30] <- -1
discrim_trial$distance[discrim_trial$discrim_tar == discrim_trial$ti] <- 0
discrim_trial$distance[discrim_trial$ti- discrim_trial$discrim_tar == 30] <- 1
discrim_trial$distance[discrim_trial$ti- discrim_trial$discrim_tar == 60] <- 2

dist_summary <- data_summary(data = discrim_trial, varname = "Accuracy", groupnames = c("distance", "SN"))
plot_dist <- ggplot(data = dist_summary, aes(x = distance, y = Accuracy)) + 
  geom_bar(stat = "identity") +
  geom_hline(yintercept=0.25, linetype="dashed", color = "black") +
  ggtitle("Gradual Rotation") + 
  facet_grid(.~SN) +
  labs(x = "Discrimination Distance", y = "% Correct") + th
print(plot_dist)


# Hand curvature analysis (save for later )