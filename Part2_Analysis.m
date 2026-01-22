clc
clear
close all

addpath("Functions\")
addpath("Data")

% % % % %==========================================================================
% % % % %% Labels
% % % % %==========================================================================
Labels=load('Labels.mat'); 
Labels=Labels.Labels;
result = groupsummary(Labels, 'id', 'sum', 'QMI_TOT'); 
scores=result.sum_QMI_TOT;
Y= result.sum_QMI_TOT;
Y(find(result.sum_QMI_TOT <80))= 0;
Y(find(result.sum_QMI_TOT >=80))=1;
Y_id=result.id;

%==========================================================================
% Indecies used for analysis based on T_intersect table 
emotions_ids1=[16:35]; %male AU
emotions_ids2=[54:73]; %female AU
n=length(emotions_ids1);

%==========================================================================
from=[1001,1101,1201,1301]; %from to, related to the file names 
to=[1100,1196,1296,1482];
fs=40e-3; %Frame rate in seconds

thLim= 60; % in seconds 
thLim= floor(thLim/fs); %in number of samples
length_ofAvailable_Data=[];

CNT=1; %counter 
labels_feat=[]; %binarized outcome 
labels_num=[]; %outcome numerical value 
maleID=[];
dyad_list=[];

for f=1:4 
    %Loading the data
    file= "data_"+string(from(f))+"_"+string(to(f))+".mat";
    load(file)
    male_id=unique(male.Respondent); %unique male ID for specific table

    for i=1:length (male_id)
        p_num=male_id(i);
        % Step 1: Subtables
        p1001=male(male.Respondent==p_num,:); %table for specific male 
        p1002=female(female.Respondent==p_num+1,:); %table for the female   
        
        % Step 2: Filter data with zeros rows
        p1001_filtered=[]; p1002_filtered=[];
        [p1001_filtered,p1002_filtered]= filterData(p1001, p1002);
        
        % Step 3: The intersection between male and female (synchronization)
        T_intersect = innerjoin(p1001_filtered, p1002_filtered, 'Keys', 'Timestamp');
        check_empty=table2array(T_intersect);
        [r,c]= size(check_empty);
        
        if  (r>=thLim) 
            length_ofAvailable_Data(CNT,1)=r; 
            d=find (Y_id==str2double(string(p_num)+string(p_num+1)));
            dyad_list=[dyad_list, str2double(string(p_num)+string(p_num+1))];
            L= Y(d);
            labels_feat(CNT,1)=L;
            labels_num(CNT,1)=scores(d);

            
        S=[];res=[];
            for s=1:length(emotions_ids1) %for each signal (emotion or AU)
                seg1=[]; seg2=[]; 
                seg1= T_intersect(:,emotions_ids1(s));
                seg1= table2array(seg1);
                seg2= T_intersect(:,emotions_ids2(s));
                seg2= table2array(seg2); 
                seg1=seg1(1:thLim);
                seg2=seg2(1:thLim);


                % Synchrony measurement 
                correlations=[];        
                [correlations, windowCenters] = windowedCorrelation(seg1, seg2,1000,100,0);
                S(:,s)=correlations; 

                % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
                % % % % % % % % % BaseLine % % % % % % % % %
                % % % %                         S (1, s)= mean (seg1);  
                % % % %                         S (2, s)= std (seg1);  
                % % % %                         S (3, s)= max (seg1);  
                % % % %                         S (4, s)= min (seg1);  
                % % % %                         S (5, s)= kurtosis (seg1); 
                % % % %                         S (6, s)= skewness (seg1);  
                % % % %                   
                % % % %                         S (7,  s)= mean (seg2);  
                % % % %                         S (8, s)= std (seg2);  
                % % % %                         S (9, s)= max (seg2);  
                % % % %                         S (10, s)= min (seg2);  
                % % % %                         S (11, s)= kurtosis (seg2); 
                % % % %                         S (12, s)= skewness (seg2);  
                % % % % 
                % % % %                         S (13, s)= sum (seg1);        
                % % % %                         S (14, s)= sum (seg2);   
                
                % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
                        
               
           
            end
        %%Use this for the statistical features
        %%SS= normalize(S,2,'zscore'); S_mat{CNT}=SS;

        S_mat{CNT}=S;
        maleID(CNT,1)= p_num; 
        CNT=CNT+1;
        end
    end
end


%%%  Visualize the Dyads' Synchrony profiles 
figure 
for i= 1:27
    subplot (6,5,i)
    contourf (S_mat{i})
    title (num2str(labels_feat(i)))
end


%==========================================================================
% Similarity - Dissimilarity measures 
%==========================================================================
flattened_matrices = cellfun(@(x) x(:), S_mat, 'UniformOutput', false);
flattened_matrices = cell2mat(flattened_matrices);
D = pdist(flattened_matrices', 'euclidean'); % Using Euclidean distance
distance_matrix = squareform(D);
coordinates_2D = mdscale(distance_matrix, 2);

figure;
scatter(coordinates_2D(:,1), coordinates_2D(:,2));
title('2D MDS Plot');
xlabel('Dimension 1');
ylabel('Dimension 2');
text(coordinates_2D(:,1), coordinates_2D(:,2), num2str(labels_feat));
% From this output, by visual inspection you will be able to see the emergent groups
% pattern of the synchrony propfile of dyads even wihtout using any
% clustering technique. To make it full automated and unsupervised pipeline we used extra clustering method  

%==========================================================================
% Clustering using K-means
%==========================================================================
k = 2;
rng(10)
[idx, C] = kmeans(coordinates_2D, k);

figure;
subplot (2,1,1)
hold on
gscatter(coordinates_2D(:,1), coordinates_2D(:,2), labels_feat, 'bgm'); 
legend ('off')
plot(C(:,1), C(:,2), 'kx', 'MarkerSize', 15, 'LineWidth', 3);  % Centroids
xlabel('X');
ylabel('Y');
title('True Labels');
hold off;
text(coordinates_2D(:,1), coordinates_2D(:,2),  num2str(labels_feat));

subplot (2,1,2)
hold on
gscatter(coordinates_2D(:,1), coordinates_2D(:,2), idx, 'bgm');
legend ('off')
plot(C(:,1), C(:,2), 'kx', 'MarkerSize', 15, 'LineWidth', 3);  % Centroids
xlabel('X');
ylabel('Y');
title('K-means Clustering Labels'); 
hold off;
text(coordinates_2D(:,1), coordinates_2D(:,2),  num2str(idx));

%==========================================================================
% Validation
%==========================================================================
% I
idx(idx==2)=0;
mean(labels_feat==idx)
% II
confusionmat(labels_feat, idx)
% III 
figure
[svalue h]= silhouette(coordinates_2D,idx);
mean(svalue)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visulaization 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% x = 1:length(dyad_list);                 
% y = length_ofAvailable_Data * 0.04;      
% stem(x, y, 'filled')
% 
% xlabel('Dyad ID', ...
%        'FontSize', 16, ...
%        'FontWeight', 'bold')
% 
% ylabel('Available Synchronized Data (s)', ...
%        'FontSize', 16, ...
%        'FontWeight', 'bold')
% 
% 
% xticks(x)
% xticklabels(string(dyad_list))
% xtickangle(45)   
