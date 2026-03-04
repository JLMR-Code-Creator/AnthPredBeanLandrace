function [totalHistogram] =  sumHistograms(histograms)

% Sum all matrices stored in the cell array 'histograms'
totalHistogram = [];
if ~isempty(histograms)
    totalHistogram = histograms{1};
    for k = 1:numel(histograms)
        totalHistogram = totalHistogram + histograms{k};
    end
end
end



%function PlotLandracesH2D()
[tifImages, listMask, fileInfo] = Load_Tiff_Files();
nImages = numel(tifImages);
HD2D_cie_ch = cell(1, nImages);
HD2D_cie_lc = cell(1, nImages);
HD2D_cie_lh = cell(1, nImages);
for k = 1:nImages    
    ILab = tifImages{k};
    Mask = listMask{k};
    [cie_ch, cie_lc, cie_lh] = Img2Hist2DCHLCLH(ILab, Mask);
    HD2D_cie_ch{k} = cie_ch; 
    HD2D_cie_lc{k} = cie_lc; 
    HD2D_cie_lh{k} = cie_lh; 
end

[h1] =  sumHistograms(HD2D_cie_ch);
[h2] =  sumHistograms(HD2D_cie_lc);
[h3] =  sumHistograms(HD2D_cie_lh);



     


%end