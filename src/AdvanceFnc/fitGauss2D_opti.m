function [finalParm, zModel] = fitGauss2D_opt(xVal2D, yVal2D, zVal2D, initParm)
% Fit 2D rotated Gaussian. Returns fitted parameters and model surface.
% Params: [Amp, sigmaX, sigmaY, theta_deg, x0, y0]
% sigmaX/sigmaY are optimization parameters (positive); we keep them >0 by optimizing log.
%
% Usage:
% [p, zModel] = fitGauss2D_opt(xVal2D,yVal2D,zVal2D,initParm);

% Flatten grids and apply mask to ignore zero/background bins (speeds fit).
x = xVal2D(:);
y = yVal2D(:);
z = zVal2D(:);

% Mask out exact zeros (or background) to reduce problem size
mask = z > 0;
x = x(mask);
y = y(mask);
z = z(mask);

% Reparameterize: p = [Amp, log(sigmaX), log(sigmaY), theta_deg, x0, y0]
p0 = initParm;
p0(2) = log(max(initParm(2), eps));
p0(3) = log(max(initParm(3), eps));

% Residual function (returns vector residuals)
resfun = @(p) residuals(p, x, y, z);

% Try lsqnonlin if available, otherwise fallback to fminsearch on SSE.
if exist('lsqnonlin','file')
    opts = optimoptions('lsqnonlin','Display','off','MaxIterations',1000,'TolFun',1e-8);
    lb = [-inf, log(eps), log(eps), -180, -inf, -inf];
    ub = [ inf,  inf,      inf,    180,  inf,  inf];
    pfit = lsqnonlin(resfun, p0, lb, ub, opts);
else
    % fminsearch minimizing sum of squares
    ssefun = @(p) sum(residuals(p,x,y,z).^2);
    opts = optimset('Display','off','MaxIter',2000,'TolX',1e-6,'TolFun',1e-6);
    pfit = fminsearch(ssefun, p0, opts);
end

% Recover parameters (sigma in linear space)
finalParm = pfit;
finalParm(2) = exp(pfit(2));
finalParm(3) = exp(pfit(3));

% Build full model on original grid for output
Amp  = finalParm(1);
sx   = finalParm(2);
sy   = finalParm(3);
theta = finalParm(4);
x0   = finalParm(5);
y0   = finalParm(6);

% compute rotated coordinates efficiently (use cosd/sind once)
c = cosd(theta);
s = sind(theta);
xr =  (xVal2D - x0)*c - (yVal2D - y0)*s;
yr =  (xVal2D - x0)*s + (yVal2D - y0)*c;
zModel = Amp .* exp( - (xr.^2)/(2*sx^2) - (yr.^2)/(2*sy^2) );

end

%% Helper: residuals
function r = residuals(p, x, y, z)
% p = [Amp, log(sx), log(sy), theta_deg, x0, y0]
Amp = p(1);
sx  = exp(p(2));
sy  = exp(p(3));
theta = p(4);
x0 = p(5);
y0 = p(6);

c = cosd(theta);
s = sind(theta);

xr = (x - x0).*c - (y - y0).*s;
yr = (x - x0).*s + (y - y0).*c;

zfit = Amp .* exp( - (xr.^2)/(2*sx^2) - (yr.^2)/(2*sy^2) );
r = zfit - z;
end

% --- Datos de entrada: listPixel (NxM) con columnas 2 y 3 ---
A = listPixel(:,2) + 129;
B = listPixel(:,3) + 129;

% --- Build 2D histogram counts without plotting ---
nBins = [50 50];
[xEdges, yEdges] = deal(linspace(1,256,nBins(1)+1), linspace(1,256,nBins(2)+1));
% histcounts2 expects X,Y as column vectors
zVal2D = histcounts2(A, B, xEdges, yEdges);

% Bin centers
xVals = (xEdges(1:end-1) + xEdges(2:end)) / 2;
yVals = (yEdges(1:end-1) + yEdges(2:end)) / 2;
[xVal2D, yVal2D] = meshgrid(xVals, yVals);

