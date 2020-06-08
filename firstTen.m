% watson and blair 2008 replication

function [learner, nonlearner] = firstTen(experiment)

    directory = 'C:/Users/16132/Documents/lab/feedback/KAT/';
    addpath('C:/Users/16132/Documents/lab/feedback/fb-hons');  % for subjTableHack
    
    load(strcat(directory, '/', experiment, '/triallvl.mat'));
    load(strcat(directory, '/', experiment, '/explvl.mat'));
    
    timeOnFeatures = subjTableHack(experiment, 'p4feature');
    triallvl.timeOnFeaturesp4 = timeOnFeatures(:, 2);
    
    % eliminate random responders
    explvl(explvl.Random == 1, :) = [];
    
    subjects = explvl.Subject;
    learnerCorrect = [];
    learnerIncorrect = [];
    nlCorrect = [];
    nlIncorrect = [];
    
    for i = 1:length(subjects)
        subjTrialLvl = triallvl(triallvl.Subject == subjects(i) & triallvl.TrialID < 11, :);
        
        correct = subjTrialLvl.timeOnFeaturesp4(subjTrialLvl.TrialAccuracy == 1);
        
        incorrect = subjTrialLvl.timeOnFeaturesp4(subjTrialLvl.TrialAccuracy == 0);
        
       if explvl.Learner(explvl.Subject == subjects(i)) == 1
          learnerCorrect = [learnerCorrect; nanmean(correct)];
          learnerIncorrect = [learnerIncorrect; nanmean(incorrect)];
       else
          nlCorrect = [nlCorrect; nanmean(correct)];
          nlIncorrect = [nlIncorrect; nanmean(incorrect)];
       end

        
    end
    
    learner = [learnerCorrect, learnerIncorrect];
    nonlearner = [nlCorrect, nlIncorrect];

    correct = [nanmean(learnerCorrect), nanmean(nlCorrect)];
    incorrect = [nanmean(learnerIncorrect), nanmean(nlIncorrect)];
    
    info = [correct; incorrect];
    
    bar(info)
    xticklabels({'correct trials', 'incorrect trials'})
    legend({'learners', 'non-learners'})

end