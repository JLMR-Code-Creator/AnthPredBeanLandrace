function gaussParams = fitGaussiansFromHist(L1, c1, nbins)
% fitGaussiansFromHist Fit Gaussian(s) to histograms of L1 and c1
%   gaussParams = fitGaussiansFromHist(L1, c1) fits a single Gaussian to the
%   histogram of L1 and to the histogram of c1 and returns a struct with
%   fields L1 and c1 containing [amplitude, mean, std].
%   gaussParams = fitGaussiansFromHist(L1, c1, nbins) uses nbins bins.
%
%   gaussParams.L1 = [A mu sigma]
%   gaussParams.c1 = [A mu sigma]
%
% Requirements: Statistics and Optimization toolboxes are not required;
% fitting is done by nonlinear least-squares using lsqnonlin if available,
% otherwise by fminsearch.

if nargin<3 || isempty(nbins), nbins = 100; end

% Helper: compute histogram (counts normalized to density) and bin centers
    function [x, y] = hist_density(data)
        data = data(~isnan(data) & ~isinf(data));
        if isempty(data)
            x = []; y = [];
            return
        end
        [counts, edges] = histcounts(data, nbins, 'Normalization', 'pdf');
        x = (edges(1:end-1)+edges(2:end))/2;
        y = counts;
    end

% Helper: fit single Gaussian to histogram (A*exp(-(x-mu)^2/(2*sigma^2)))
    function params = fitGaussian(x, y)
        if isempty(x)
            params = [NaN NaN NaN];
            return
        end
        % initial guesses
        mu0 = sum(x.*y)/sum(y);
        sigma0 = sqrt(max(sum(y.*(x-mu0).^2)/sum(y), eps));
        A0 = max(y);
        p0 = [A0, mu0, sigma0];

        gauss = @(p,xdata) p(1)*exp(-0.5*((xdata-p(2))./p(3)).^2);
        resid = @(p) gauss(p,x)-y;

        opts = [];
        % prefer lsqnonlin if available
        if exist('lsqnonlin','file')==2
            lb = [0, min(x), eps];
            ub = [inf, max(x), inf];
            opts = optimoptions('lsqnonlin','Display','off');
            p = lsqnonlin(resid,p0,lb,ub,opts);
        else
            % use fminsearch on sum of squares
            sse = @(p) sum(resid(p).^2);
            p = fminsearch(sse,p0,optimset('Display','off'));
        end
        params = p;
    end

[xL,yL] = hist_density(L1);
[xC,yC] = hist_density(c1);

pL = fitGaussian(xL,yL);
pC = fitGaussian(xC,yC);

gaussParams.L1 = pL;
gaussParams.c1 = pC;
end