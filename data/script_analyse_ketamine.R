##############################################################
### KETAMINE, ILLUSION GAME, SELF ASSOCIATION TASK ###########
##############################################################
### Script for data analysis ##################
##############################################################

###############################################################
#### STEP 1 ###################################################
#### Importing the cleaned dataset  #########################
###############################################################

# Setting working directory
setwd("~/Documents/GitHub/IllusionGameSelfAssociation/data")

data <- read.csv2("ketamine.csv") # fichier pretraite

library(afex)
library(ARTool)
library(emmeans)
library(dplyr)
library(tidyverse)
library(rstatix)
library(car)
library(FSA)
library(singcar)
library(psych)

###############################################################
#### STEP 2###################################################
#### Running ANOVAs on the SAT scores #########################
###############################################################


# Retirer les individus avec diagnostic psy
data <- data %>%
  filter(Current.Psychiatric_T0 != 0)

table(data$Group_T0)

###############################################
### Modif cognitive (peu importe le label) ####
###############################################

#### Rejet des associations incorrectes
## RT

# Étape 1 : Calcul de la moyenne RT mismatch pour chaque participant
data_avg_rt <- data %>%
  rowwise() %>%
  mutate(
    avg_rt_mismatch_T0 = mean(c(rt_mismatch_self_T0, rt_mismatch_friend_T0, rt_mismatch_stranger_T0, rt_mismatch_ancient_self_T0, rt_mismatch_ancient_friend_T0, rt_mismatch_ancient_stranger_T0), na.rm = TRUE),
    avg_rt_mismatch_T1 = mean(c(rt_mismatch_self_T1, rt_mismatch_friend_T1, rt_mismatch_stranger_T1, rt_mismatch_ancient_self_T1, rt_mismatch_ancient_friend_T1, rt_mismatch_ancient_stranger_T1), na.rm = TRUE)
  ) %>%
  ungroup()

# Scores pour le sujet ketamine
case_rt <- data_avg_rt %>%
  filter(Group_T1 == "ketamine_T1") %>%
  select(avg_rt_mismatch_T0, avg_rt_mismatch_T1) %>%
  unlist()

# Scores pour les contrôles
controls_rt <- data_avg_rt %>%
  filter(Group_T1 == "control_T1") %>%
  select(avg_rt_mismatch_T0, avg_rt_mismatch_T1)

# Appliquer le test RSDT
RSDT(case_rt[1], case_rt[2], controls_rt[[1]], controls_rt[[2]])

## Erreur
# Étape 1 : Calcul de la moyenne ERROR mismatch pour chaque participant
data_avg_error <- data %>%
  rowwise() %>%
  mutate(
    avg_error_mismatch_T0 = mean(c(error_mismatch_self_T0, error_mismatch_friend_T0, error_mismatch_stranger_T0, error_mismatch_ancient_self_T0, error_mismatch_ancient_friend_T0, error_mismatch_ancient_stranger_T0), na.rm = TRUE),
    avg_error_mismatch_T1 = mean(c(error_mismatch_self_T1, error_mismatch_friend_T1, error_mismatch_stranger_T1, error_mismatch_ancient_self_T1, error_mismatch_ancient_friend_T1, error_mismatch_ancient_stranger_T1), na.rm = TRUE)
  ) %>%
  ungroup()


# Scores pour le sujet ketamine
case_error <- data_avg_error %>%
  filter(Group_T1 == "ketamine_T1") %>%
  select(avg_error_mismatch_T0, avg_error_mismatch_T1) %>%
  unlist()

# Scores pour les contrôles
controls_error <- data_avg_error %>%
  filter(Group_T1 == "control_T1") %>%
  select(avg_error_mismatch_T0, avg_error_mismatch_T1)

# Appliquer le test RSDT
RSDT(case_error[1], case_error[2], controls_error[[1]], controls_error[[2]])

#### Acceptation des associations correctes

# TR

# Étape 1 : Calcul de la moyenne RT match pour chaque participant
data_avg_rt <- data %>%
  rowwise() %>%
  mutate(
    avg_rt_match_T0 = mean(c(rt_match_new_self_T0, rt_match_new_friend_T0, rt_match_new_stranger_T0), na.rm = TRUE),
    avg_rt_match_T1 = mean(c(rt_match_new_self_T1, rt_match_new_friend_T1, rt_match_new_stranger_T1), na.rm = TRUE)
  ) %>%
  ungroup()

# Scores pour le sujet ketamine
case_rt <- data_avg_rt %>%
  filter(Group_T1 == "ketamine_T1") %>%
  select(avg_rt_match_T0, avg_rt_match_T1) %>%
  unlist()

# Scores pour les contrôles
controls_rt <- data_avg_rt %>%
  filter(Group_T1 == "control_T1") %>%
  select(avg_rt_match_T0, avg_rt_match_T1)

# Appliquer le test RSDT
RSDT(case_rt[1], case_rt[2], controls_rt[[1]], controls_rt[[2]])

# Erreur

