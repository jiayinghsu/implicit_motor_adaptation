rm(list = ls())

##### LOAD IN LIBRARIES #####

source("~/Dropbox/VICE/JT/FUNCTIONS/R_functions/r_functions.R")
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

##### LOAD IN LIBRARIES #####

pilot_data <- read.table('~/Dropbox/VICE/JT/MR_DEUB/Analyze/Pilot/CINDYLIN_S1_091919_trial.csv', header=TRUE, sep=",")
MT_list <- unique(pilot_data$ti)
pilot_data$discrim_onset <- pilot_data$discrim_onset * 1000
pilot_data$RT <- pilot_data$RT * 1000
pilot_data$RT <- pilot_data$RT - 2100
pilot_data$DT <- mod(pilot_data$ti + 360 - pilot_data$discrim_rot, 360)
move_bin_size <- 300

if(pilot_data$ri >= 0){
  pilot_data$hand_theta_50 <- - pilot_data$hand_theta_50 
}

##### LOAD IN LIBRARIES #####

# leave only discrimination trials
pilot_rot <- pilot_data[pilot_data$discrim == 1,  ]

# leave only accurate reaches
pilot_rot <- pilot_rot [ pilot_rot$hand_theta_50 >= 60 & pilot_rot$hand_theta_50 <= 120, ]
count_cond <- data_summary_count(pilot_rot, varname = 'TN', groupnames = c('ti', 'discrim_rot') )

#ggplot(pilot_data, aes(x = TN, y = hand_theta_50) ) + geom_point() + facet_grid(.~ti)
#ggplot(pilot_data, aes(x = TN, y = RT) ) + geom_point() + facet_grid(.~ti)

##### BINE RT #####

pilot_rot$moveonset_bin <- floor(((pilot_rot$discrim_onset - pilot_rot$RT)/move_bin_size))
ggplot(pilot_rot, aes(x = moveonset_bin) ) + geom_histogram() + facet_grid(.~discrim_rot)

##### CALCULATE ACCURACY #####

# 1 = B = UP
# 2 = D = DOWN
# 3 = P =  LEFT
# 4 = Q = RIGHT

# subj as
pilot_rot$Accuracy <- 0
pilot_rot$Accuracy[pilot_rot$problem_report == "UpArrow" & pilot_rot$stim_type == 1] <- 1
pilot_rot$Accuracy[pilot_rot$problem_report == "DownArrow" & pilot_rot$stim_type == 2] <- 1
pilot_rot$Accuracy[pilot_rot$problem_report == "LeftArrow" & pilot_rot$stim_type == 3] <- 1
pilot_rot$Accuracy[pilot_rot$problem_report == "RightArrow" & pilot_rot$stim_type == 4] <- 1

##### MAIN PLOT #####

main_sum   <- data_summary(pilot_rot, varname = c("Accuracy"), groupnames = c('moveonset_bin', 'discrim_rot') )
main_count <- data_summary_count(pilot_rot, varname = c("Accuracy"), groupnames = c('moveonset_bin', 'discrim_rot') )
main_plot  <- ggplot(main_sum[main_count$Accuracy > 5, ], aes(x = moveonset_bin, y  = Accuracy, group = discrim_rot, color = factor(discrim_rot))) + 
  geom_point(size = 3) + geom_line() + geom_errorbar(aes(ymin = Accuracy - sd, ymax = Accuracy + sd), width = 0.02, size = 1) +  th
print(main_plot)




