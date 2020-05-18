%% feedback analyses

    %  Author: Kat 
    %  Date Created: 
    %  Last Edit: 
     
    %  Cognitive Science Lab, Simon Fraser University 
    %  Originally Created For: feedback
      
    %  Reviewed: 
    %  Verified: 

    
    %  PURPOSE: runs all fb analyses in one place
 
    
    %  INPUT: []

    
    %  OUTPUT: analyses and plots for all measures used in kat's feedback
    %  honours paper. may change for actual paper.
    
    %  Additional Scripts Used: 
        % subjTableHack and/or Gnarly: to get data
        
        % basics: calculates stats and makes plots for basic measures
        % straight out of the summary table (accuracy, fixation duration
        % during feedback, response time (p2 duration), gaze optimization
        % during p2, time on irrelevant features (both p2 and p4, pretty
        % sure I did not end up using this), feedback phase duration)
        
        % stimulusVsButtons: calculates and plots time on stimulus features
        % vs time on feedback buttons during feedback phase
        
        % attnChange: calculates and plots (by individual) difference
        % between p2 and p4 gaze optimization (inspired by Leong et al
        % 2017)
        
        % postError: investigates attention changes following error trials
        % by a) comparing p2 (stimulus presentation) attention on error
        % trials and trials immediately following, the next trial of the
        % same correct category, and next trial of the same stimulus and b)
        % comparing p4 (feedback phase) attention on all error trials to
        % all correct trials 
        
        % shortFB: for self-paced experiments (aka not feedback2 or
        % feedback3), counts fixations to relevant stimulus features,
        % irrelevant stimulus features, and feedback buttons in short
        % feedback phases containing 4 or fewer total fixations
        
        % gramm: matlab plotting library (makes pretty graphs). 
        % source: https://github.com/piermorel/gramm
        
    
    
    %  Additional Comments: this is the quarantine version aka I had to
    %  rework the parts that would normally use Gnarly. Because of this,
    %  for now ignore any lines of code that get data (aka treat them like
    %  a magic black box). when the lab is open again, I will revert these
    %  to Gnarly, and then we can verify those parts. 
    


% these five experiments were analyzed for kat's honours paper. not sure if
% this will change for the real paper. the first three are old eye tracking
% experiments using selfpaced feedback (no limit on how long it stays on
% screen). feedback2 and feedback3 are more recent and manipulated the
% amount of time particpants could look at feedback (1 sec vs 9 sec)
experiments = ["asset", "sshrcif", "sato", "feedback2", "feedback3"];

% these are file locations on kat's computer, if you need to run this
% script, replace with locations of gramm (link above) and
% InProgress/Experiments/FeedbackDuration/Analyses on your computer.
% InProgress folder will be unnecessary once we can go back to Gnarly/SQL.
addpath('/Users/16132/Documents/lab/gramm-master');     % for pretty plots :)
addpath('/Users/16132/Documents/lab/InProgress-master/Experiments/FeedbackDuration/Analyses');      % this is the location of subjTableHack



