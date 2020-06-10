% watson and blair 2008 replication 
%(see fig. 4 in that paper...Attentional Allocation During Feedback:
%Eyetracking Adventures on the Other Side of the Response)

function [learner, nonlearner] = firstTen(experiment)

    directory = 'C:/Users/16132/Documents/lab/feedback/KAT/';
    addpath('C:/Users/16132/Documents/lab/feedback/fb-hons');  % for subjTableHack
    
    load(strcat(directory, '/', experiment, '/triallvl.mat'));
    load(strcat(directory, '/', experiment, '/explvl.mat'));
    
    % we are looking at time spent on stimulus features during feedback
    timeOnFeatures = subjTableHack(experiment, 'p4feature');
    triallvl.timeOnFeaturesp4 = timeOnFeatures(:, 2);
    
    % eliminate random responders
    explvl(explvl.Random == 1, :) = [];

    
    %% toggle back and forth for 1 sec or 9 sec people in feedback 2/3, or use third one for other experiments (sorry, lazy)
    %subjects = explvl.Subject(explvl.FeedbackDuration == 1000);
    %subjects = explvl.Subject(explvl.FeedbackDuration == 9000);
    subjects = explvl.Subject
    
    learnerCorrect = [];
    learnerIncorrect = [];
    nlCorrect = [];
    nlIncorrect = [];
    
    for i = 1:length(subjects)
        % get first ten trials for current subject
        subjTrialLvl = triallvl(triallvl.Subject == subjects(i) & triallvl.TrialID < 11, :);
        
        % identify correct and incorrect trials
        correct = subjTrialLvl.timeOnFeaturesp4(subjTrialLvl.TrialAccuracy == 1);
        incorrect = subjTrialLvl.timeOnFeaturesp4(subjTrialLvl.TrialAccuracy == 0);
        
        % append to appropriate variable (learner or not)
       if explvl.Learner(explvl.Subject == subjects(i)) == 1
          learnerCorrect = [learnerCorrect; nanmean(correct)];
          learnerIncorrect = [learnerIncorrect; nanmean(incorrect)];
       else
          nlCorrect = [nlCorrect; nanmean(correct)];
          nlIncorrect = [nlIncorrect; nanmean(incorrect)];
       end

        
    end
    
     % idk why I did this, just so we could return something I guess. but
    % these two variables are more or less useless (just a different way of
    % arranging the actual data)
    learner = [learnerCorrect, learnerIncorrect];
    nonlearner = [nlCorrect, nlIncorrect];

    % correct and incorrect will now contain a mean for learners on correct
    % trials, mean for nonlearners on correct trials, mean for learners on
    % incorrect trials, and mean for nonlearners on incorrect trials
    correct = [nanmean(learnerCorrect), nanmean(nlCorrect)];
    incorrect = [nanmean(learnerIncorrect), nanmean(nlIncorrect)];
    
    % SEM = standard deviation/sqrt(n)
    correctsem = [nanstd(learnerCorrect)/sqrt(length(learnerCorrect)), nanstd(nlCorrect)/sqrt(length(nlCorrect))];
    incorrectsem = [nanstd(learnerIncorrect)/sqrt(length(learnerIncorrect)), nanstd(nlIncorrect)/sqrt(length(nlIncorrect))];
    
    
    % just to make the graph easier to make
    info = [correct; incorrect];
    error = [correctsem; incorrectsem];
    
    % create bar plot
    hBar = bar(info)
    
    % UGH, so basically when you do grouped bar graphs, if you just do
    % error bars the normal way, they don't end up on top of the actual
    % bars, they end up stacked on top of each other in the middle. so you
    % have to do this trick to get them where you want them (see this
    % Mathworks page:
    % https://www.mathworks.com/matlabcentral/answers/407467-how-to-put-error-bars-on-top-of-grouped-bars
    % in the answer given by dpb (second answer))
    xBar=cell2mat(get(hBar,'XData')).' + [hBar.XOffset];  % compute bar centers
    
    % we want the error bars on the same figure, so hold on
    hold on
    
    % black error bar, with no lines connecting them
    errorbar(xBar, info, error, '.k');
    
    xticklabels({'correct trials', 'incorrect trials'})
    legend({'learners', 'non-learners'}, 'location', 'northwest')
    
    
    % two t-tests: comparing learners to nonlearners on correct trials, and
    % comparing learners to nonlearners on inccorect trials
    % (purposely not suppressing output on both of these so we don't have
    % to return a million values and can just display them instead)
    [h, p, ci, stats] = ttest2(learnerCorrect, nlCorrect)
    [h2, p2, ci2, stats2] = ttest2(learnerIncorrect, nlIncorrect)

end