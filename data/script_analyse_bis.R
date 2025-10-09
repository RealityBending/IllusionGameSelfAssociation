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

data <- read.csv2("monfichier.csv") # fichier pretraite

library(afex)
library(ARTool)
library(emmeans)
library(dplyr)
library(tidyverse)
library(rstatix)
library(car)
library(FSA)

###############################################################
#### STEP 2###################################################
#### Running ANOVAs on the SAT scores #########################
###############################################################

# Remplacer la modalite par afterglow
data$Group[data$Afterglow == 0] <- "Afterglow"

# Calculer age pour participant qui a mis date de naissance
data$Age[data$Age == 1980] <- 45

# Retirer les individus avec diagnostic psy
data <- data %>%
  filter(Current.Psychiatric != 0)

table(data$Group)

#################################################
### Deconstruction d une ancienne association ###
#################################################

#### Rejet d'une association incorrecte (peu importe la forme et la personne) ####

# Temps de reponse
# Mise en forme des donnees
data_rt_all <- data %>%
  pivot_longer(cols = c(rt_mismatch_self, rt_mismatch_friend, rt_mismatch_stranger),
               names_to = "person", values_to = "rt") %>%
  mutate(Group = factor(Group),
         rt = as.numeric(rt)) # Assure que c’est bien numérique

# ANOVA avec covariables
model <- aov(rt ~ Group + Age + Sex, data = data_rt_all)
summary(model)

# Stats descriptives 
data_rt_all %>%
  group_by(Group) %>%
  summarise(mean = mean(rt), sd = sd(rt))

# Graph
ggplot(data_rt_all, aes(x = Group, y = rt, fill = Group)) +
  geom_boxplot(alpha = 0.6) +
  geom_jitter(width = 0.1, alpha = 0.5) +
  labs(title = "Temps de réponse moyen par groupe (toutes conditions confondues)",
       x = "Groupe", y = "Temps de réponse (ms)") +
  theme_minimal()

# Nombre d erreur
# Mise en forme des donnees
data_error_all <- data %>%
  pivot_longer(cols = c(error_mismatch_self, error_mismatch_friend, error_mismatch_stranger),
               names_to = "person", values_to = "error") %>%
  mutate(Group = factor(Group),
         error = as.numeric(error)) # Assure que c’est bien numérique

# ANOVA avec covariables
model <- aov(error ~ Group + Age + Sex, data = data_error_all)
summary(model)

# Stats descriptives 
data_error_all %>%
  group_by(Group) %>%
  summarise(mean = mean(error), sd = sd(error))

# Graph
ggplot(data_error_all, aes(x = Group, y = error, fill = Group)) +
  geom_boxplot(alpha = 0.6) +
  geom_jitter(width = 0.1, alpha = 0.5) +
  labs(title = "Nombre d'erreurs moyen par groupe (toutes conditions confondues)",
       x = "Groupe", y = "Nombre d'erreurs") +
  theme_minimal()

### Coût supplémentaire lié à deconstruction d'une ancienne association ###

# Temps de reponse
# Mise en forme des donnees
data_rt_mismatch <- subset(data, select = c("Participant", "diff_rt_mismatch_self", "diff_rt_mismatch_friend", "diff_rt_mismatch_stranger", "Group", "Sex", "Age"))

data_rt_mismatch <- data_rt_mismatch %>%
  pivot_longer(cols = c(diff_rt_mismatch_self, diff_rt_mismatch_friend, diff_rt_mismatch_stranger),
               names_to = "person", values_to = "diff_rt") %>%
  mutate(person = as.character(person), 
           rperson = dplyr::recode(person, 
                         "diff_rt_mismatch_self" = "Self", 
                         "diff_rt_mismatch_friend" = "Friend", 
                         "diff_rt_mismatch_stranger" = "Stranger"),
         person = factor(person), 
         Group = factor(Group))
data_rt_mismatch$diff_rt <- as.numeric(data_rt_mismatch$diff_rt)


# ANOVA avec covariables
aov_res <- aov_ez(
  id = "Participant",
  dv = "diff_rt",
  data = data_rt_mismatch,
  within = "person",
  between = "Group",          # uniquement facteur Group ici
  covariate = c("Age", "Sex") # Sex comme covariable
)

summary(aov_res)

