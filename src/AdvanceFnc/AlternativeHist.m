function [finalParm] = fitGauss2D(xVal2D,yVal2D,zVal2D,initParm)
% *purpose*
%  fit a data to a 2D rotated Gaussian function
% *inputs*
% xVal2D - [arbitrary units] define horizontal indices of zVal2D
% yVal2D - [arbitrary units] define vertical indices of zVal2D
% zVal2D - [arbitrary units] array of values to fit to 2D Gaussian
% fit parameters
%  initParm(1) Amp - [units of zData] Amplitude
%  initParm(2) xG - [units of xVals] xFWHM
%  initParm(3) yG - [units of yVals] yFWHM
%  initParm(4) theta - [deg] rotation angle of 2D Gaussian rotation
%  initParm(5) x0 - [units of xVals] horizontal value of centroid
%  initParm(6) y0 - [units of yVals] vertical value of centroid
% *outputs*
% finalParm - fit parameters
zFunc = @fitGauss2D;
finalParm = fminsearch(zFunc, initParm);
    function [SSE, zFit] = fitGauss2D(params)
        Amp = params(1);
        xG = params(2).^2;
        yG = params(3).^2;
        theta = params(4);
        x0 = params(5);
        y0 = params(6);
        xC = ((xVal2D-x0).*cosd(theta) - (yVal2D-y0).*sind(theta)).^2;
        yC = ((xVal2D-x0).*sind(theta) + (yVal2D-y0).*cosd(theta)).^2;       
        zFit = Amp.*exp( -(xC./(2.0*xG)) - (yC./(2.0*yG)) );        
        SSE = sum((zFit(:) - zVal2D(:)).^2);
    end
end

A = listPixel(:,2);
B = listPixel(:,3);
A  =  A + 129;
B  =  B + 129;
hdata = histogram2(A,B,[50 50],'FaceColor','flat');
colorbar
xlim ([1 256])
ylim ([1 256])

xVals = (hdata.XBinEdges(2:end) + hdata.XBinEdges(1:end-1))/2.0;
yVals = (hdata.YBinEdges(2:end) + hdata.YBinEdges(1:end-1))/2.0;
[xVal2D,yVal2D] = meshgrid(xVals,yVals);
zVal2D = hdata.Values;
N = size(zVal2D,1);
% initial uess
binaryImage = true(size(zVal2D));
binaryImage(zVal2D < min(zVal2D(zVal2D > 0))) = false;
zDesc = regionprops(logical(binaryImage), zVal2D, 'PixelIdxList', ...
    'WeightedCentroid','Orientation','Area');
idx = find([zDesc.Area] == max([zDesc.Area]));
estC = zDesc(idx).WeightedCentroid;
estTheta = zDesc(idx).Orientation;
blob = zeros(size(zVal2D));
blob(zDesc(idx).PixelIdxList) = 1;
initParm = [1.2*max(zVal2D(:)) std(A)/2 std(B)/2 estTheta yVals(round(estC(1))) xVals(round(estC(2)))];
zVal2DCleaned = zVal2D;
zVal2DCleaned(blob==0) = 0;
[finalParm] = fitGauss2D(xVal2D,yVal2D,zVal2DCleaned,initParm);
Amp = finalParm(1);
xG = finalParm(2).^2;
yG = finalParm(3).^2;
theta = finalParm(4);
x0 = finalParm(5);
y0 = finalParm(6);
xC = ((xVal2D-x0).*cosd(theta) - (yVal2D-y0).*sind(theta)).^2;
yC = ((xVal2D-x0).*sind(theta) + (yVal2D-y0).*cosd(theta)).^2;
zModel = Amp.*exp( -(xC./(2.0*xG)) - (yC./(2.0*yG)) );
figure();
sgtitle('2D Gaussian Fit');
subplot(4,4,4)
histogram2(A,B,[50 50],'FaceColor','flat')
subplot(4,4,[5 6 7 9 10 11 13 14 15]);
imagesc(xVal2D(1,:),yVal2D(:,1)',zVal2D);
hold on;
set(gca,'ydir','normal');
col0 = find(xVals>x0,1,'first');
row0 = find(yVals>y0,1,'first');
myXLim = xlim;
myYLim = ylim;
plot([x0 x0],myYLim,'r');
plot(myXLim,[y0 y0],'k');
subplot(4,4,1:3);
plot(xVals,interp2(xVals,yVals,zVal2D,xVals,y0*ones(size(yVals))),'k.');
hold on;
plot(xVals,interp2(xVals,yVals,zModel,xVals,y0*ones(size(yVals))),'b.');
plot([x0 x0],[0 2*Amp],'r');
xlim(myXLim);
ylim([0 2*Amp]);
subplot(4,4,[8 12 16]);
plot(interp2(xVals,yVals,zVal2D,x0*ones(size(yVals)),yVals),yVals,'r.');
hold on;
plot(interp2(xVals,yVals,zModel,x0*ones(size(yVals)),yVals),yVals,'b.');
plot([0 2*Amp],[y0 y0],'k');
ylim(myYLim);
xlim([0 2*Amp]);