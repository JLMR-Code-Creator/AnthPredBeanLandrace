function centers = find_gaussians(cie_lh)
% FIND_GAUSSIANS Locate Gaussian-like peaks in a probability distribution matrix.
% centers = FIND_GAUSSIANS(cie_lh) returns an N-by-4 array of
% [x, y, width, height] for detected Gaussian peaks in the matrix cie_lh.
% x = column coordinate, y = row coordinate, width = estimated sigma*2 (approx. FWHM/2.355),
% height = peak amplitude (normalized).
%
% The function:
% - accepts input named cie_lh,
% - smooths the matrix,
% - finds local maxima,
% - thresholds by prominence and minimum value,
% - estimates width by fitting a 2D Gaussian to a neighborhood around each peak.

if nargin==0 || isempty(cie_lh)
    centers = zeros(0,4);
    return
end

A = double(cie_lh);

% Smooth to reduce noise (Gaussian filter)
sigma = 1;
hsize = max(3,2*ceil(3*sigma)+1);
h = fspecial('gaussian', hsize, sigma);
As = imfilter(A, h, 'replicate');

% Normalize
if max(As(:))>0
    As = As / max(As(:));
end

% Find regional maxima
rmax = imregionalmax(As);

% Remove very small peaks by intensity threshold (relative)
minLevel = 0.05;
rmax = rmax & (As >= minLevel);

cc = bwconncomp(rmax);
if cc.NumObjects==0
    centers = zeros(0,4);
    return
end
props = regionprops(cc, As, 'WeightedCentroid', 'MaxIntensity');

% Filter by prominence: require peak max above local background
se = strel('disk',5);
localMin = imerode(As, se.getnhood);
minProm = 0.05;
keep = false(numel(props),1);
for k=1:numel(props)
    mx = props(k).MaxIntensity;
    wc = props(k).WeightedCentroid;
    rr = round(wc(2)); ccx = round(wc(1));
    rr = min(max(rr,1),size(A,1)); ccx = min(max(ccx,1),size(A,2));
    nb = As(max(1,rr-8):min(size(A,1),rr+8), max(1,ccx-8):min(size(A,2),ccx+8));
    bg = min(nb(:));
    if (mx - bg) >= minProm
        keep(k)=true;
    end
end

if ~any(keep)
    centers = zeros(0,4);
    return
end

props = props(keep);

% Prepare output: [x, y, width, height]
centers = zeros(numel(props),4);

% Options for lsqcurvefit fallback if available
has_lsq = exist('lsqcurvefit','file')==2;

for k=1:numel(props)
    wc = props(k).WeightedCentroid; % [x y]
    cx = wc(1); cy = wc(2);
    % Neighborhood for fitting
    half = 8;
    x1 = max(1, round(cx-half)); x2 = min(size(As,2), round(cx+half));
    y1 = max(1, round(cy-half)); y2 = min(size(As,1), round(cy+half));
    sub = As(y1:y2, x1:x2);
    [Xgrid,Ygrid] = meshgrid(x1:x2, y1:y2);
    xdata = [Xgrid(:), Ygrid(:)];
    zdata = sub(:);
    % Initial params: amplitude, xo, yo, sigma, offset
    amp0 = props(k).MaxIntensity;
    sigma0 = 2;
    p0 = [amp0, cx, cy, sigma0, 0];
    % 2D Gaussian model
    gauss2d = @(p,xy) p(1)*exp(-(((xy(:,1)-p(2)).^2 + (xy(:,2)-p(3)).^2)./(2*p(4).^2))) + p(5);
    % Boundaries
    lb = [0, x1, y1, 0.5, 0];
    ub = [1.5, x2, y2, 10, 1];
    try
        if has_lsq
            opts = optimoptions('lsqcurvefit','Display','off');
            pfit = lsqcurvefit(gauss2d, p0, xdata, zdata, lb, ub, opts);
        else
            % simple fminsearch fallback (minimize sum squared error)
            errfun = @(p) sum((gauss2d(p,xdata)-zdata).^2);
            pfit = fminsearch(errfun, p0);
        end
    catch
        pfit = p0;
    end
    amp = max(pfit(1),0);
    xo = pfit(2);
    yo = pfit(3);
    sigma_fit = max(pfit(4), 0);
    % width: report approx full-width (2*sigma) for convenience
    width = 2*sigma_fit;
    height = amp;
    centers(k,:) = [xo, yo, width, height];
    
end
% Draw detected centers as rectangles and text coordinates on the image
if ~isempty(centers)
    % Prepare figure if none exists
    hFig = findobj('Type','Figure','Name','cie_lh centers');
    if isempty(hFig)
        hFig = figure('Name','cie_lh centers');
    else
        figure(hFig);
        clf(hFig);
    end
    imagesc(cie_lh); hold on;
    for k=1:size(centers,1)
        xo = centers(k,1); yo = centers(k,2);
        w = centers(k,3); h = centers(k,4);
        % Draw a rectangle centered at (xo,yo) with size ~2*sigma
        rectPos = [xo - w/2, yo - w/2, w, w];
        rectangle('Position', rectPos, 'EdgeColor', 'r', 'LineWidth', 1.5);
        % Draw a crosshair
        plot([xo- w/4, xo+ w/4], [yo, yo], 'r-', 'LineWidth', 1);
        plot([xo, xo], [yo- w/4, yo+ w/4], 'r-', 'LineWidth', 1);
        % Annotate coordinates
        txt = sprintf('%.1f,%.1f', xo, yo);
        text(xo + w/2 + 1, yo - w/2 - 1, txt, 'Color', 'y', 'FontSize', 10, 'FontWeight', 'bold');
    end
    hold off;
end

end