# Stats descriptives 
data_rt_mismatch %>%
  group_by(Group, person) %>%
  summarise(
    mean = mean(diff_rt, na.rm = TRUE),
    sd = sd(diff_rt, na.rm = TRUE),
    n = n()
  )


# Graph
ggplot(data_rt_mismatch, aes(x = person, y = diff_rt, color = Group)) +
  geom_boxplot() +
  geom_point(position = position_jitter(width = 0.1), alpha = 0.5) +
  labs(title = "Reaction Time by Association and Afterglow for Mismatch Trials",
       x = "Person", y = "Reaction Time (ms)",
       color = "Afterglow")

# Erreur
# Mise en forme des données
data_error_mismatch <- subset(data, select = c("Participant", "diff_error_mismatch_self", "diff_error_mismatch_friend", "diff_error_mismatch_stranger", "Group", "Age", "Sex"))

data_error_mismatch <- data_error_mismatch %>%
  pivot_longer(
    cols = c(diff_error_mismatch_self, diff_error_mismatch_friend, diff_error_mismatch_stranger),
    names_to = "person", values_to = "diff_error"
  ) %>%
  mutate(
    person = as.character(person),
    person = dplyr::recode(
      person,
      "diff_error_mismatch_self" = "Self",
      "diff_error_mismatch_friend" = "Friend",
      "diff_error_mismatch_stranger" = "Stranger"
    ),
    person = factor(person),
    Group = factor(Group)
  )
data_error_mismatch$diff_error <- as.numeric(data_error_mismatch$diff_error)

# ANOVA avec covariables
aov_res <- aov_ez(
  id = "Participant",
  dv = "diff_error",
  data = data_error_mismatch,
  within = "person",
  between = "Group",          # uniquement facteur Group ici
  covariate = c("Age", "Sex") # Sex comme covariable
)

summary (aov_res)

# Post hoc 
# Comparaisons entre niveaux du facteur within "person"
emmeans_person <- emmeans(aov_res, ~ person)
pairs(emmeans_person, adjust = "bonferroni")  # ou adjust = "tukey"

# Comparaisons entre niveaux du facteur between "Group"
emmeans_group <- emmeans(aov_res, ~ Group)
pairs(emmeans_group, adjust = "bonferroni")

# Interactions
emmeans_interaction <- emmeans(aov_res, ~ person | Group)
pairs(emmeans_interaction, adjust = "bonferroni")

# Stats descriptives 
data_error_mismatch %>%
  group_by(Group, person) %>%
  summarise(
    mean = mean(diff_error, na.rm = TRUE),
    sd = sd(diff_error, na.rm = TRUE),
    n = n()
  )

# Graph
ggplot(data_error_mismatch, aes(x = Group, y = diff_error, color = person)) +
  geom_boxplot() +
  geom_point(position = position_jitter(width = 0.1), alpha = 0.5) +
  labs(title = "Difference of error by Association and Afterglow for Mismatch Trials",
       x = "Afterglow", y = "Difference of error",
       color = "Person")


##############################################
### Construction d une nouvelle association ##
##############################################

# Acceptation d'une association correcte (peu importe la forme et la personne)

# Temps de reponse
# Mise en forme des donnees
data_rt_all <- data %>%
  pivot_longer(cols = c(rt_match_new_self, rt_match_new_friend, rt_match_new_stranger),
               names_to = "person", values_to = "rt") %>%
  mutate(Group = factor(Group),
         rt = as.numeric(rt)) # Assure que c’est bien numérique

# ANOVA avec covariables
model <- aov(rt ~ Group + Age + Sex, data = data_rt_all)
summary(model)

# Stats descriptives 
data_rt_all %>%
  group_by(Group) %>%
  summarise(mean = mean(rt), sd = sd(rt))

# Graph
ggplot(data_rt_all, aes(x = Group, y = rt, fill = Group)) +
  geom_boxplot(alpha = 0.6) +
  geom_jitter(width = 0.1, alpha = 0.5) +
  labs(title = "Temps de réponse moyen par groupe (toutes conditions confondues)",
       x = "Groupe", y = "Temps de réponse (ms)") +
  theme_minimal()


# Erreur
# Mise en forme des donnees
data_error_all <- data %>%
  pivot_longer(cols = c(error_match_new_self, error_match_new_friend, error_match_new_stranger),
               names_to = "person", values_to = "error") %>%
  mutate(Group = factor(Group),
         error = as.numeric(error)) # Assure que c’est bien numérique