# Étape 1 : Calcul de la moyenne erreur match pour chaque participant
data_avg_error <- data %>%
  rowwise() %>%
  mutate(
    avg_error_match_T0 = mean(c(error_match_new_self_T0, error_match_new_friend_T0, error_match_new_stranger_T0), na.rm = TRUE),
    avg_error_match_T1 = mean(c(error_match_new_self_T1, error_match_new_friend_T1, error_match_new_stranger_T1), na.rm = TRUE)
  ) %>%
  ungroup()

# Scores pour le sujet ketamine
case_error <- data_avg_error %>%
  filter(Group_T1 == "ketamine_T1") %>%
  select(avg_error_match_T0, avg_error_match_T1) %>%
  unlist()

# Scores pour les contrôles
controls_error <- data_avg_error %>%
  filter(Group_T1 == "control_T1") %>%
  select(avg_error_match_T0, avg_error_match_T1)

# Appliquer le test RSDT
RSDT(case_error[1], case_error[2], controls_error[[1]], controls_error[[2]])


########################################################
## Il y a t-il un ERS sur deconstruction/construction ##
##chez les controles ###################################
###########################################

# Deconstruction
#### En moyennant T0 et T1
# Créer la moyenne T0-T1 pour chaque condition, uniquement pour les contrôles
data_avg <- data %>%
  filter(Group_T1 == "control_T1") %>%
  rowwise() %>%
  mutate(
    self_avg = mean(c(diff_rt_mismatch_self_T0, diff_rt_mismatch_self_T1), na.rm = TRUE),
    friend_avg = mean(c(diff_rt_mismatch_friend_T0, diff_rt_mismatch_friend_T1), na.rm = TRUE)
  ) %>%
  ungroup() %>%
  select(Participant_T1, self_avg, friend_avg)

# Mettre au format long
data_long_avg <- data_avg %>%
  pivot_longer(cols = c(self_avg, friend_avg), names_to = "Condition", values_to = "RT")

# Appliquer le test de Friedman
friedman_result_avg <- friedman.test(RT ~ Condition | Participant_T1, data = data_long_avg)

# Afficher le résultat
print(friedman_result_avg)



# pour les erreurs
data_avg <- data %>%
  filter(Group_T1 == "control_T1") %>%
  rowwise() %>%
  mutate(
    self_avg = mean(c(diff_error_mismatch_self_T0, diff_error_mismatch_self_T1), na.rm = TRUE),
    friend_avg = mean(c(diff_error_mismatch_friend_T0, diff_error_mismatch_friend_T1), na.rm = TRUE)
  ) %>%
  ungroup() %>%
  select(Participant_T1, self_avg, friend_avg)

# Mettre au format long
data_long_avg <- data_avg %>%
  pivot_longer(cols = c(self_avg, friend_avg), names_to = "Condition", values_to = "ERROR")

# Appliquer le test de Friedman
friedman_result_avg <- friedman.test(ERROR ~ Condition | Participant_T1, data = data_long_avg)

# Afficher le résultat
print(friedman_result_avg)


# Construction
#### En moyennant T0 et T1
# Créer la moyenne T0-T1 pour chaque condition, uniquement pour les contrôles
data_avg <- data %>%
  filter(Group_T1 == "control_T1") %>%
  rowwise() %>%
  mutate(
    self_avg = mean(c(rt_match_new_self_T0, rt_match_new_self_T1), na.rm = TRUE),
    friend_avg = mean(c(rt_match_new_friend_T0, rt_match_new_friend_T1), na.rm = TRUE)
  ) %>%
  ungroup() %>%
  select(Participant_T1, self_avg, friend_avg)

# Mettre au format long
data_long_avg <- data_avg %>%
  pivot_longer(cols = c(self_avg, friend_avg), names_to = "Condition", values_to = "RT")

# Appliquer le test de Friedman
friedman_result_avg <- friedman.test(RT ~ Condition | Participant_T1, data = data_long_avg)

# Afficher le résultat
print(friedman_result_avg)


# pour les erreurs
data_avg <- data %>%
  filter(Group_T1 == "control_T1") %>%
  rowwise() %>%
  mutate(
    self_avg = mean(c(error_match_new_self_T0, error_match_new_self_T1), na.rm = TRUE),
    friend_avg = mean(c(error_match_new_friend_T0, error_match_new_friend_T1), na.rm = TRUE)
  ) %>%
  ungroup() %>%
  select(Participant_T1, self_avg, friend_avg)

# Mettre au format long
data_long_avg <- data_avg %>%
  pivot_longer(cols = c(self_avg, friend_avg), names_to = "Condition", values_to = "ERROR")

# Appliquer le test de Friedman
friedman_result_avg <- friedman.test(ERROR ~ Condition | Participant_T1, data = data_long_avg)

# Afficher le résultat
print(friedman_result_avg)

ggplot(data_long_avg, aes(x = Condition, y = ERROR)) +
  stat_summary(fun = mean, geom = "bar", fill = "#69b3a2", width = 0.6) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
  geom_jitter(width = 0.1, size = 2, alpha = 0.6, color = "gray40") +
  labs(
    title = "Erreurs (moyenne T0/T1)",
    x = "Condition",
    y = "Nombre d'erreurs"
  ) +
  theme_minimal()


########################################################
## Il y a t-il un ERF sur deconstruction/construction ##
##chez les controles ###################################
###########################################

