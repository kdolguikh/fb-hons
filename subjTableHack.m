%Cognitive Science Lab, Simon Fraser University
%Author: Kat Dolguikh
%Date: Jan 24 2019
%Last Edit: april 6 I THINK WORKS

% originally created for: FEEDBACK

%% my gnarly hack since i don't have SQL right now


function data = subjTableHack(experiment, measure, varargin)

    direc = strcat('Users/16132/Documents/lab/KAT/', experiment);

    load(strcat(direc, '/explvl.mat'));
    load(strcat(direc, '/triallvl.mat'));
    load(strcat(direc, '/fixlvl.mat'));
    
    % eliminate ITI fixations (this is a bug we found a while back resulting from lag, or something)
    if strcmp(experiment, 'Feedback2')||strcmp(experiment, 'Feedback3')
        fixlvl = fixlvl(fixlvl.ITI == 0, :);
    end

    subjects = explvl.Subject;

%% THIS IS MY  GNARLY SUBSTITUTE
switch measure

    case 'cond'   
        data = [subjects, explvl.FeedbackDuration];     % note format
        
    case 'cp' 
        data = [subjects, explvl.CP];   % note format
        
    case 'rt2'      % pull straight from trial lvl
        response = [];
        sub = [];
        for i = 1:length(subjects)
           current = subjects(i); 
           filtered = triallvl.Phase2RT(triallvl.Subject == current);
           this = triallvl.Subject(triallvl.Subject == current);
           sub = [sub; this];
           response = [response; filtered]; 
        end
        data = [sub, response];
        
    case 'rt4'  % pull straight from trial lvl
        response = [];
        sub = [];
        for i = 1:length(subjects)
           current = subjects(i); 
           filtered = triallvl.Phase4RT(triallvl.Subject == current);
           this = triallvl.Subject(triallvl.Subject == current);
           sub = [sub; this];
           response = [response; filtered]; 
        end
        data = [sub, response];
        
    case 'accuracy'     % pull straight from trial lvl
        acc = [];
        sub = [];
        for i = 1:length(subjects)
           current = subjects(i); 
           filtered = triallvl.TrialAccuracy(triallvl.Subject == current);
           this = triallvl.Subject(triallvl.Subject == current);
           sub = [sub; this];
           acc = [acc; filtered]; 
        end
        data = [sub, acc];
        
    case 'durp2'   % fixation time ON FEATURES (average)
        
        sub = [];
        dur = [];
        
        for i = 1:length(subjects)
           current = subjects(i);
           thisSub = fixlvl(fixlvl.Subject == current, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == current));
           
           for j = 1:maxTrial% for every trial for the current subject, find all fixations with funcRelevance = 1, 2, or 3
               thisTrial = thisSub(thisSub.TrialID == j, :);
               p2 = thisTrial(thisTrial.TrialPhase == 2, :);
               p2 = p2.Duration(p2.funcRelevance > 0 & p2.funcRelevance < 4);
               if isempty(p2)   % if there are none, pad with a NaN
                   meandur = NaN;
               else
                   meandur = nanmean(p2);
               end
               sub = [sub; current];
               dur = [dur; meandur];
           end
                    
        end
        data = [sub, dur];
        
    case 'durp4'        % same as above but p4 instead of p2
        
        sub = [];
        dur = [];
        
        for i = 1:length(subjects)
           current = subjects(i);
           thisSub = fixlvl(fixlvl.Subject == current, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == current));
           
           for j = 1:maxTrial
               thisTrial = thisSub(thisSub.TrialID == j, :);
               p4 = thisTrial(thisTrial.TrialPhase == 4, :);
               p4 = p4.Duration(p4.funcRelevance > 0 & p4.funcRelevance < 4);
               if isempty(p4)
                   meandur = NaN;
               else
                   meandur = nanmean(p4);
               end
               sub = [sub; current];
               dur = [dur; meandur];
           end
            
           
        end
        data = [sub, dur];
        
    case 'fc2'      % same as above, but counnt using length() instead of taking a mean
        
        sub = [];
        fc = [];
        
        for i = 1:length(subjects)
           current = subjects(i);
           thisSub = fixlvl(fixlvl.Subject == current, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == current));
           
           for j = 1:maxTrial
               thisTrial = thisSub(thisSub.TrialID == j, :);
               p2 = thisTrial(thisTrial.TrialPhase == 2, :);
               p2 = p2.Duration(p2.funcRelevance > 0 & p2.funcRelevance < 4);
               if isempty(p2)
                   fc2 = 0;
               else
                   fc2 = length(p2);
               end
               sub = [sub; current];
               fc = [fc; fc2];
           end
           
            
        end
        data = [sub, fc];
        
    case 'fc4'      % same as above, but p4 instead of p2
        
        sub = [];
        fc = [];
        
        for i = 1:length(subjects)
           current = subjects(i);
           thisSub = fixlvl(fixlvl.Subject == current, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == current));
           
           for j = 1:maxTrial
               thisTrial = thisSub(thisSub.TrialID == j, :);
               p4 = thisTrial(thisTrial.TrialPhase == 4, :);
               p4 = p4.Duration(p4.funcRelevance > 0 & p4.funcRelevance < 4);
               if isempty(p4)
                   fc4 = 0;
               else
                   fc4 = length(p4);
               end
               sub = [sub; current];
               fc = [fc; fc4];
           end
           
            
        end
        data = [sub, fc];
        

    case 'irrel2'   % time on irrelevant features in p2
        
        sub = [];
        irrel = [];
        
        for i = 1:length(subjects)  % same as dur2, except only for funcRelevance = 3
           current = subjects(i);
           thisSub = fixlvl(fixlvl.Subject == current, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == current));
           
           for j = 1:maxTrial
               thisTrial = thisSub(thisSub.TrialID == j, :);
               p2 = thisTrial(thisTrial.TrialPhase == 2, :);
               p2 = p2.Duration(p2.funcRelevance == 3);
               if isempty(p2)
                   meandur = NaN;
               else
                   meandur = nanmean(p2);
               end
               sub = [sub; current];
               irrel = [irrel; meandur];
           end
          
            
        end
        data = [sub, irrel];
        
    case 'irrel4'   % same as above, just p4 instead of p2
        
        sub = [];
        irrel = [];
        
        for i = 1:length(subjects)
           current = subjects(i);
           thisSub = fixlvl(fixlvl.Subject == current, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == current));
           
           for j = 1:maxTrial
               thisTrial = thisSub(thisSub.TrialID == j, :);
               p4 = thisTrial(thisTrial.TrialPhase == 4, :);
               p4 = p4.Duration(p4.funcRelevance == 3);
               if isempty(p4)
                   meandur = NaN;
               else
                   meandur = nanmean(p4);
               end
               sub = [sub; current];
               irrel = [irrel; meandur];
           end
          
            
        end
        data = [sub, irrel];
        
    case 'opt'        % pulled the calculation straight from gnarly. 
                        % this is optimization during p2
        sub = [];
        opt = [];
        
        for i = 1:length(subjects)
           current = subjects(i);
           thisSub = fixlvl(fixlvl.Subject == current, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == current));
           
           for j = 1:maxTrial
               thisTrial = thisSub(thisSub.TrialID == j, :);
               p2 = thisTrial(thisTrial.TrialPhase == 2, :);
               if isempty(p2)
                   optimization = NaN;  % no p2 value means we can't calculate opt
               else
                      relevant = p2.Duration(p2.funcRelevance == 1 | p2.funcRelevance == 2);
                      irrelevant = p2.Duration(p2.funcRelevance == 3);

                      relevant = nansum(relevant)/2;    
                      irrelevant = nansum(irrelevant);

                      optimization = (relevant - irrelevant)/(relevant + irrelevant);
               end
               
               sub = [sub; current];
               opt = [opt; optimization];
               
           end
            
        end
        
        data = [sub, opt];
        
    case 'opt4'             % same as above, just p4 instead of p2
        
        sub = [];
        opt = [];
        
        for i = 1:length(subjects)
           current = subjects(i);
           thisSub = fixlvl(fixlvl.Subject == current, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == current));
           
           for j = 1:maxTrial
               thisTrial = thisSub(thisSub.TrialID == j, :);
               p4 = thisTrial(thisTrial.TrialPhase == 4, :);
               if isempty(p4)
                   optimization = NaN;
               else
                      relevant = p4.Duration(p4.funcRelevance == 1 | p4.funcRelevance == 2);
                      irrelevant = p4.Duration(p4.funcRelevance == 3);

                      relevant = nansum(relevant)/2;
                      irrelevant = nansum(irrelevant);

                      optimization = (relevant - irrelevant)/(relevant + irrelevant);
               end
               
               sub = [sub; current];
               opt = [opt; optimization];
               
           end
            
        end
        
        data = [sub, opt];
        
    case 'p4button'     % similar to time on irrel
        
        sub = [];
        button = [];
        
        for i = 1:length(subjects)
           current = subjects(i);
           thisSub = fixlvl(fixlvl.Subject == current, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == current));
           
           for j = 1:maxTrial
               thisTrial = thisSub(thisSub.TrialID == j, :);
               p4 = thisTrial(thisTrial.TrialPhase == 4, :);
               p4 = p4.Duration(p4.funcRelevance > 3);    % p4 now contains durations of all p4 fixations to buttons
               if isempty(p4)
                   timeonfb = NaN;
               else
                   timeonfb = nansum(p4);   % sum for total time on buttons on this trial
               end
               sub = [sub; current];
               button = [button; timeonfb];
           end
          
            
        end
        data = [sub, button];
        
    case 'p4feature'        % same as above but features instead of buttons (funcRel = 1, 2, or 3)
        
        sub = [];
        stim = [];
        
        for i = 1:length(subjects)
           current = subjects(i);
           thisSub = fixlvl(fixlvl.Subject == current, :);
           maxTrial = max(triallvl.TrialID(triallvl.Subject == current));
           
           for j = 1:maxTrial
               thisTrial = thisSub(thisSub.TrialID == j, :);
               p4 = thisTrial(thisTrial.TrialPhase == 4, :);
               p4 = p4.Duration(p4.funcRelevance < 4 & p4.funcRelevance > 0);
               if isempty(p4)
                   timeonfb = NaN;
               else
                   timeonfb = nansum(p4);
               end
               sub = [sub; current];
               stim = [stim; timeonfb];
           end
          
            
        end
        data = [sub, stim];
          
end

end