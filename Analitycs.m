



function management_switch(option, varargin)
% MANAGEMENT_SWITCH Simple switch for management options.
%   MANAGEMENT_SWITCH(OPTION) performs the action specified by OPTION.
%   Valid OPTION strings:
%       'start'     - start the service (no additional args)
%       'stop'      - stop the service
%       'status'    - display status (returns logical up/down)
%       'restart'   - restart the service
%       'set'       - set a parameter: MANAGEMENT_SWITCH('set', name, value)
%       'get'       - get a parameter: val = MANAGEMENT_SWITCH('get', name)
%
%   Examples:
%       management_switch('start')
%       management_switch('set','maxUsers',100)
%       v = management_switch('get','maxUsers')
%
%   This function uses a persistent struct to simulate internal state.

persistent state
if isempty(state)
    % initialize default state
    state.running = false;
    state.params = struct('maxUsers', 10, 'mode', 'normal');
end

nargoutchk(0,1) % allow up to one output

switch lower(option)
    case 'start'
        if state.running
            fprintf('Service is already running.\n');
        else
            state.running = true;
            fprintf('Service started.\n');
        end

    case 'stop'
        if ~state.running
            fprintf('Service is not running.\n');
        else
            state.running = false;
            fprintf('Service stopped.\n');
        end

    case 'status'
        if nargout>0
            varargout = {state.running};
        else
            if state.running
                fprintf('Service status: running\n');
            else
                fprintf('Service status: stopped\n');
            end
        end

    case 'restart'
        state.running = false;
        pause(0.1); % simulate restart delay
        state.running = true;
        fprintf('Service restarted.\n');

    case 'set'
        if numel(varargin) < 2
            error('management_switch:set:InvalidArguments', ...
                'Usage: management_switch(''set'', name, value)');
        end
        name = varargin{1};
        val  = varargin{2};
        if ~ischar(name) && ~isstring(name)
            error('management_switch:set:InvalidName', 'Parameter name must be a string.');
        end
        name = char(name);
        state.params.(name) = val;
        fprintf('Parameter ''%s'' set.\n', name);

    case 'get'
        if numel(varargin) < 1
            error('management_switch:get:InvalidArguments', ...
                'Usage: val = management_switch(''get'', name)');
        end
        name = varargin{1};
        if ~ischar(name) && ~isstring(name)
            error('management_switch:get:InvalidName', 'Parameter name must be a string.');
        end
        name = char(name);
        if isfield(state.params, name)
            out = state.params.(name);
            if nargout>0
                varargout = {out};
            else
                disp(out);
            end
        else
            error('management_switch:get:UnknownParameter', 'Unknown parameter ''%s''.', name);
        end

    otherwise
        error('management_switch:InvalidOption', 'Unknown option ''%s''.', option);
end

% handle optional output for status/get
if nargout>0
    if exist('varargout','var')
        [varargout{1:nargout}] = varargout{:}; %#ok<NASGU,NOANS>
    else
        % If caller expects output but none was prepared, return empty.
        varargout = cell(1,nargout); %#ok<NASGU>
    end
end
end