# Deconstruction
# TR
#### En moyennant T0 et T1
# Créer la moyenne T0-T1 pour chaque condition, uniquement pour les contrôles
data_avg <- data %>%
  filter(Group_T1 == "control_T1") %>%
  rowwise() %>%
  mutate(
    stranger_avg = mean(c(diff_rt_mismatch_stranger_T0, diff_rt_mismatch_stranger_T1), na.rm = TRUE),
    friend_avg = mean(c(diff_rt_mismatch_friend_T0, diff_rt_mismatch_friend_T1), na.rm = TRUE)
  ) %>%
  ungroup() %>%
  select(Participant_T1, stranger_avg, friend_avg)

# Mettre au format long
data_long_avg <- data_avg %>%
  pivot_longer(cols = c(stranger_avg, friend_avg), names_to = "Condition", values_to = "RT")

# Appliquer le test de Friedman
friedman_result_avg <- friedman.test(RT ~ Condition | Participant_T1, data = data_long_avg)

# Afficher le résultat
print(friedman_result_avg)


# ERREUR
#### En moyennant T0 et T1
# Créer la moyenne T0-T1 pour chaque condition, uniquement pour les contrôles
data_avg <- data %>%
  filter(Group_T1 == "control_T1") %>%
  rowwise() %>%
  mutate(
    stranger_avg = mean(c(diff_error_mismatch_stranger_T0, diff_error_mismatch_stranger_T1), na.rm = TRUE),
    friend_avg = mean(c(diff_error_mismatch_friend_T0, diff_error_mismatch_friend_T1), na.rm = TRUE)
  ) %>%
  ungroup() %>%
  select(Participant_T1, stranger_avg, friend_avg)

# Mettre au format long
data_long_avg <- data_avg %>%
  pivot_longer(cols = c(stranger_avg, friend_avg), names_to = "Condition", values_to = "RT")

# Appliquer le test de Friedman
friedman_result_avg <- friedman.test(RT ~ Condition | Participant_T1, data = data_long_avg)

# Afficher le résultat
print(friedman_result_avg)


# Construction
# TR

#### En moyennant T0 et T1
# Créer la moyenne T0-T1 pour chaque condition, uniquement pour les contrôles
data_avg <- data %>%
  filter(Group_T1 == "control_T1") %>%
  rowwise() %>%
  mutate(
    stranger_avg = mean(c(rt_match_new_stranger_T0, rt_match_new_stranger_T1), na.rm = TRUE),
    friend_avg = mean(c(rt_match_new_friend_T0, rt_match_new_friend_T1), na.rm = TRUE)
  ) %>%
  ungroup() %>%
  select(Participant_T1, stranger_avg, friend_avg)

# Mettre au format long
data_long_avg <- data_avg %>%
  pivot_longer(cols = c(stranger_avg, friend_avg), names_to = "Condition", values_to = "RT")

# Appliquer le test de Friedman
friedman_result_avg <- friedman.test(RT ~ Condition | Participant_T1, data = data_long_avg)

# Afficher le résultat
print(friedman_result_avg)

# ERROR

#### En moyennant T0 et T1
# Créer la moyenne T0-T1 pour chaque condition, uniquement pour les contrôles
data_avg <- data %>%
  filter(Group_T1 == "control_T1") %>%
  rowwise() %>%
  mutate(
    stranger_avg = mean(c(error_match_new_stranger_T0, error_match_new_stranger_T1), na.rm = TRUE),
    friend_avg = mean(c(error_match_new_friend_T0, error_match_new_friend_T1), na.rm = TRUE)
  ) %>%
  ungroup() %>%
  select(Participant_T1, stranger_avg, friend_avg)

# Mettre au format long
data_long_avg <- data_avg %>%
  pivot_longer(cols = c(stranger_avg, friend_avg), names_to = "Condition", values_to = "RT")

# Appliquer le test de Friedman
friedman_result_avg <- friedman.test(RT ~ Condition | Participant_T1, data = data_long_avg)

# Afficher le résultat
print(friedman_result_avg)

#################################################
### Il y a t-il une diff d'ERS ? ################
#################################################
### Deconstruction d'une association
# TR
# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("ers_rt_decons_T0", "ers_rt_decons_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "ers_rt_decons_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "ers_rt_decons_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)

# ERREUR
# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("ers_error_decons_T0", "ers_error_decons_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "ers_error_decons_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "ers_error_decons_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)


####### Construction d'une nouvelle association
# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("ers_rt_cons_T0", "ers_rt_cons_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "ers_rt_cons_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "ers_rt_cons_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)

# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("ers_error_cons_T0", "ers_error_cons_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "ers_error_cons_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "ers_error_cons_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)


# Graphique
# 1. Restructuration des données
data_long <- data %>%
  select(Participant_T1, Group_T1,
         error_match_new_self_T0, error_match_new_self_T1,
         error_match_new_friend_T0, error_match_new_friend_T1,
         error_match_new_stranger_T0, error_match_new_stranger_T1) %>%
  pivot_longer(
    cols = starts_with("error_match_new"),
    names_to = c("Condition", "Time"),
    names_pattern = "error_match_new_([^_]+)_(T\\d)",
    values_to = "RT"
  ) %>%
  mutate(
    Groupe = case_when(
      Group_T1 == "ketamine_T1" ~ "Sujet expérimental",
      Group_T1 == "control_T1" ~ "Contrôles"
    ),
    Condition_Time = factor(paste(Condition, Time, sep = "_"),
                            levels = c("self_T0", "self_T1",
                                       "friend_T0", "friend_T1",
                                       "stranger_T0", "stranger_T1"))
  )
