function [percentageZeros] = percentZeros(T)
 
    %Input:
        %T: the table that you need to check the precentage of zeros  
    % Output:
        %percentageZeros: percentage of zero lines from the overall data
        
    zeros = T.Anger == 0 & T.Joy == 0 & ...
    T.Contempt  == 0 & T.Fear == 0 & T.Sadness == 0 &...
    T.Surprise == 0 & T.Engagement == 0 & T.Disgust == 0;
    
    %if all emotions are zerors (which are based on AU calculations) then
    %consider this row as zero row 

    T_Zeros= T(zeros, :);
    
    [lengthZeros,~]=size(T_Zeros);
    [lengthTotal,~]=size(T);
    percentageZeros= 100*(lengthZeros/lengthTotal);
    percentageZeros= round(percentageZeros,1);

end