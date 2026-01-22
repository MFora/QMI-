clc
clear
close all

addpath("Functions\")
addpath("Data")

% % % % %==========================================================================
% Labels
% % % % %==========================================================================
% Some outcomes for each individual speparetly 
Labels=load('Labels.mat');
Labels=Labels.Labels;

% Group the subjects into dyads 
result = groupsummary(Labels, 'id', 'sum', 'QMI_TOT'); 

% Outcome for all participants 
Y= result.sum_QMI_TOT;

% Binarize the outcome 
Y(find(result.sum_QMI_TOT <80))= 0;
Y(find(result.sum_QMI_TOT >=80))=1;

% The dyad ID
Y_id=result.id;

% % % % %==========================================================================

from=[1001,1101,1201,1301]; %from to, related to the file names 
to=[1100,1196,1296,1482];
fs=40e-3; %Frame rate in seconds 

% Have at least one minute available 
threshold= 60; % in seconds 
thLim= floor(threshold/fs); %in number of samples

CNT=1; %counter 
CNTth= 1;

% T: All available data
T = table(0, 0, 0, ...  
    'VariableNames', {'ID', 'maleDuration', 'femaleDuration'});
% Tth: An initial screening step. 
% During preprocessing, only dyads with valid data from both partners that were temporally synchronized were retained for subsequent analysis
Tth = table(0, 0, 0,0,0,0, ... 
    'VariableNames', {'ID', 'maleDuration', 'femaleDuration','malePercent','femalePercent','Dyadlabel'});

for f=1:4 % The data are separated into four .mat files
    %Loading the data
    file= "data_"+string(from(f))+"_"+string(to(f))+".mat";
    load(file)
    male_id=unique(male.Respondent); %unique male ID for specific table

    for i=1:length (male_id)
        p_num=male_id(i);
        % Step 1: Subtables
        p1001=[]; p1002=[];
        p1001=male(male.Respondent==p_num,:); %table for specific male 
        p1002=female(female.Respondent==p_num+1,:); %table for the female   
        
        [Lmale,~]=size(p1001); %No. of samples
        [Lfemale,~]=size(p1002);

        T.ID(CNT)= string(p_num)+string(p_num+1);
        T.maleDuration(CNT)= Lmale;
        T.femaleDuration(CNT)= Lfemale;

        if Lmale>= thLim & Lfemale>=thLim
            % Both subjects have more than the available time, including zero values
            Tth.ID(CNTth)= string(p_num)+string(p_num+1);
            Tth.maleDuration(CNTth)= (Lmale*fs)/60;
            Tth.femaleDuration(CNTth)= (Lfemale*fs)/60;
            Tth.malePercent(CNTth)=percentZeros(p1001);
            Tth.femalePercent(CNTth)=percentZeros(p1002);
            IDX=find (Y_id==str2double(string(p_num)+string(p_num+1)));
            Tth.Dyadlabel(CNTth)= Y(IDX);

            CNTth= CNTth+1;
            
            %%% Visulization; not recommended for large loops 
            % figure
            % for iii= 6:11
            %     subplot(6,1,iii-5)
            %     plot(table2array(p1001(:,iii)))
            % end
            % sgtitle(string(p_num)+ ' %zeros= '+ string(percentZeros(p1001))) 
            
        end

        CNT= CNT+1;
    end
end

% % writetable(Tth, 'Dyadic_Sample_Data_Quality_and_Labels.csv')




