function [idx] = QRSChenDetect(fileName,m)
    %read .mat file converted from .dat file
    file = load(fileName);
    recordedSignal = file.val(1,:);
    signalLength = size(recordedSignal,2);
    
    %%% Linear high pass filtering stage
    y1 = 1/m*[ones(1,m)];
    y2 = zeros(1,m);
    y2(1,(m+1)/2) = 1;
    fconv2 = conv(recordedSignal,y2, 'same') - conv(recordedSignal, y1, 'same');
    
    %%% Non linear low pass filtering stage
    windowSizeFilter = 36;
    filtered = conv(fconv2 .* fconv2 ,ones(1,windowSizeFilter), 'same');
    
    %%% decision making
    alpha = 0.05;
    gamma = 0.15;
    windowSize = 125;
    numberOfWindows = signalLength/windowSize;
    allWindowsIndexes = 1:(signalLength/windowSize);
    maxValues = arrayfun(@(x) max(filtered(((x-1)*(windowSize)+1):x*windowSize)), allWindowsIndexes);
    maxValuesIdx = arrayfun(@(x) find(filtered(((x-1)*(windowSize)+1):x*windowSize) == max(filtered(((x-1)*(windowSize)+1):x*windowSize)),1), allWindowsIndexes);
    
    threshold = max(filtered(1:250))-1;
    detections = zeros(1, signalLength);
    for i=1:numberOfWindows
        fullRecordIndex = (i-1)*windowSize + maxValuesIdx(i);
        if maxValues(i) >= threshold && (fullRecordIndex < 51 || sum(detections(fullRecordIndex-50:fullRecordIndex)) == 0)
            detections(fullRecordIndex) = 1;
            threshold = alpha*gamma* maxValues(i) + (1-alpha)*threshold;
        end
    end
    %find all detections
    idx = find(detections == 1);