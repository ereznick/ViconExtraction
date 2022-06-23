%Save Vicon Data Into Matlab Struct
%VICON EXTRACTION MASTER

%Emma Reznick 2021
%Emma Reznick 2022
%Updates:
%-added subject details
%-added AMTI and Kistler Force Plates
%-gloabal CoP

%% Connect to Vicon Nexus
addpath('C:\Program Files (x86)\Vicon\Nexus2.12\SDK\Matlab')
addpath('C:\Program Files (x86)\Vicon\Nexus2.12\SDK\Win64')
vicon = ViconNexus;

structureName = input('Structure Name:','s');

[trial,data_path] = uigetfile('*.x1d',...
    'Select One or More Files', ...
    'MultiSelect', 'on');

targetPath = pwd;%pwd'C:\Users\hframe\Desktop\HoppingData'; %%FILL IN

%Select Desired Trials
bool_FP = true;
bool_marker = true;
bool_Jangle = true;
bool_Jvel = true;
bool_Jmom = true;
bool_Jforce = true;
bool_Jpow = true;
bool_event = true;
bool_subDet = true;

%Loop Through Trials
if iscell(trial)
    trialNum = numel(trial);
else
    trialNum = 1;
end

%Loop Through Trials
if iscell(trial)
    trialNum = numel(trial);
else
    trialNum = 1;
end

for t = 1:trialNum
    %Check for multiple subjects
    [subject, ~, active] = vicon.GetSubjectInfo;
    for s = 1:numel(subject)
        %check to see if subject is checked
        if ~active(s)
            continue
        end
        
        try
            trialName = trial{t}(1:end-4);
        catch
            trialName = trial(1:end-4);
        end
        trialPath = [data_path, trialName];
        disp(['Opening ' trialName])
        vicon.OpenTrial(trialPath,30)
        trialNameClean = trialName(find(~isspace(trialName)));
        
        
 %% Raw Data
        if bool_FP
            try
                Data.(trialNameClean).(subject{s}).ForcePlate = PullForcePlateViconFRB(vicon);
                disp('    Force Plates Collected')
            catch
                disp('    No FP Data')
            end
            
        end
        if bool_marker
            try
                Data.(trialNameClean).(subject{s}).Markers = PullMarkerViconFRB(vicon, subject{s});
                disp('    Markers Collected')
            catch
                disp('    No Marker Data')
            end
        end
        %% Modeled Kinematics
        if bool_Jangle
            try
                Data.(trialNameClean).(subject{s}).JointAngle = PullJointAngleViconFRB(vicon, subject{s});
                disp('    Joint Angles Collected')
            catch
                disp('    No Joint Angle Data')
            end
        end
        if bool_Jvel
            try
                Data.(trialNameClean).(subject{s}).JointVelocity = PullJointVelocityViconFRB(vicon, subject{s});
                disp('    Joint Velocity Collected')
            catch
                disp('    No Joint Velocity Data')
            end
        end
        
        %% Modeled Kinetics
        if bool_Jmom
            try
                Data.(trialNameClean).(subject{s}).JointMoment = PullJointMomentViconFRB(vicon, subject{s});
                disp('    Joint Moments Collected')
            catch
                disp('    No Joint Moment Data')
            end
        end
        if bool_Jforce
            try
                Data.(trialNameClean).(subject{s}).JointForce = PullJointForceViconFRB(vicon, subject{s});
                disp('    Joint Forces Collected')
            catch
                disp('    No Joint Force Data')
            end
        end
        if bool_Jpow
            try
                Data.(trialNameClean).(subject{s}).JointPower = PullJointPowerViconFRB(vicon, subject{s});
                disp('    Joint Powers Collected')
            catch
                disp('    No Joint Power Data')
            end
        end
        
        %% Misc Data
        if bool_event
            %if you want to add other events, input the name as a third argument as a string
            try
                Data.(trialNameClean).(subject{s}).Events = PullEventsViconFRB(vicon, subject{s}, 'hopStart');
                disp('    Events Collected')
            catch
                disp('    No Events Data')
            end
        end
        if bool_subDet
            try
                Data.(trialNameClean).(subject{s}).SubjectDetails = PullSubjectDetailsViconFRB(vicon, subject{s});
                disp('    Subject Details Collected')
            catch
                disp('    No Subject Details')
            end
        end
    end
end
cd(targetPath);
eval([structureName ' = Data;']);
clear Data
save(structureName,structureName,'-v7.3')
disp('Mischief Managed')