# Résumé des contrôles
controls_summary <- data_long %>%
  filter(Groupe == "Contrôles") %>%
  group_by(Condition_Time) %>%
  summarise(
    mean = mean(RT, na.rm = TRUE),
    sd = sd(RT, na.rm = TRUE),
    .groups = "drop"
  )
# Graphique combiné
ggplot() +
  # Barres des moyennes (Contrôles)
  geom_col(data = controls_summary,
           aes(x = Condition_Time, y = mean),
           fill = "grey80", color = "black", width = 0.6) +
  
  # Barres d'erreur (SD)
  geom_errorbar(data = controls_summary,
                aes(x = Condition_Time, ymin = mean - sd, ymax = mean + sd),
                width = 0.2) +
  
  # Points individuels (contrôles + sujet)
  geom_point(data = data_long,
             aes(x = Condition_Time, y = RT, color = Groupe),
             position = position_jitter(width = 0.1), size = 2.5, alpha = 0.8) +
  
  # Ligne sujet expérimental (T0 à T1 par condition)
  geom_line(data = data_long %>%
              filter(Groupe == "Sujet expérimental") %>%
              arrange(Condition_Time),
            aes(x = Condition_Time, y = RT, group = Condition),
            color = "red", linewidth = 1.1) +
  
  scale_color_manual(values = c("Contrôles" = "black", "Sujet expérimental" = "red")) +
  
  labs(
    title = "Évolution des erreurs de reconnaissance – Sujet vs Contrôles",
    x = "Condition et Temps",
    y = "Nombre d’erreurs",
    color = "Groupe"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "right",
    axis.text.x = element_text(angle = 45, hjust = 1)
  )





library(dplyr)
library(tidyr)
library(ggplot2)

# Restructuration des données
data_long <- data %>%
  select(Participant_T1, Group_T1,
         error_match_new_self_T0, error_match_new_self_T1,
         error_match_new_friend_T0, error_match_new_friend_T1,
         error_match_new_stranger_T0, error_match_new_stranger_T1) %>%
  pivot_longer(
    cols = starts_with("error_match_new"),
    names_to = c("Condition", "Time"),
    names_pattern = "error_match_new_([^_]+)_(T\\d)",
    values_to = "RT"
  ) %>%
  mutate(
    Groupe = case_when(
      Group_T1 == "ketamine_T1" ~ "Sujet expérimental",
      Group_T1 == "control_T1" ~ "Contrôles"
    ),
    Time = factor(Time, levels = c("T0", "T1")),
    Condition = factor(Condition, levels = c("self", "friend", "stranger"))
  )
controls_summary <- data_long %>%
  filter(Groupe == "Contrôles") %>%
  group_by(Time, Condition) %>%
  summarise(
    mean = mean(RT, na.rm = TRUE),
    sd = sd(RT, na.rm = TRUE),
    .groups = "drop"
  )
ggplot() +
  # Barres de moyennes (contrôles)
  geom_col(data = controls_summary,
           aes(x = Condition, y = mean, fill = Time),
           position = position_dodge(width = 0.6),
           color = "black", width = 0.5) +
  
  # Barres d’erreur (SD)
  geom_errorbar(data = controls_summary,
                aes(x = Condition, ymin = mean - sd, ymax = mean + sd, group = Time),
                position = position_dodge(width = 0.6),
                width = 0.2) +
  
  # Points individuels
  geom_point(data = data_long,
             aes(x = Condition, y = RT, color = Groupe, group = Time),
             position = position_jitterdodge(jitter.width = 0.15, dodge.width = 0.6),
             size = 2.5, alpha = 0.8) +
  
  # Lignes sujet expérimental (T0 → T1 pour chaque condition)
  geom_line(data = data_long %>%
              filter(Groupe == "Sujet expérimental") %>%
              arrange(Time),
            aes(x = Condition, y = RT, group = interaction(Condition, Participant_T1)),
            color = "red", linewidth = 1.2,
            position = position_dodge(width = 0.6)) +
  
  scale_fill_manual(values = c("T0" = "grey80", "T1" = "grey50")) +
  scale_color_manual(values = c("Contrôles" = "black", "Sujet expérimental" = "red")) +
  
  facet_wrap(~Time, nrow = 1) +
  labs(
    title = "Évolution des erreurs de reconnaissance – Sujet vs Contrôles",
    x = "Condition",
    y = "Nombre d’erreurs",
    fill = "Temps",
    color = "Groupe"
  ) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "right")





#################################################
### Il y a t-il une diff d'ERF ? ################
#################################################
### Deconstruction d'une association

# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("erf_rt_decons_T0", "erf_rt_decons_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "erf_rt_decons_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "erf_rt_decons_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)


# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("erf_error_decons_T0", "erf_error_decons_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "erf_error_decons_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "erf_error_decons_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)

