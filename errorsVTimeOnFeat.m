%% # errors and time on features during fb

% correlation between total errors (experiment) and time on features during
% feedback on first 50 trials

% - Notes -
% Experiment name is the main argument, with feedbackDuration being an
% optional argument for experiments with this manipulation. Currently, this
% only applies to Feedback 2 and 3.

% Reviewed: Tyrus Tracey [July 4th, 2020] 
% Verified:

function [r, p] = errorsVTimeOnFeat(experiment, feedbackDuration)
    directory = 'C:/Users/16132/Documents/lab/feedback/KAT/';
    addpath('C:/Users/16132/Documents/lab/feedback/fb-hons');  % for subjTableHack
    load(strcat(directory, '/', experiment, '/triallvl.mat'));
    load(strcat(directory, '/', experiment, '/explvl.mat'));
    
    % we are looking at time spent on stimulus features during feedback
    timeOnFeatures = subjTableHack(experiment, 'p4feature');
    triallvl.timeOnFeaturesp4 = timeOnFeatures(:, 2);
    
    % eliminate random responders
    explvl(explvl.random == 1, :) = [];
    
    %% Handling for 1 sec or 9 sec people in feedback 2/3
    if strcmp(experiment, "Feedback2") || strcmp(experiment, "Feedback3")
        if ~exist('feedbackDuration','var')
            error('Feedback duration(ms) is a required argument for this experiment.');
            return;
        end
        if feedbackDuration == 1000
            subjects = explvl.Subject(explvl.FeedbackDuration == 1000);
            errors = explvl.errorCount(explvl.FeedbackDuration == 1000);
        elseif feedbackDuration == 9000
            subjects = explvl.Subject(explvl.FeedbackDuration == 9000);
            errors = explvl.errorCount(explvl.FeedbackDuration == 9000);
        else
            error('Inputted feedback duration not implemented in this function.');
            return;
        end
        
    else % Experiment is not Feedback2/3
        subjects = explvl.Subject;
        errors = explvl.errorCount;
    end
    
    % we only want the first 50 trials
    triallvl(triallvl.TrialID > 50, :) = [];
    feedback = [];
    
    for i = 1:length(subjects)
        fb = triallvl.timeOnFeaturesp4(triallvl.Subject == subjects(i)); %total time subject looked at feature in p4
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