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
subjx <- read.table('/Users/newxjy/Dropbox/VICE/JT/DEUBAL/Analyze/baseline_subj6000.csv', header=TRUE, sep=",")

# Baseline substraction
subjx$hand <- subjx$hand_theta
targets <- unique(subjx$ti)
num.tar <- length(targets)
num.sub <- length(unique(subjx$SN))

for (si in 1:num.sub){
  for(tar in 1:num.tar){
    idx <- subjx$SN == si & subjx$ti == targets[tar] & subjx$CN >= 1 & subjx$CN <= 5
    hand_mean <- mean(subjx$hand[idx], na.rm = TRUE)
    print(hand_mean)
    
    idx_ti <- subjx$SN == si & subjx$ti == targets[tar]
    subjx$hand[idx_ti] <- subjx$hand[idx_ti] - hand_mean
  }
}

#Plot hand angle
## Single subject
ggplot(subjx, aes(x = TN, y = hand, color = factor(SN))) + 
  geom_line() + 
  #facet_grid(.~ti) +
  labs(color = "SN") +
  xlab("Trial Number") +
  ylab("Hand") +
  ggtitle("Baseline") +
  geom_hline(yintercept=-0, linetype="dashed", color = "black") +
  geom_vline(xintercept= 21, linetype="dashed", color = "black") +
  geom_vline(xintercept= 41, linetype="dashed", color = "black") 

# Parcellate the discrimination trials
discrim_trial <- subjx[!(subjx$discrim==0),]
discrim_trial <- discrim_trial[!(abs(discrim_trial$hand) < -5) & !(abs(discrim_trial$hand) > 5),] 

# Plot Accuracy ~ Time at movement target location and hand location 
## factorize discrim_onset 
levels(factor(discrim_trial$discrim_onset))

## calculate accuracy 
discrim_trial$Accuracy <- 0
discrim_trial$Accuracy[discrim_trial$problem_report == "b" & discrim_trial$stim_type == 1] <- 1
discrim_trial$Accuracy[discrim_trial$problem_report == "d" & discrim_trial$stim_type == 2] <- 1
discrim_trial$Accuracy[discrim_trial$problem_report == "p" & discrim_trial$stim_type == 3] <- 1
discrim_trial$Accuracy[discrim_trial$problem_report == "q" & discrim_trial$stim_type == 4] <- 1

# plot accuracy 
main_count <- data_summary_count(discrim_trial, varname = c("Accuracy"), groupnames = c('discrim_onset') )
main_sum   <- data_summary(discrim_trial, varname = c("Accuracy"), groupnames = c('discrim_onset', 'SN') )
main_plot  <- ggplot(main_sum[main_count$Accuracy > 5, ], aes(x = discrim_onset, y  = Accuracy)) + 
  geom_point(size = 3) + 
  geom_line() + 
  labs(color = "Location") +
  xlab("Discrimination Onset") + 
  ylab("Accuracy Rate") + 
  geom_hline(yintercept=0.25, linetype="dashed", color = "black") + 
  facet_grid(.~SN) +
  ggtitle("Baseline")
#geom_errorbar(aes(ymin = Accuracy - sd, ymax = Accuracy + sd), width = 0.01, size = 1) +  th
print(main_plot)

# plot accuracy ~ distance
## recalculate distance
discrim_trial$distance <- 0 
discrim_trial$distance[discrim_trial$discrim_tar- discrim_trial$ti == 60] <- -2
discrim_trial$distance[discrim_trial$discrim_tar- discrim_trial$ti == 30] <- -1
discrim_trial$distance[discrim_trial$discrim_tar == discrim_trial$ti] <- 0
discrim_trial$distance[discrim_trial$ti- discrim_trial$discrim_tar == 30] <- 1
discrim_trial$distance[discrim_trial$ti- discrim_trial$discrim_tar == 60] <- 2
hist(discrim_trial$distance)

dist_summary <- data_summary(data = discrim_trial, varname = "Accuracy", groupnames = c("distance", "SN"))
plot_dist <- ggplot(data = dist_summary, aes(x = distance, y = Accuracy)) + 
  geom_bar(stat = "identity") +
  geom_hline(yintercept=0.25, linetype="dashed", color = "black") +
  ggtitle("Baseline") +
  facet_grid(.~SN) +
  labs(x = "Discrimination Distance", y = "% Correct") + th
print(plot_dist)


# Hand curvature analysis (save for later )