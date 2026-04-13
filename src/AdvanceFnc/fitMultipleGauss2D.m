function [paramsList, modelsSum, modelsPerComp] = fitMultipleGauss2D(listPixel, nBins, maxComponents)
% Fit multiple 2D rotated Gaussians to data in listPixel(:,2:3).
% Inputs:
%   listPixel      - NxM array, cols 2 and 3 are coordinates
%   nBins          - [nx ny] histogram bins (default [50 50])
%   maxComponents  - maximum components to fit (optional)
% Outputs:
%   paramsList     - Kx6 array of fitted params [Amp, sx, sy, theta, x0, y0]
%   modelsSum      - combined model image (same grid as histogram)
%   modelsPerComp  - cell array with each component model

if nargin < 2 || isempty(nBins), nBins = [50 50]; end
if nargin < 3, maxComponents = 10; end

% Build histogram (without plotting)
A = listPixel(:,2) + 129;
B = listPixel(:,3) + 129;
xEdges = linspace(1,256,nBins(1)+1);
yEdges = linspace(1,256,nBins(2)+1);
zVal2D = histcounts2(A,B,xEdges,yEdges);

% Bin centers and grids
xVals = (xEdges(1:end-1)+xEdges(2:end))/2;
yVals = (yEdges(1:end-1)+yEdges(2:end))/2;
[xVal2D, yVal2D] = meshgrid(xVals,yVals);

% Smooth to detect peaks
smWin = fspecial('gaussian', [7 7], 1.5);
zSmooth = imfilter(zVal2D, smWin, 'replicate');

% Detect regional maxima
peaksMask = imregionalmax(zSmooth);
% Remove very small maxima
peaksMask(zSmooth < prctile(zSmooth(zSmooth>0), 50)) = false;
[py, px] = find(peaksMask);
nPeaks = numel(px);
if nPeaks == 0
    warning('No peaks found. Returning empty outputs.');
    paramsList = []; modelsSum = zeros(size(zVal2D)); modelsPerComp = {};
    return;
end

% Limit to strongest peaks if requested
peakVals = zSmooth(sub2ind(size(zSmooth), py, px));
[~, idxOrder] = sort(peakVals,'descend');
keep = idxOrder(1:min(numel(idxOrder), maxComponents));
py = py(keep); px = px(keep);
nComp = numel(px);

% Watershed segmentation on inverted smoothed image to get regions per peak
D = -zSmooth;
D(~isfinite(D)) = max(D(:));
L = watershed(imimposemin(D, peaksMask), 8);
L(zVal2D==0) = 0;    % ignore background

% Prepare outputs
paramsList = zeros(nComp,6);
modelsPerComp = cell(nComp,1);
modelsSum = zeros(size(zVal2D));

% Loop components: initialize and fit each region separately
for k = 1:nComp
    compLabel = find(L == L(py(k), px(k)));
    mask = false(size(zVal2D));
    mask(compLabel) = true;

    % Use masked data for initial estimates
    zMasked = zeros(size(zVal2D));
    zMasked(mask) = zVal2D(mask);
    if all(zMasked(:)==0), continue; end

    % initial estimates: Amp, sx, sy, theta, x0, y0
    amp0 = 1.2 * max(zMasked(:));
    % approximate sigma from second moments of mask weighted by intensity
    [rows, cols] = find(mask);
    vals = zVal2D(mask);
    if sum(vals) == 0
        x0 = xVals(px(k)); y0 = yVals(py(k));
        sx0 = (xVals(end)-xVals(1))/10;
        sy0 = (yVals(end)-yVals(1))/10;
        theta0 = 0;
    else
        cx = sum(xVals(cols) .* vals) / sum(vals);
        cy = sum(yVals(rows) .* vals) / sum(vals);
        x0 = cx; y0 = cy;
        sx0 = sqrt(sum(((xVals(cols)-cx).^2) .* vals) / sum(vals));
        sy0 = sqrt(sum(((yVals(rows)-cy).^2) .* vals) / sum(vals));
        theta0 = 0;
        % guard
        sx0 = max(sx0, 0.5); sy0 = max(sy0, 0.5);
    end

    initParm = [amp0, sx0, sy0, theta0, x0, y0];

    % Fit using fitGauss2D_opt if exists, otherwise fitGauss2D
    if exist('fitGauss2D_opt','file')
        [pfit, modelK] = fitGauss2D_opt(xVal2D, yVal2D, zMasked, initParm);
    else
        pfit = fitGauss2D(xVal2D, yVal2D, zMasked, initParm); % assumes returns finalParm only
        % build modelK manually (same convention as earlier)
        Amp = pfit(1); xG = pfit(2).^2; yG = pfit(3).^2; theta = pfit(4); x0 = pfit(5); y0 = pfit(6);
        c = cosd(theta); s = sind(theta);
        dx = xVal2D - x0; dy = yVal2D - y0;
        xr = dx*c - dy*s; yr = dx*s + dy*c;
        modelK = Amp .* exp( - (xr.^2)./(2*xG) - (yr.^2)./(2*yG) );
    end

    % store
    paramsList(k,:) = pfit;
    modelsPerComp{k} = modelK;
    modelsSum = modelsSum + modelK;
end

end