####### Construction d'une nouvelle association
# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("erf_rt_cons_T0", "erf_rt_cons_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "erf_rt_cons_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "erf_rt_cons_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)

# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("erf_error_cons_T0", "erf_error_cons_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "erf_error_cons_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "erf_error_cons_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)











# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("diff_rt_mismatch_self_T0", "diff_rt_mismatch_self_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "diff_rt_mismatch_self_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "diff_rt_mismatch_self_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)

# Moyennes et écarts-types des contrôles pour chaque tâche
control_summary <- data %>%
  filter(Group_T1 == "control_T1") %>%
  summarise(
    mean_T0 = mean(diff_rt_mismatch_self_T0, na.rm = TRUE),
    sd_T0   = sd(diff_rt_mismatch_self_T0, na.rm = TRUE),
    mean_T1 = mean(diff_rt_mismatch_self_T1, na.rm = TRUE),
    sd_T1   = sd(diff_rt_mismatch_self_T1, na.rm = TRUE)
  )

# Score du sujet ketamine
case_scores <- data %>%
  filter(Group_T1 == "ketamine_T1") %>%
  select(diff_rt_mismatch_self_T0, diff_rt_mismatch_self_T1)

# Préparer les données pour le graphe
plot_data <- data.frame(
  Task = c("T0", "T1"),
  Control_Mean = c(control_summary$mean_T0, control_summary$mean_T1),
  Control_SD = c(control_summary$sd_T0, control_summary$sd_T1),
  Case_Score = c(case_scores$diff_rt_mismatch_self_T0, case_scores$diff_rt_mismatch_self_T1)
)

# Graphique
ggplot(plot_data, aes(x = Task)) +
  geom_bar(aes(y = Control_Mean), stat = "identity", fill = "lightblue", width = 0.5) +
  geom_errorbar(aes(ymin = Control_Mean - Control_SD, ymax = Control_Mean + Control_SD),
                width = 0.2, color = "blue") +
  geom_point(aes(y = Case_Score), color = "red", size = 4) +
  geom_line(aes(y = Case_Score, group = 1), color = "red", linetype = "dashed") +
  labs(
    title = "Comparaison du sujet ketamine avec les contrôles",
    y = "Temps de réponse, déconstruction", x = "Temps de mesure"
  ) +
  theme_minimal()

# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("diff_error_mismatch_self_T0", "diff_error_mismatch_self_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "diff_error_mismatch_self_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "diff_error_mismatch_self_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)

# Moyennes et écarts-types des contrôles pour chaque tâche
control_summary <- data %>%
  filter(Group_T1 == "control_T1") %>%
  summarise(
    mean_T0 = mean(diff_error_mismatch_self_T0, na.rm = TRUE),
    sd_T0   = sd(diff_error_mismatch_self_T0, na.rm = TRUE),
    mean_T1 = mean(diff_error_mismatch_self_T1, na.rm = TRUE),
    sd_T1   = sd(diff_error_mismatch_self_T1, na.rm = TRUE)
  )

# Score du sujet ketamine
case_scores <- data %>%
  filter(Group_T1 == "ketamine_T1") %>%
  select(diff_error_mismatch_self_T0, diff_error_mismatch_self_T1)

# Préparer les données pour le graphe
plot_data <- data.frame(
  Task = c("T0", "T1"),
  Control_Mean = c(control_summary$mean_T0, control_summary$mean_T1),
  Control_SD = c(control_summary$sd_T0, control_summary$sd_T1),
  Case_Score = c(case_scores$diff_error_mismatch_self_T0, case_scores$diff_error_mismatch_self_T1)
)

# Graphique
ggplot(plot_data, aes(x = Task)) +
  geom_bar(aes(y = Control_Mean), stat = "identity", fill = "lightblue", width = 0.5) +
  geom_errorbar(aes(ymin = Control_Mean - Control_SD, ymax = Control_Mean + Control_SD),
                width = 0.2, color = "blue") +
  geom_point(aes(y = Case_Score), color = "red", size = 4) +
  geom_line(aes(y = Case_Score, group = 1), color = "red", linetype = "dashed") +
  labs(
    title = "Comparaison du sujet ketamine avec les contrôles",
    y = "Nombre d'erreurs, déconstruction", x = "Temps de mesure"
  ) +
  theme_minimal()


#################################################
### Construction d une nouvelle association #####
#################################################
# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("rt_match_new_self_T0", "rt_match_new_self_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "rt_match_new_self_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "rt_match_new_self_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)

# Moyennes et écarts-types des contrôles pour chaque tâche
control_summary <- data %>%
  filter(Group_T1 == "control_T1") %>%
  summarise(
    mean_T0 = mean(rt_match_new_self_T0, na.rm = TRUE),
    sd_T0   = sd(rt_match_new_self_T0, na.rm = TRUE),
    mean_T1 = mean(rt_match_new_self_T1, na.rm = TRUE),
    sd_T1   = sd(rt_match_new_self_T1, na.rm = TRUE)
  )

# Score du sujet ketamine
case_scores <- data %>%
  filter(Group_T1 == "ketamine_T1") %>%
  select(rt_match_new_self_T0, rt_match_new_self_T1)