%=same process for each experiment
for i = experiments
    
    % load data:
    dir = strcat('Users/16132/Documents/lab/KAT/', i);  %again, location on kat's laptop. 

    % kat has this data. if you need it to verify, ask her.
    load(strcat(dir, '/explvl.mat'));
    load(strcat(dir, '/fixlvl.mat'));
    
    % summary table (binned). same as above
    sumr = strcat(dir, '/subjectTable.mat');
    load(sumr);
    
    % these two measures (fixations to stimulus features and buttons) do
    % not come directly from a data table. normally they would be
    % calculated using Gnarly. 
    p4feat = subjTableHack(i, 'p4feature');
    p4but = subjTableHack(i, 'p4button');
    
    % append to table we are going to use
    subjectTable.p4features = p4feat(:, 2);
    subjectTable.p4button = p4but(:, 2);
    
    % remove nonlearners
    subjectTable = subjectTable(subjectTable.CP > 0, :);
    
    % and remove bad gaze people (identified in explvl tables)
    gd = explvl.Subject(explvl.GazeDropper == 1);
    
    for j = 1:length(gd)    % inefficient, I know... :(
        subjectTable(subjectTable.Subject == gd(j), :) = [];
    end
    
    % identify experiments as fixedtime or not (this will have an impact on
    % what analyses we do)
    fixed = 0;
    
    if  strcmp(i, "feedback2") || strcmp(i, "feedback3")
        fixed = 1;
    end
        
    %% ok now my measures
     
    % bins for t-tests
    cps = subjTableHack(i, 'cp');
    
    % cut all bad gaze people and nonlearners from fixlvl table (needed for
    % lower level attentional measures)
    gd = explvl.GazeDropper == 1;
    nl = explvl.Learner == 0;
    cut = gd | nl;
    badSubs = explvl.Subject(cut);

    for j = 1:length(badSubs) 
         cutMe = badSubs(j);
         x = cps(:, 1) == cutMe;
         cps(x, :) = [];
         
         fixlvl(fixlvl.Subject == j, :) = [];
    end

    
    % for several of my analyses, I compare values in the first bin of
    % trials to what I call the learned bin. this is the bin containing the
    % trial 11 trials after CP is reached. for each subject, their CP is
    % the first of 24 trials they got correct in a row--this is the point
    % at which we can say they have learned the categories. targetTrial is
    % a vector containing this value for each subject in the experiment
    
    targetTrial = cps(:, 2) + 11;
    
    % binSize and limits are used to make future calculations easier.
    % binSize is the number of trials per bin (varies by experiment) and
    % limits gives us the maximum trial number of each bin.
    binSize = max(subjectTable.Trial(subjectTable.TrialBin == 1));
    limits = (1:15)*binSize;
        
    
    % basics makes plots and does ttests for all measures listed in
    % description above. for fixed-time experiments, it also compares
    % across conditions. summaryBinned is a table containing bin means for
    % all measures.
    summaryBinned = basics(i, fixed, subjectTable, targetTrial, limits);
    
    
    % stimulus vs buttons during fb
    % stims will be time spent on stimulus features, buttons will be time
    % spent on feedback signals during the feedback phase of the experiment
    [stims, buttons] = stimulusVsButtons(i, subjectTable, fixed);   
    
    % t-test (paired samples...comparing stimulus to button values for
    % each participant)
    disp('stimulus vs buttons everyone')
    [h, p, ci, stats] = ttest(stims, buttons)
    
    % ratio of time on buttons:stimulus features
    disp('ratio')
    ratio = nanmean(buttons)/nanmean(stims)
    
    % proportion of time spent on stimulus features
    disp('stimulus feature rate')
    stimRate = nanmean(stims)/(nanmean(stims) + nanmean(buttons))
    
    
    % attention change 
    % attnChange creates plots for each individual and runs a paired
    % samples t-test for first bin vs learned bin attention change. for
    % fixed-time experiments, it also compares across conditions.
    disp('attentionChange')
    [h, p, ci, stats] = attnChange(i, subjectTable, targetTrial, binSize, limits, badSubs, fixed)
 
    
    % post-error
    % we run post-error twice; once for p2 attention and once for p4
    % attention.
    % for p2, we compare across three kinds of post-error trial:
%         -the trial immediately following the error (ttestn)
%         -the next trial with the same category as the error trial
%         (ttestc)
%         -the next trial with the same stimulus as the error trial
%         (ttests)
%     we return the t-test results comparing error trials with each of these post-error types
    [ttestn, ttestc, ttests] = postError(i, subjectTable, 'p2', cps(:, 2), fixed);     
    
    % for p4 there is only one t-test: attention on error trials compared
    % to correct trials
    [~, irrel, ~] = postError(i, subjectTable, 'p4', cps(:, 2), fixed); 

    
    % SELF-PACED ONLY:
     if ~fixed
        % shortFB counts the number of fixations during very short feedback
        % phases (less than 4 fixations) to relevant stimulus features,
        % irrelevant stimulus features, and feedback buttons. it plots
        % these numbers and returns them. relevance is a 3x1 matrix:
        % relevance(1) = relevant features, relevance(2) = irrelevant
        % features, relevance(3) = feedback buttons
        relevance = shortFB(i, subjectTable, fixlvl);
        
     end
          
    % finally, we run a model predicting learning from attentional measures
    % using our summary table. 
    predictLearning = fitlme(subjectTable, 'Accuracy ~ p4features + rt2 + Optimization +  TrialBin + (TrialBin|Subject)');
      
    
end

 