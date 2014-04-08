function ap = computeAP(probs, labels)

[~, sortedInd] = sort(probs, 'descend');

ap = 0.0;
nPos = 0.0;
nFA = 0.0;
oldRecall = 0.0;
totalPos = sum(labels==1);

for i = 1:size(sortedInd, 1)
    if labels(sortedInd(i)) > 0
        nPos = nPos + 1;
    else
        nFA = nFA + 1;
    end
    currentRecall = nPos/totalPos;
    ap = ap + (nPos/(nPos+nFA)) * (currentRecall-oldRecall);
    oldRecall = currentRecall;
end

end