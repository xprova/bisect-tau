function y = getIndex(sigNames, signal)

% returns index of signal in sigNames
% or [] if not found

y = find(strcmp(sigNames, signal));

end