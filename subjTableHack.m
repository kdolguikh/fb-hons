    %  Author: Kat 
    %  Date Created: Jan 24 /20
    %  Last Edit: Apr 6 
     
    %  Cognitive Science Lab, Simon Fraser University 
    %  Originally Created For: feedback
      
    %  Reviewed: Tyrus Tracey [2020-Jun-07]
    %  Verified: 
 
    %  PURPOSE: 
        % Gnarly-style data extraction from saved .mat TrialLvl and FixLvl
        % tables. Used in 2020 COVID-19 quarantine to complete work from
        % home (aka without SQL connectors)
 
    
    %  INPUT: 
    
%       experiment: experiment name

%       measure: what data are we looking for. the currentSubject options are
%        only measures I needed for my honours project that were not attainable 
%        in a more direct way. In the future, if we hope to use something like 
%        this, it should probably be expanded.
%        measure options:
%         'cond': 
%           condition, only relevant for feedback2 and feedback3 
%           (9 sec or 1 sec feedback condition). One row per participant
%         'cp': 
%           subject's CP (first of 24 in a row correct trials) 
%           aka point at which we can say they learned. One row per participant.
%         'rt2': 
%           phase 2 duration aka how long stimulus was onscreen before 
%           participant made a category selection. One row per trial per participant.
%         'rt4': 
%           phase 4 duration aka how long feedback was onscreen before 
%           participant moved on to next trial. One row per trial per participant. 
%         'accuracy': 
%           1 if participant answered correctly, 0 if they answered incorrectly. 
%           One row per trial per participant. 
%         'durp2': 
%           mean duration of phase 2 fixations to features (funcRelevance 1, 2, or 3) 
%           One row per trial per participant
%         'durp4': 
%           mean duration of phase 4 fixations to features (funcRelevance 1, 2, or 3)
%           One row per trial per participant
%         'fc2': 
%           number of phase 2 fixations to features (funcRelevance 1, 2, or 3)
%           one row per trial per participant
%         'fc4': 
%           number of phase 4 fixations to features (funcRelevance 1, 2, or 3) 
%           one row per trial per participant
%         'irrel2': 
%           number of phase 2 fixations to irrrelevant feature (funcRelevance = 3)
%           one row per trial per participant
%         'irrel4': 
%           number of phase 4 fixations to irrrelevant feature (funcRelevance = 3)
%           one row per trial per participant
%         'opt': 
%           gaze optimization during phase 2. one row per trial per participant.
%         'opt4': 
%             gaze optimization during phase 4. one row per trial per participant.
%         'p4button': 
%           time fixating feedback buttons(funcRelevance 4, 5, 6, or 7) during phase 4. 
%           one row per trial per participant.
%         'p4feature': 
%           time fixating stimulus features (funcRelevance 1, 2, or 3) during phase 4. 
%           one row per trial per participant. 


    
    %  OUTPUT: depending on measure, either 2xn table where n = number of
    %  subjects in experiment or 2xtn table where t = number of trials, n =
    %  number of subjects. first column is subject number, second column is
    %  measure value.
    
    %  Additional Scripts Used: 
    
    
    %  Additional Comments: for each measure here, I list the Gnarly script (with args) that I
        % was intending to replicate. all of Gnarly can be found at:
        % Analyses/General/Gnarly. Then most of the scripts you will need to look
        % at will be in the DataExtractor folder. 


% originally created for: FEEDBACK



function data = subjTableHack(experiment, measure)

    % this is where the data is stored on kat's computer

    direc = strcat('Users/16132/Documents/lab/KAT/', experiment);

    load(strcat(direc, '/explvl.mat'));
    load(strcat(direc, '/triallvl.mat'));
    load(strcat(direc, '/fixlvl.mat'));
    
    % eliminate ITI fixations (this is a bug we found a while back resulting from lag, or something)
    if strcmp(experiment, 'Feedback2')||strcmp(experiment, 'Feedback3')
        fixlvl = fixlvl(fixlvl.ITI == 0, :);
    end

    subjects = explvl.Subject;

