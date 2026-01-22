function [p1001_filtered,p1002_filtered] = filterData(p1001, p1002)

    %==========================================================================
    % Filter and select sample numbers from p1001
    %==========================================================================
    rowsToSelect = p1001.Anger ~= 0 & p1001.Joy ~= 0 & ...
    p1001.Contempt  ~= 0 & p1001.Fear ~= 0 & p1001.Sadness ~= 0 &...
    p1001.Surprise ~= 0 & p1001.Engagement ~= 0 & p1001.Disgust ~= 0;

    p1001_filtered = p1001(rowsToSelect, :);  % ':' indicates all variables
    %==========================================================================
    % Filter and select sample numbers from p1002
    %==========================================================================
    rowsToSelect2 =   p1002.Anger ~= 0 & p1002.Joy ~= 0 & ...
    p1002.Contempt  ~= 0 & p1002.Fear ~= 0 & p1002.Sadness ~= 0 &...
    p1002.Surprise ~= 0 & p1002.Engagement ~= 0 & p1002.Disgust ~= 0;

    p1002_filtered = p1002(rowsToSelect2, :);  % ':' indicates all variables

end

