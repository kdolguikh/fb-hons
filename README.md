# fb-hons
##Scripts used for analysis for Kat's honours project, 2020



master.m: basic outline of all analyses. loops through all 5 experiments (asset, sshrc_if, sato, fb2, fb3)

basics.m: calculates summary statistics and creates plots and conducts t-tests for all measures coming straight from summary tables (eg. accuracy, response time, fb duration)

stimulusVsButtons.m: calculates & plots time on stimulus features vs time on feedback buttons during p4.

shortFB.m: for self-paced experiments, counts funcRelevance locations of fixations during very short feedback phases (<4 fixations).

attnChange.m: calculates and plots (for individuals) difference in attention between p2 and p4 on the same trial. inspired by Leong et al (2017)

postError.m: compares attention on error and correct trials during p2 (error trial compared to next trial, next trial same category, next trial same stimulus) and during feedback (comparing all errors to all correct)

subjTableHack.m: basically just a remake of gnarly, but using .mat explvl, triallvl, and fixlvl tables instead of SQL. 