# ANOVA avec covariables
model <- aov(error ~ Group + Age + Sex, data = data_error_all)
summary(model)

# Stats descriptives 
data_error_all %>%
  group_by(Group) %>%
  summarise(mean = mean(error), sd = sd(error))

# Graph
ggplot(data_error_all, aes(x = Group, y = error, fill = Group)) +
  geom_boxplot(alpha = 0.6) +
  geom_jitter(width = 0.1, alpha = 0.5) +
  labs(title = "Nombre d'erreurs moyen par groupe (toutes conditions confondues)",
       x = "Groupe", y = "Nombre d'erreurs") +
  theme_minimal()

### Avantage lié au self, en fonction du groupe###

# Temps de reponse
# Mise en forme des donnees
data_rt_match <- subset(data, select = c("Participant", "rt_match_new_self", "rt_match_new_friend", "rt_match_new_stranger", "Group", "Age", "Sex"))

data_rt_match <- data_rt_match %>%
  pivot_longer(cols = c(rt_match_new_self, rt_match_new_friend, rt_match_new_stranger),
               names_to = "person", values_to = "rt") %>%
  mutate(person = as.character(person),
person = dplyr::recode(
  person, 
                         "rt_match_new_self" = "Self", 
                         "rt_match_new_friend" = "Friend", 
                         "rt_match_new_stranger" = "Stranger"),
         person = factor(person), 
         Group = factor(Group))
data_rt_match$rt <- as.numeric(data_rt_match$rt)

# ANOVA avec covariables
aov_res <- aov_ez(
  id = "Participant",
  dv = "rt",
  data = data_rt_match,
  within = "person",
  between = "Group",          # uniquement facteur Group ici
  covariate = c("Age", "Sex") # Sex comme covariable
)
summary(aov_res)

# Post hoc
# Estimation des moyennes marginales
emm <- emmeans(aov_res, ~ person)
# Comparaisons post-hoc avec correction de Bonferroni
pairs(emm, adjust = "bonferroni")

# Stats descriptives
data_rt_match %>%
  group_by(person) %>%
  summarise(mean = mean(rt), sd = sd(rt))

# Graph
ggplot(data_rt_match, aes(x = Group, y = rt, color = person)) +
  geom_boxplot() +
  geom_point(position = position_jitter(width = 0.1), alpha = 0.5) +
  labs(title = "Reaction Time by Association and Afterglow for Mismatch Trials",
       x = "Group", y = "Reaction Time (ms)",
       color = "Person")

# Erreur
# Mise en forme des donnees
data_error_match <- subset(data, select = c("Participant", "error_match_new_self", "error_match_new_friend", "error_match_new_stranger", "Group", "Age", "Sex"))

data_error_match <- data_error_match %>%
  pivot_longer(cols = c(error_match_new_self, error_match_new_friend, error_match_new_stranger),
               names_to = "person", values_to = "error") %>%
  mutate(person = as.character(person),
         person = dplyr::recode(
           person, 
           "error_match_new_self" = "Self", 
           "error_match_new_friend" = "Friend", 
           "error_match_new_stranger" = "Stranger"),
         person = factor(person), 
         Group = factor(Group))
data_error_match$error <- as.numeric(data_error_match$error)

# ANOVA
aov_res <- aov_ez(id = "Participant", dv = "error", data = data_error_match, 
                  within = "person", between = "Group")

# Avec covariables
aov_res <- aov_ez(
  id = "Participant",
  dv = "error",
  data = data_error_match,
  within = "person",
  between = "Group",          # uniquement facteur Group ici
  covariate = c("Age", "Sex") # Sex comme covariable
)


summary(aov_res)

# Post hoc
# Estimation des moyennes marginales
emm <- emmeans(aov_res, ~ person)
# Comparaisons post-hoc avec correction de Bonferroni
pairs(emm, adjust = "bonferroni")

# Stats descriptives
data_error_match %>%
  group_by(person) %>%
  summarise(mean = mean(error), sd = sd(error))

# Graph
ggplot(data_error_match, aes(x = Group, y = error, color = person)) +
  geom_boxplot() +
  geom_point(position = position_jitter(width = 0.1), alpha = 0.5) +
  labs(title = "Error by Association and Afterglow for Mismatch Trials",
       x = "Group", y = "Average number of error",
       color = "Person")





