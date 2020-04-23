%% feedback analyses

% for all experiments:

experiments = ["asset", "sshrcif", "sato", "feedback2", "feedback3"];

addpath('/Users/16132/Documents/lab/gramm-master');     % for pretty plots :)
addpath('/Users/16132/Documents/lab/InProgress-master/Experiments/FeedbackDuration/Analyses');      % this is the location of subjTableHack


% loop thru same process for each one

for i = experiments
    
    % load data:
    
    dir = strcat('Users/16132/Documents/lab/KAT/', i);

    load(strcat(dir, '/explvl.mat'));
    load(strcat(dir, '/fixlvl.mat'));
    
    % summary table (binned)
    sumr = strcat(dir, '/subjectTable.mat');
    load(sumr);
    
    p4feat = subjTableHack(i, 'p4feature');
    p4but = subjTableHack(i, 'p4button');
    
    subjectTable.p4features = p4feat(:, 2);
    subjectTable.p4button = p4but(:, 2);
    
    % filtered for learners now
    subjectTable = subjectTable(subjectTable.CP > 0, :);
    
    % need to filter for bad gaze people, too...
    gd = explvl.Subject(explvl.GazeDropper == 1);
    for j = 1:length(gd)    % god this is inefficient
        subjectTable(subjectTable.Subject == gd(j), :) = [];
    end
    
    
    fixed = 0;
    
    if  strcmp(i, "feedback2") || strcmp(i, "feedback3")
        fixed = 1;
    end
        
    %% ok now my measures
     
    % bins for t-tests
    cps = subjTableHack(i, 'cp');
    
    % cut all the people we don't want...
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

    
    targetTrial = cps(:, 2) + 11;
    
    binSize = max(subjectTable.Trial(subjectTable.TrialBin == 1));
    limits = (1:15)*binSize;
        
    % summaryBinned gives me the result of grpstats for ALL measures in the
    % summaryTable. basics also outputs a billion plots for me. any actual
    % stats I want will be done with the outputted table.
         
    summaryBinned = basics(i, fixed, subjectTable, targetTrial, limits);
    
    
    % stimulus vs buttons during fb
        
     [stims, buttons] = stimulusVsButtons(i, subjectTable);   
    
     % paired samples
    disp('stimulus vs buttons everyone')
    [h, p, ci, stats] = ttest(stims, buttons)
    disp('ratio')
    ratio = nanmean(buttons)/nanmean(stims)
    disp('stimulus feature rate')
    stimRate = nanmean(stims)/(nanmean(stims) + nanmean(buttons))
    
    
    % attention change (p2 vs p4)
    disp('attentionChange')
    [h, p, ci, stats] = attnChange(i, subjectTable, targetTrial, binSize, limits, badSubs)
        % I'm returning the results of my paired sample t test
 
    
    % post-error

    [ttestn, ttestc, ttests] = postError(i, subjectTable, 'p2', cps(:, 2));     
   [~, irrel, ~] = postError(i, subjectTable, 'p4', cps(:, 2)); 


     if ~fixed
    % SELF-PACED ONLY:
        % - really short feedback phases
        relevance = shortFB(i, subjectTable, fixlvl);
        
     end
          

   predictLearning = fitlme(subjectTable, 'Accuracy ~ p4features + rt2 + Optimization +  TrialBin + (TrialBin|Subject)');
      
    
end

 