% --- Estimate initial parameters using connected region of nonzero bins ---
% Threshold: keep bins above smallest positive count
nz = zVal2D > 0;
if ~any(nz(:))
    error('No nonzero histogram bins found.');
end
th = min(zVal2D(nz));
binaryImage = zVal2D >= th;

props = regionprops(binaryImage, zVal2D, 'PixelIdxList','WeightedCentroid','Orientation','Area');
[~, idxMax] = max([props.Area]);
rp = props(idxMax);

% Weighted centroid returns [x y] in bin coordinates -> map to centers
estC = rp.WeightedCentroid;           % [xBinCenterIndex, yBinCenterIndex] (centroid in data coords)
estTheta = rp.Orientation;
% Note: WeightedCentroid returns coordinates in (x,y) with same units as image columns/rows:
% convert to nearest bin center index
cx = round(estC(1)); cy = round(estC(2));
cx = max(min(cx, numel(xVals)),1);
cy = max(min(cy, numel(yVals)),1);

% initial parameters (keep same convention que tu función fitGauss2D espera)
initAmp = 1.2 * max(zVal2D(:));
initParm = [ initAmp, std(A)/2, std(B)/2, estTheta, xVals(cx), yVals(cy) ];

% Create cleaned zVal2D (zero outside selected blob)
zVal2DCleaned = zeros(size(zVal2D));
zVal2DCleaned(rp.PixelIdxList) = zVal2D(rp.PixelIdxList);

% --- Fit (usa tu función fitGauss2D existente) ---
finalParm = fitGauss2D_opt(xVal2D, yVal2D, zVal2DCleaned, initParm);

% --- Build model (vectorizado y con cos/sin precalculados) ---
Amp   = finalParm(1);
xG    = finalParm(2).^2;    % según implementación original
yG    = finalParm(3).^2;
theta = finalParm(4);
x0    = finalParm(5);
y0    = finalParm(6);

c = cosd(theta);
s = sind(theta);
dx = xVal2D - x0;
dy = yVal2D - y0;
xr = dx * c - dy * s;
yr = dx * s + dy * c;
zModel = Amp .* exp( - (xr.^2)./(2*xG) - (yr.^2)./(2*yG) );

% --- Plot compacto ---
figure;
sgtitle('2D Gaussian Fit');

% Histogram (top-left small)
subplot(4,4,4);
histogram2(A,B,nBins,'FaceColor','flat');
xlim([1 256]); ylim([1 256]);

% Main image with model overlay
subplot(4,4,[5 6 7 9 10 11 13 14 15]);
imagesc(xVals, yVals, zVal2D);
set(gca,'ydir','normal'); hold on;
contour(xVals, yVals, zModel, 6, 'LineColor','b', 'LineWidth', 1);    % overlay model contours
plot(x0, y0, 'r+', 'MarkerSize',10, 'LineWidth',1.5);
xlim([min(xVals) max(xVals)]); ylim([min(yVals) max(yVals)]);

% X-cut (top row)
subplot(4,4,1:3);
z_xcut_data  = interp2(xVals, yVals, zVal2D, xVals, y0*ones(size(xVals)), 'linear', 0);
z_xcut_model = interp2(xVals, yVals, zModel, xVals, y0*ones(size(xVals)), 'linear', 0);
plot(xVals, z_xcut_data, 'k.'); hold on;
plot(xVals, z_xcut_model, 'b-');
plot([x0 x0],[0 2*Amp],'r');
xlim([min(xVals) max(xVals)]);
ylim([0 2*Amp]);

% Y-cut (right column)
subplot(4,4,[8 12 16]);
z_ycut_data  = interp2(xVals, yVals, zVal2D, x0*ones(size(yVals)), yVals, 'linear', 0);
z_ycut_model = interp2(xVals, yVals, zModel, x0*ones(size(yVals)), yVals, 'linear', 0);
plot(z_ycut_data, yVals, 'r.'); hold on;
plot(z_ycut_model, yVals, 'b-');
plot([0 2*Amp],[y0 y0],'k');
ylim([min(yVals) max(yVals)]);
xlim([0 2*Amp]);
