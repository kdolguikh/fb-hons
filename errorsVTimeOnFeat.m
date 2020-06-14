%% # errors and time on features during fb

% correlation bw total errors (experiment) and time on features during
% feedback on first 50 trials 

function [r, p] = errorsVTimeOnFeat(experiment)

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
    subjects = explvl.Subject(explvl.FeedbackDuration == 1000);
    %subjects = explvl.Subject(explvl.FeedbackDuration == 9000);
    %subjects = explvl.Subject;
    errors = explvl.errorCount;
    
    % we only want the first 50 trials
    triallvl(triallvl.TrialID > 50, :) = [];
    feedback = [];
    
    for i = 1:length(subjects)
        fb = triallvl.timeOnFeaturesp4(triallvl.Subject == subjects(i));
        feedback = [feedback; nanmean(fb)];
    end
    
    % check for & delete any NaN values in feedback (the corr function
    % seems to not be able to handle NaNs)
    toRemove = isnan(feedback);
    feedback(toRemove) = [];
    errors(toRemove) = [];
    
    [r, p] = corr(errors, feedback);
    scatter(errors, feedback);

end