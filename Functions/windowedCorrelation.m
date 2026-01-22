function [correlations, windowCenters] = windowedCorrelation(data1, data2, windowSize, stepSize,would_norm)
    % Check that data1 and data2 have the same length
    if length(data1) ~= length(data2)
        error('The input data series must be of the same length.');
    end

    % Number of data points
    n = length(data1);
    
    % Initialize the output
    correlations = [];
    windowCenters = [];

    % Loop over the data with the specified window size and step size
    for startIdx = 1:stepSize:(n - windowSize + 1)
        endIdx = startIdx + windowSize - 1;
        
        % Extract the current window of data
        windowData1 = data1(startIdx:endIdx);
        windowData2 = data2(startIdx:endIdx);
        
        % Compute the correlation coefficient for the current window
        corrCoeff= sum(windowData1 .* windowData2); 
        % Other measures
        %corrCoeff= sqrt(sum((windowData1 - windowData2).^2));  
        %corrCoeff=  dot(windowData1, windowData2) / (norm(windowData1) * norm(windowData2)); 
        %corrCoeff= corr(windowData1, windowData2); 
        %corrCoeff=dtw(windowData1, windowData2);

        % Store the correlation and the center of the window
        correlations = [correlations; corrCoeff];
        windowCenters = [windowCenters; (startIdx + endIdx) / 2];
    end
     
    if would_norm==1 %1 to normalize wrt to the max val
        max_corr = max(correlations); 
        correlations = correlations / max_corr;
    end
end