# Préparer les données pour le graphe
plot_data <- data.frame(
  Task = c("T0", "T1"),
  Control_Mean = c(control_summary$mean_T0, control_summary$mean_T1),
  Control_SD = c(control_summary$sd_T0, control_summary$sd_T1),
  Case_Score = c(case_scores$rt_match_new_self_T0, case_scores$rt_match_new_self_T1)
)

# Graphique
ggplot(plot_data, aes(x = Task)) +
  geom_bar(aes(y = Control_Mean), stat = "identity", fill = "lightblue", width = 0.5) +
  geom_errorbar(aes(ymin = Control_Mean - Control_SD, ymax = Control_Mean + Control_SD),
                width = 0.2, color = "blue") +
  geom_point(aes(y = Case_Score), color = "red", size = 4) +
  geom_line(aes(y = Case_Score, group = 1), color = "red", linetype = "dashed") +
  labs(
    title = "Comparaison du sujet ketamine avec les contrôles",
    y = "Temps de réponse, construction", x = "Temps de mesure"
  ) +
  theme_minimal()




# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("error_match_new_self_T0", "error_match_new_self_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "error_match_new_self_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "error_match_new_self_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)

# Moyennes et écarts-types des contrôles pour chaque tâche
control_summary <- data %>%
  filter(Group_T1 == "control_T1") %>%
  summarise(
    mean_T0 = mean(error_match_new_self_T0, na.rm = TRUE),
    sd_T0   = sd(error_match_new_self_T0, na.rm = TRUE),
    mean_T1 = mean(error_match_new_self_T1, na.rm = TRUE),
    sd_T1   = sd(error_match_new_self_T1, na.rm = TRUE)
  )

# Score du sujet ketamine
case_scores <- data %>%
  filter(Group_T1 == "ketamine_T1") %>%
  select(error_match_new_self_T0, error_match_new_self_T1)

# Préparer les données pour le graphe
plot_data <- data.frame(
  Task = c("T0", "T1"),
  Control_Mean = c(control_summary$mean_T0, control_summary$mean_T1),
  Control_SD = c(control_summary$sd_T0, control_summary$sd_T1),
  Case_Score = c(case_scores$error_match_new_self_T0, case_scores$error_match_new_self_T1)
)

# Graphique
ggplot(plot_data, aes(x = Task)) +
  geom_bar(aes(y = Control_Mean), stat = "identity", fill = "lightblue", width = 0.5) +
  geom_errorbar(aes(ymin = Control_Mean - Control_SD, ymax = Control_Mean + Control_SD),
                width = 0.2, color = "blue") +
  geom_point(aes(y = Case_Score), color = "red", size = 4) +
  geom_line(aes(y = Case_Score, group = 1), color = "red", linetype = "dashed") +
  labs(
    title = "Comparaison du sujet ketamine avec les contrôles",
    y = "Nombre d'erreurs, construction", x = "Temps de mesure"
  ) +
  theme_minimal()




# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("rt_match_new_self_T0", "rt_match_new_self_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "rt_match_new_self_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "rt_match_new_self_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)

# Moyennes et écarts-types des contrôles pour chaque tâche
control_summary <- data %>%
  filter(Group_T1 == "control_T1") %>%
  summarise(
    mean_T0 = mean(rt_match_new_self_T0, na.rm = TRUE),
    sd_T0   = sd(rt_match_new_self_T0, na.rm = TRUE),
    mean_T1 = mean(rt_match_new_self_T1, na.rm = TRUE),
    sd_T1   = sd(rt_match_new_self_T1, na.rm = TRUE)
  )

# Score du sujet ketamine
case_scores <- data %>%
  filter(Group_T1 == "ketamine_T1") %>%
  select(rt_match_new_self_T0, rt_match_new_self_T1)

# Préparer les données pour le graphe
plot_data <- data.frame(
  Task = c("T0", "T1"),
  Control_Mean = c(control_summary$mean_T0, control_summary$mean_T1),
  Control_SD = c(control_summary$sd_T0, control_summary$sd_T1),
  Case_Score = c(case_scores$rt_match_new_self_T0, case_scores$rt_match_new_self_T1)
)

# Graphique
ggplot(plot_data, aes(x = Task)) +
  geom_bar(aes(y = Control_Mean), stat = "identity", fill = "lightblue", width = 0.5) +
  geom_errorbar(aes(ymin = Control_Mean - Control_SD, ymax = Control_Mean + Control_SD),
                width = 0.2, color = "blue") +
  geom_point(aes(y = Case_Score), color = "red", size = 4) +
  geom_line(aes(y = Case_Score, group = 1), color = "red", linetype = "dashed") +
  labs(
    title = "Comparaison du sujet ketamine avec les contrôles",
    y = "Temps de réponse, construction", x = "Temps de mesure"
  ) +
  theme_minimal()















# En T0
# Filtrer uniquement les participants contrôle à T0
data_friedman <- data %>%
  filter(Group_T1 == "control_T1") %>%
  select(Participant_T1, diff_rt_mismatch_self_T0, diff_rt_mismatch_friend_T0)

# Mettre les données au format long pour le test de Friedman
data_long <- data_friedman %>%
  pivot_longer(
    cols = c(diff_rt_mismatch_self_T0, diff_rt_mismatch_friend_T0),
    names_to = "Condition",
    values_to = "RT"
  )

