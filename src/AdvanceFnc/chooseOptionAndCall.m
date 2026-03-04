function chosenValue = chooseOptionAndCall(promptTitle, options, handlerFcn, varargin)
% chooseOptionAndCall - Display options to user, get selection, call handler.
%
% Syntax:
%   val = chooseOptionAndCall(title, options, handler)
%   val = chooseOptionAndCall(title, options, handler, arg1, arg2, ...)
%
% Inputs:
%   promptTitle - string for dialog title or prompt
%   options     - cell array of strings (options) or numeric vector (values)
%   handlerFcn  - function handle to call with the chosen value/index:
%                 handlerFcn(value) or handlerFcn(value, varargin{:})
%   varargin    - additional arguments passed to handlerFcn
%
% Output:
%   chosenValue - value returned by handlerFcn (empty if cancelled)
%
% Example:
%   opts = {'Add','Remove','Update'};
%   f = @(s) fprintf('You chose: %s\n', s);
%   chooseOptionAndCall('Select action', opts, f);

% Validate inputs
narginchk(3, Inf);
if isempty(options)
    error('Options must be a non-empty cell array or numeric vector.');
end
if ~isa(handlerFcn, 'function_handle')
    error('handlerFcn must be a function handle.');
end

% Prepare displayable labels and a mapping to actual values
if iscellstr(options) || isstring(options)
    labels = cellstr(options);
    values = labels;
elseif isnumeric(options) || islogical(options)
    values = num2cell(options(:));
    labels = cellfun(@num2str, values, 'UniformOutput', false);
else
    % For other types, use class and index
    values = options(:);
    labels = arrayfun(@(i) sprintf('%s #%d', class(values{i}), i), (1:numel(values))', 'UniformOutput', false);
end

% Show selection dialog
[sel, ok] = listdlg('ListString', labels, ...
                    'SelectionMode', 'single', ...
                    'PromptString', promptTitle, ...
                    'Name', promptTitle, ...
                    'OKString', 'Choose', ...
                    'CancelString', 'Cancel', ...
                    'ListSize', [300 200]);
if ~ok || isempty(sel)
    chosenValue = [];
    return;
end

% Get chosen item
chosenItem = values{sel};

% Call handler function and return its output
if nargout(handlerFcn) == 0
    % Handler does not return value (or unknown) - call and return empty
    handlerFcn(chosenItem, varargin{:});
    chosenValue = [];
else
    chosenValue = handlerFcn(chosenItem, varargin{:});
end
end