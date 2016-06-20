function varargout = getSignals(sim, varargin)

    % example call:
    % [t, q, qn] = getSignals(sim, 'time', 'q', 'qn');

    n = length(varargin);

    varargout = cell(n, 1);

    for i=1:n

        ind = getIndex(sim.sigNames, varargin{i});

        varargout{i} = sim.signals(ind, :);

    end

end
