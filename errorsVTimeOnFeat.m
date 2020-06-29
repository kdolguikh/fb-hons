%% # errors and time on features during fb

% correlation bw total errors (experiment) and time on features during
% feedback on first 50 trials 

% Reviewed: 
% Verified:

% Reviewer Notes:
% I've added feedback duration as an optional argument to handle our use cases.
% FB2/3 produce unequal amounts of errors to feedbacks which causes an
% error in the correlation function. Works fine on sshrcif however.
% I've put some code that'll output those values onto the console for
% debugging.

function [r, p] = errorsVTimeOnFeat(experiment, feedbackDuration)

    directory = 'C:/Users/16132/Documents/lab/feedback/KAT/';
    addpath('C:/Users/16132/Documents/lab/feedback/fb-hons');  % for subjTableHack
    load(strcat(directory, '/', experiment, '/triallvl.mat'));
    load(strcat(directory, '/', experiment, '/explvl.mat'));
    
    % we are looking at time spent on stimulus features during feedback
    timeOnFeatures = subjTableHack(experiment, 'p4feature');
    triallvl.timeOnFeaturesp4 = timeOnFeatures(:, 2);
    
    % eliminate random responders
    explvl(explvl.Random == 1, :) = [];
    
    %% Handling for 1 sec or 9 sec people in feedback 2/3
    if strcmp(experiment, "Feedback2") || strcmp(experiment, "Feedback3")
        if ~exist('feedbackDuration','var')
            error('Feedback duration(ms) is a required argument for this experiment.');
            return;
        end

        if feedbackDuration == 1000
            subjects = explvl.Subject(explvl.FeedbackDuration == 1000);
        elseif feedbackDuration == 9000
            subjects = explvl.Subject(explvl.FeedbackDuration == 9000);
        else
            error('Inputted feedback duration not implemented in this function.');
            return;
        end
        
    else % Experiment is not Feedback2/3
        subjects = explvl.Subject;
    end
    
    errors = explvl.errorCount;
    
    % we only want the first 50 trials
    triallvl(triallvl.TrialID > 50, :) = [];
    feedback = [];
    
    for i = 1:length(subjects)
        fb = triallvl.timeOnFeaturesp4(triallvl.Subject == subjects(i)); %total time subject looked at feature in p4
        feedback = [feedback; nanmean(fb)];
    end
    
    
    numErrors = length(errors);
    numFeedbk = length(feedback);
    if numErrors ~= numFeedbk
        dispE = ['Errors Length: ', num2str(length(errors))];
        dispF = ['Feedback Length: ', num2str(length(feedback))];
        disp('--Before Removal--');
        disp(dispE);
        disp(dispF);
    end
    
    % check for & delete any NaN values in feedback (the corr function
    % seems to not be able to handle NaNs)
    toRemove = isnan(feedback);
    feedback(toRemove) = [];
    errors(toRemove) = [];
    
   if numErrors ~= numFeedbk
        dispE = ['Errors Length: ', num2str(length(errors))];
        dispF = ['Feedback Length: ', num2str(length(feedback))];
        disp('--After Removal--');
        disp(dispE);
        disp(dispF);
   end
    
    [r, p] = corr(errors, feedback);
    scatter(errors, feedback);

end