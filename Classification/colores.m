function [L_min,L_max] = Lrange(a,b)
    arguments
        a (1,1) {mustBeFloat}
        b (1,1) {mustBeFloat}
    end
 
    L = 0:0.01:100;
    a = a*ones(size(L));
    b = b*ones(size(L));
    lab = [L ; a ; b]';
    rgb = lab2rgb(lab);
    gamut_mask = all((0 <= rgb) & (rgb <= 1),2);
    j = find(gamut_mask,1,'first');
    k = find(gamut_mask,1,'last');
    if isempty(j)
        L_min = NaN;
        L_max = NaN;
    else
        L_min = L(j);
        L_max = L(k);
    end
end
 
function x = findNonzeroBoundary(f,x1,x2,abstol)
    arguments
        f      (1,1) function_handle
        x1     (1,1) {mustBeFloat}
        x2     (1,1) {mustBeFloat}
        abstol (1,1) {mustBeFloat} = 1e-4
 
    end
 
    if (f(x1) == 0) || (f(x2) ~= 0)
        error("Function must be nonzero at initial starting point and zero at initial ending point.")
    end
 
    xm = mean([x1 x2]);
    if abs(xm - x1) / max(abs(xm),abs(x1)) <= abstol
        x = x1;
    elseif (f(xm) == 0)
        x = findNonzeroBoundary(f,x1,xm);
    else
        x = findNonzeroBoundary(f,xm,x2);
    end
end

lch2lab = @(lch) [lch(1) lch(2)*cosd(lch(3)) lch(2)*sind(lch(3))];
inGamut = @(lab) all(0 <= lab2rgb(lab),2) & all(lab2rgb(lab) <= 1,2);
maxChromaAtLh = @(L,h) findNonzeroBoundary(@(c) inGamut(lch2lab([L c h])), 0, 200);
L = 35;
h = 0;
c = maxChromaAtLh(L,h)
rgb_out = lab2rgb(lch2lab([L c h]));

figure
colorSwatches(rgb_out)
axis equal
axis off

L = 90;
h = 0;
c = maxChromaAtLh(L,h)

rgb_out = lab2rgb(lch2lab([L c h]));
figure
colorSwatches(rgb_out)
axis equal
axis off

dh = 30;
h = -180:dh:150;
L = 35:15:95;
dL = 15;
rgb = zeros(length(h),length(L),3);
for q = 1:length(L)
    for k = 1:length(h)
        c = maxChromaAtLh(L(q),h(k));
        rgb(k,q,:) = lab2rgb(lch2lab([L(q) c h(k)]));
    end
end


rgb2 = reshape(fliplr(rgb),[],3);
p = colorSwatches(rgb2,[length(L) length(h)]);
p.XData = (p.XData - 0.5) * (dh/1.5) + h(1);
p.YData = (p.YData - 0.5) * (dL/1.5) + L(1);
xticks(h);
xlabel("h")
yticks(L)
ylabel("L*")
grid on
title("Highest chroma (most saturated) colors for different L* and h values")