# Appliquer le test de Friedman
friedman_result <- friedman.test(RT ~ Condition | Participant_T1, data = data_long)

# Afficher le résultat
print(friedman_result)

# Filtrer uniquement les participants contrôle à T0
data_friedman <- data %>%
  filter(Group_T1 == "control_T1") %>%
  select(Participant_T1, diff_error_mismatch_self_T0, diff_error_mismatch_friend_T0)

# Mettre les données au format long pour le test de Friedman
data_long <- data_friedman %>%
  pivot_longer(
    cols = c(diff_error_mismatch_self_T0, diff_error_mismatch_friend_T0),
    names_to = "Condition",
    values_to = "ERROR"
  )

# Appliquer le test de Friedman
friedman_result <- friedman.test(ERROR ~ Condition | Participant_T1, data = data_long)

# Afficher le résultat
print(friedman_result)


# En T1
# Filtrer uniquement les participants contrôle à T1
data_friedman <- data %>%
  filter(Group_T1 == "control_T1") %>%
  select(Participant_T1, diff_rt_mismatch_self_T1, diff_rt_mismatch_friend_T1)

# Mettre les données au format long pour le test de Friedman
data_long <- data_friedman %>%
  pivot_longer(
    cols = c(diff_rt_mismatch_self_T1, diff_rt_mismatch_friend_T1),
    names_to = "Condition",
    values_to = "RT"
  )

# Appliquer le test de Friedman
friedman_result <- friedman.test(RT ~ Condition | Participant_T1, data = data_long)

# Afficher le résultat
print(friedman_result)

# Filtrer uniquement les participants contrôle à T1
data_friedman <- data %>%
  filter(Group_T1 == "control_T1") %>%
  select(Participant_T1, diff_error_mismatch_self_T1, diff_error_mismatch_friend_T1)

# Mettre les données au format long pour le test de Friedman
data_long <- data_friedman %>%
  pivot_longer(
    cols = c(diff_error_mismatch_self_T1, diff_error_mismatch_friend_T1),
    names_to = "Condition",
    values_to = "ERROR"
  )

# Appliquer le test de Friedman
friedman_result <- friedman.test(ERROR ~ Condition | Participant_T1, data = data_long)

# Afficher le résultat
print(friedman_result)




























# Étape 1 : Calcul de la moyenne RT match pour chaque participant
data_avg_rt <- data %>%
  rowwise() %>%
  mutate(
    avg_rt_match_T0 = mean(c(rt_match_new_self_T0, rt_match_new_friend_T0, rt_match_new_stranger_T0), na.rm = TRUE),
    avg_rt_match_T1 = mean(c(rt_match_new_self_T1, rt_match_new_friend_T1, rt_match_new_stranger_T1), na.rm = TRUE)
  ) %>%
  ungroup()

# Passage au format long pour ggplot
data_long <- data_avg_rt %>%
  pivot_longer(
    cols = c(avg_rt_match_T0, avg_rt_match_T1),
    names_to = "Timepoint",
    names_prefix = "avg_rt_match_",
    values_to = "RT"
  )


ggplot(data_long, aes(x = Timepoint, y = RT, group = Group_T1, color = Group_T1)) +
  geom_line(alpha = 0.3) +  # lignes individuelles
  stat_summary(aes(group = Group_T1), fun = mean, geom = "line", size = 1.5) +  # moyenne par groupe
  stat_summary(aes(group = Group_T1), fun = mean, geom = "point", size = 3) +  # points de moyenne
  labs(title = "Évolution du temps de réponse moyen (Match)",
       x = "Temps",
       y = "Temps de réponse moyen",
       color = "Groupe") +
  theme_minimal()


# Scores pour le sujet ketamine
case_rt <- data_avg_rt %>%
  filter(Group_T1 == "ketamine_T1") %>%
  select(avg_rt_match_T0, avg_rt_match_T1) %>%
  unlist()

# Scores pour les contrôles
controls_rt <- data_avg_rt %>%
  filter(Group_T1 == "control_T1") %>%
  select(avg_rt_match_T0, avg_rt_match_T1)

# Appliquer le test RSDT
RSDT(case_rt[1], case_rt[2], controls_rt[[1]], controls_rt[[2]])



# Étape 1 : Calcul de la moyenne RT match pour chaque participant
data_avg_error <- data %>%
  rowwise() %>%
  mutate(
    avg_error_match_T0 = mean(c(error_match_new_self_T0, error_match_new_friend_T0, error_match_new_stranger_T0), na.rm = TRUE),
    avg_error_match_T1 = mean(c(error_match_new_self_T1, error_match_new_friend_T1, error_match_new_stranger_T1), na.rm = TRUE)
  ) %>%
  ungroup()

# Passage au format long pour ggplot
data_long <- data_avg_error %>%
  pivot_longer(
    cols = c(avg_error_match_T0, avg_error_match_T1),
    names_to = "Timepoint",
    names_prefix = "avg_error_match_",
    values_to = "ERROR"
  )