switch measure

    case 'cond'   
        % don't worry about gnarly for this one, we literally just want
        % each subject and their condition
        data = [subjects, explvl.FeedbackDuration];   
        
    case 'cp' 
        % don't worry about gnarly for this one, we literally just want
        % each subject and their CP
        data = [subjects, explvl.CP];   
        
    case 'rt2'      
        s% pull straight from trial lvl
        % Gnarly: RTExtractor (phase 2)
        response = [];
        sub = [];
        for i = 1:length(subjects)
           currentSubject = subjects(i); 
           filtered = triallvl.Phase2RT(triallvl.Subject == currentSubject);
           this = triallvl.Subject(triallvl.Subject == currentSubject);
           sub = [sub; this];
           response = [response; filtered]; 
        end
        data = [sub, response];
        
    case 'rt4'  
        % pull straight from trial lvl
        response = [];
        sub = [];
        for i = 1:length(subjects)
           currentSubject = subjects(i); 
           filtered = triallvl.Phase4RT(triallvl.Subject == currentSubject);
           this = triallvl.Subject(triallvl.Subject == currentSubject);
           sub = [sub; this];
           response = [response; filtered]; 
        end
        data = [sub, response];
        
    case 'accuracy'     % pull straight from trial lvl
        acc = [];
        sub = [];
        for i = 1:length(subjects)
           currentSubject = subjects(i); 
           % similar to p2, p4 rt, accuracy is just a column in trial lvl
           filtered = triallvl.TrialAccuracy(triallvl.Subject == currentSubject);
           this = triallvl.Subject(triallvl.Subject == currentSubject);
           sub = [sub; this];
           acc = [acc; filtered]; 
        end
        data = [sub, acc];
        
    case 'durp2'
        % fixation time ON FEATURES (average)
        % for this measure, we want the mean duration of all fixations to
        % stimulus features for each trial (funcRelevance = 1, 2, or 3)
        
        % Gnarly: MeanTimeOnFeatures, phase 2, 'all3' (so the means are not separated by feature)
        sub = [];
        dur = [];
        
        for i = 1:length(subjects)
           currentSubject = subjects(i);
           currentFixations = fixlvl(fixlvl.Subject == currentSubject, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == currentSubject));
           
           for j = 1:maxTrial
               currentTrial = currentFixations(currentFixations.TrialID == j, :);
               p2 = currentTrial(currentTrial.TrialPhase == 2, :);
               p2 = p2.Duration(p2.funcRelevance > 0 & p2.funcRelevance < 4);
               if isempty(p2)  
                   % if there are none, pad with a NaN
                   meandur = NaN;
               else
                   meandur = nanmean(p2);
               end
               sub = [sub; currentSubject];
               dur = [dur; meandur];
           end
                    
        end
        data = [sub, dur];
        
    case 'durp4'
        % same as above but p4 instead of p2
        % Gnarly: MeanTimeOnFeatures, phase 4, 'all3'
        sub = [];
        dur = [];
        
        for i = 1:length(subjects)
           currentSubject = subjects(i);
           currentFixations = fixlvl(fixlvl.Subject == currentSubject, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == currentSubject));
           
           for j = 1:maxTrial
               currentTrial = currentFixations(currentFixations.TrialID == j, :);
               p4 = currentTrial(currentTrial.TrialPhase == 4, :);
               p4 = p4.Duration(p4.funcRelevance > 0 & p4.funcRelevance < 4);
               if isempty(p4)
                   meandur = NaN;
               else
                   meandur = nanmean(p4);
               end
               sub = [sub; currentSubject];
               dur = [dur; meandur];
           end
            
           
        end
        data = [sub, dur];
        
    case 'fc2' 
        % same as above, but count using length() instead of nanmean()
        % to get number of fixations to features during p2 of each trial
        % fc2 will be the number of these fixations

        % Gnarly: FixationCountExtractor, phase 2, 'allinone'
        
        sub = [];
        fc = [];
        
        for i = 1:length(subjects)
           currentSubject = subjects(i);
           currentFixations = fixlvl(fixlvl.Subject == currentSubject, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == currentSubject));
           
           for j = 1:maxTrial
               currentTrial = currentFixations(currentFixations.TrialID == j, :);
               p2 = currentTrial(currentTrial.TrialPhase == 2, :);
               
               p2 = p2.Duration(p2.funcRelevance > 0 & p2.funcRelevance < 4);
               if isempty(p2)
                   % empty = length 0 = no fixations
                   fc2 = 0;
               else
                   fc2 = length(p2);
               end
               sub = [sub; currentSubject];
               fc = [fc; fc2];
           end
           
            
        end
        data = [sub, fc];
        
    case 'fc4'      
        % same as above, but p4 instead of p2
        
        % Gnarly: FixationCountExtractor, phase 4, 'allinone'
        sub = [];
        fc = [];
        
        for i = 1:length(subjects)
           currentSubject = subjects(i);
           currentFixations = fixlvl(fixlvl.Subject == currentSubject, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == currentSubject));
           
           for j = 1:maxTrial
               currentTrial = currentFixations(currentFixations.TrialID == j, :);
               p4 = currentTrial(currentTrial.TrialPhase == 4, :);
               p4 = p4.Duration(p4.funcRelevance > 0 & p4.funcRelevance < 4);
               if isempty(p4)
                   fc4 = 0;
               else
                   fc4 = length(p4);
               end
               sub = [sub; currentSubject];
               fc = [fc; fc4];
           end
           
            
        end
        data = [sub, fc];
        


    case 'irrel2'   
        % time spent on irrelevant features in p2 (funcRelevance == 3)
        
        % Gnarly: DurationExtractor, phase 2, 'relevance' column 3 (the
        % relevance argument separates data by funcrelevance and outputs
        % values for all 3 features...this measure here only cares about
        % the last one aka irrelevant)
        sub = [];
        irrel = [];
        
        for i = 1:length(subjects)  
           currentSubject = subjects(i);
           currentFixations = fixlvl(fixlvl.Subject == currentSubject, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == currentSubject));
           
           for j = 1:maxTrial
               % for each trial, we find all fixations to irrelevant
               % features (funcRelevance = 3) and take their sum to get the
               % total time spent looking at irrelevant features on that
               % trial
               currentTrial = currentFixations(currentFixations.TrialID == j, :);
               p2 = currentTrial(currentTrial.TrialPhase == 2, :);
               p2 = p2.Duration(p2.funcRelevance == 3);
               if isempty(p2)
                   currentIrrel = NaN;
               else
                   currentIrrel = nansum(p2);
               end
               sub = [sub; currentSubject];
               irrel = [irrel; currentIrrel];
           end
          
            
        end
        data = [sub, irrel];
        
    case 'irrel4'   
        % same as above, just p4 instead of p2
        
        % Gnarly: DurationExtractor, phase 4, 'relevance'
        
        sub = [];
        irrel = [];
        
        for i = 1:length(subjects)
           currentSubject = subjects(i);
           currentFixations = fixlvl(fixlvl.Subject == currentSubject, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == currentSubject));
           
           for j = 1:maxTrial
               currentTrial = currentFixations(currentFixations.TrialID == j, :);
               p4 = currentTrial(currentTrial.TrialPhase == 4, :);
               p4 = p4.Duration(p4.funcRelevance == 3);
               if isempty(p4)
                   currentIrrel = NaN;
               else
                   currentIrrel = nansum(p4);
               end
               sub = [sub; currentSubject];
               irrel = [irrel; currentIrrel];
           end
          
            
        end
        data = [sub, irrel];
        

    case 'opt2' 
        % pulled the calculation straight from gnarly. 
                        
        % Gnarly: OptimizationExtractor, phase 2, 
        sub = [];
        opt = [];
        
        for i = 1:length(subjects)
           currentSubject = subjects(i);
           currentFixations = fixlvl(fixlvl.Subject == currentSubject, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == currentSubject));
           
           for j = 1:maxTrial
               currentTrial = currentFixations(currentFixations.TrialID == j, :);
               p2 = currentTrial(currentTrial.TrialPhase == 2, :);
               if isempty(p2)
                   optimization = NaN;  % no p2 value means we can't calculate opt
               else
                      relevant = p2.Duration(p2.funcRelevance == 1 | p2.funcRelevance == 2);
                      irrelevant = p2.Duration(p2.funcRelevance == 3);
    
                      % we divide relevant by 2 here, since we have 2:1
                      % relevant to irrelevant feature ratio. 
                      % in optimization, we are looking for a
                      % measure that gives us: -1 if fixations are entirely
                      % to irrelevant features, 1 if fixations are entirely
                      % to relevant features, 0 if they occur at chance
                      % levels (i.e. 1/3 of the fixations to each of the
                      % features). 
                      relevant = nansum(relevant)/2;    
                      irrelevant = nansum(irrelevant);

                      % so opt is rel-irrel/modified total
                      optimization = (relevant - irrelevant)/(relevant + irrelevant);
               end
               
               sub = [sub; currentSubject];
               opt = [opt; optimization];
               
           end
            
        end
        
        data = [sub, opt];
        
    case 'opt4' 
        % same as above, just p4 instead of p2
        
        %Gnarly: OptimizationExtractor, phase 4
        sub = [];
        opt = [];
        
        for i = 1:length(subjects)
           currentSubject = subjects(i);
           currentFixations = fixlvl(fixlvl.Subject == currentSubject, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == currentSubject));
           
           for j = 1:maxTrial
               % this should be exactly the same as in 'opt', except using
               % TrialPhase == 4 instead of ==2
               currentTrial = currentFixations(currentFixations.TrialID == j, :);
               p4 = currentTrial(currentTrial.TrialPhase == 4, :);
               if isempty(p4)
                   optimization = NaN;
               else
                      relevant = p4.Duration(p4.funcRelevance == 1 | p4.funcRelevance == 2);
                      irrelevant = p4.Duration(p4.funcRelevance == 3);

                      relevant = nansum(relevant)/2;
                      irrelevant = nansum(irrelevant);

                      optimization = (relevant - irrelevant)/(relevant + irrelevant);
               end
               
               sub = [sub; currentSubject];
               opt = [opt; optimization];
               
           end
            
        end
        
        data = [sub, opt];
        
    case 'p4button'     
        % total time fixating on feedback buttons during phase 4 on each
        % trial (funcRelevance 4, 5, 6, 7)
        % Gnarly: DurationExtractor, phase 4, 'feedbackButtons3'
        
        sub = [];
        button = [];
        
        for i = 1:length(subjects)
           currentSubject = subjects(i);
           currentFixations = fixlvl(fixlvl.Subject == currentSubject, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == currentSubject));
           
           for j = 1:maxTrial
               currentTrial = currentFixations(currentFixations.TrialID == j, :);
               p4 = currentTrial(currentTrial.TrialPhase == 4, :);
               p4 = p4.Duration(p4.funcRelevance > 3);   
                % p4 now contains durations of all p4 fixations to buttons
               if isempty(p4)
                   timeonfb = NaN;
               else
                    % sum for total time on buttons on this trial
                   timeonfb = nansum(p4);  
               end
               sub = [sub; currentSubject];
               button = [button; timeonfb];
           end
          
            
        end
        data = [sub, button];
        
    case 'p4feature' 
        % same as above but features instead of buttons 
        % (funcRelevance 1, 2, 3)
        
        % DurationExtractor, phase 4, 'all3'
         
        sub = [];
        stim = [];
        
        for i = 1:length(subjects)
           currentSubject = subjects(i);
           currentFixations = fixlvl(fixlvl.Subject == currentSubject, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == currentSubject));
           
           for j = 1:maxTrial
               currentTrial = currentFixations(currentFixations.TrialID == j, :);
               p4 = currentTrial(currentTrial.TrialPhase == 4, :);
               p4 = p4.Duration(p4.funcRelevance < 4 & p4.funcRelevance > 0);
               if isempty(p4)
                   timeonfb = NaN;
               else
                   timeonfb = nansum(p4);
               end
               sub = [sub; currentSubject];
               stim = [stim; timeonfb];
           end
          
            
        end
        data = [sub, stim];
          
end

end