ggplot(data_long, aes(x = Timepoint, y = ERROR, group = Group_T1, color = Group_T1)) +
  geom_line(alpha = 0.3) +  # lignes individuelles
  stat_summary(aes(group = Group_T1), fun = mean, geom = "line", size = 1.5) +  # moyenne par groupe
  stat_summary(aes(group = Group_T1), fun = mean, geom = "point", size = 3) +  # points de moyenne
  labs(title = "Évolution du temps de réponse moyen (Match)",
       x = "Temps",
       y = "Nombre d'erreurs moyen",
       color = "Groupe") +
  theme_minimal()


# Scores pour le sujet ketamine
case_error <- data_avg_error %>%
  filter(Group_T1 == "ketamine_T1") %>%
  select(avg_error_match_T0, avg_error_match_T1) %>%
  unlist()

# Scores pour les contrôles
controls_error <- data_avg_error %>%
  filter(Group_T1 == "control_T1") %>%
  select(avg_error_match_T0, avg_error_match_T1)

# Appliquer le test RSDT
RSDT(case_error[1], case_error[2], controls_error[[1]], controls_error[[2]])
















# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("ers_error_decons_T0", "ers_error_decons_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "ers_error_decons_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "ers_error_decons_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)

# Moyennes et écarts-types des contrôles pour chaque tâche
control_summary <- data %>%
  filter(Group_T1 == "control_T1") %>%
  summarise(
    mean_T0 = mean(ers_error_decons_T0, na.rm = TRUE),
    sd_T0   = sd(ers_error_decons_T0, na.rm = TRUE),
    mean_T1 = mean(ers_error_decons_T1, na.rm = TRUE),
    sd_T1   = sd(ers_error_decons_T1, na.rm = TRUE)
  )

# Score du sujet ketamine
case_scores <- data %>%
  filter(Group_T1 == "ketamine_T1") %>%
  select(ers_error_decons_T0, ers_error_decons_T1)

# Préparer les données pour le graphe
plot_data <- data.frame(
  Task = c("T0", "T1"),
  Control_Mean = c(control_summary$mean_T0, control_summary$mean_T1),
  Control_SD = c(control_summary$sd_T0, control_summary$sd_T1),
  Case_Score = c(case_scores$ers_error_decons_T0, case_scores$ers_error_decons_T1)
)

# Graphique
ggplot(plot_data, aes(x = Task)) +
  geom_bar(aes(y = Control_Mean), stat = "identity", fill = "lightblue", width = 0.5) +
  geom_errorbar(aes(ymin = Control_Mean - Control_SD, ymax = Control_Mean + Control_SD),
                width = 0.2, color = "blue") +
  geom_point(aes(y = Case_Score), color = "red", size = 4) +
  geom_line(aes(y = Case_Score, group = 1), color = "red", linetype = "dashed") +
  labs(
    title = "Comparaison du sujet ketamine avec les contrôles",
    y = "Score ers_error_decons", x = "Tâche"
  ) +
  theme_minimal()





# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("ers_rt_decons_T0", "ers_rt_decons_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "ers_rt_decons_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "ers_rt_decons_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)



# Extraire les scores du sujet unique
case_scores <- data[data$Group_T1 == "ketamine_T1", c("ers_error_decons_T0", "ers_error_decons_T1")]

# Extraire les scores des contrôles
controls_T0 <- data[data$Group_T1 == "control_T1", "ers_error_decons_T0"]
controls_T1 <- data[data$Group_T1 == "control_T1", "ers_error_decons_T1"]

# Appliquer le test RSDT
RSDT(case_scores[[1]], case_scores[[2]], controls_T0, controls_T1)


# Moyennes et écarts-types des contrôles pour chaque tâche
control_summary <- data %>%
  filter(Group_T1 == "control_T1") %>%
  summarise(
    mean_T0 = mean(ers_error_decons_T0, na.rm = TRUE),
    sd_T0   = sd(ers_error_decons_T0, na.rm = TRUE),
    mean_T1 = mean(ers_error_decons_T1, na.rm = TRUE),
    sd_T1   = sd(ers_error_decons_T1, na.rm = TRUE)
  )

# Score du sujet ketamine
case_scores <- data %>%
  filter(Group_T1 == "ketamine_T1") %>%
  select(ers_error_decons_T0, ers_error_decons_T1)

# Préparer les données pour le graphe
plot_data <- data.frame(
  Task = c("T0", "T1"),
  Control_Mean = c(control_summary$mean_T0, control_summary$mean_T1),
  Control_SD = c(control_summary$sd_T0, control_summary$sd_T1),
  Case_Score = c(case_scores$ers_error_decons_T0, case_scores$ers_error_decons_T1)
)

# Graphique
ggplot(plot_data, aes(x = Task)) +
  geom_bar(aes(y = Control_Mean), stat = "identity", fill = "lightblue", width = 0.5) +
  geom_errorbar(aes(ymin = Control_Mean - Control_SD, ymax = Control_Mean + Control_SD),
                width = 0.2, color = "blue") +
  geom_point(aes(y = Case_Score), color = "red", size = 4) +
  geom_line(aes(y = Case_Score, group = 1), color = "red", linetype = "dashed") +
  labs(
    title = "Comparaison du sujet ketamine avec les contrôles",
    y = "Score ers_error_decons", x = "Tâche"
  ) +
  theme_minimal()





#################################################
### Construction d'une nouvelle association ####
#################################################
