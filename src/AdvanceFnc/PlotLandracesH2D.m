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
tipo = 2;
if tipo == 1 % Sumandos histogramas lab
    [tifImages, listMask, fileInfo] = Load_Tiff_Files();
    nImages = numel(tifImages);
    HD2D_cie_ab = cell(1, nImages);
    HD2D_cie_la = cell(1, nImages);
    HD2D_cie_lb = cell(1, nImages);
    for k = 1:nImages    
        ILab = tifImages{k};
        Mask = listMask{k};
        [cie_ab, cie_la, cie_lb] = Img2Hist2DABLALB(ILab, ~Mask);
        HD2D_cie_ab{k} = cie_ab; 
        HD2D_cie_la{k} = cie_la; 
        HD2D_cie_lb{k} = cie_lb; 
    end
    [h1] =  sumHistograms(HD2D_cie_ab);
    [h2] =  sumHistograms(HD2D_cie_la);
    [h3] =  sumHistograms(HD2D_cie_lb);    
elseif tipo == 2 %% Sumando histogramas lch
    [tifImages, listMask, fileInfo] = Load_Tiff_Files();
    nImages = numel(tifImages);
    HD2D_cie_ch = cell(1, nImages);
    HD2D_cie_lc = cell(1, nImages);
    HD2D_cie_lh = cell(1, nImages);
    for k = 1:nImages    
        ILab = tifImages{k};
        Mask = listMask{k};
        [cie_ch, cie_lc, cie_lh] = Img2Hist2DCHLCLH(ILab, ~Mask);
        HD2D_cie_ch{k} = cie_ch; 
        HD2D_cie_lc{k} = cie_lc; 
        HD2D_cie_lh{k} = cie_lh; 
    end

    [h1] =  sumHistograms(HD2D_cie_ch);
    [h2] =  sumHistograms(HD2D_cie_lc);
    [h3] =  sumHistograms(HD2D_cie_lh); %<-------------------------------------------
elseif tipo==3 % Acumulando el conjuntos de datos antes de la generación del histograma
    [tifImages, listMask, fileInfo] = Load_Tiff_Files();
    nImages = numel(tifImages);
    listPixel = [];
    for k = 1:nImages
        ILab = tifImages{k};
        Mask = listMask{k};
        % Process the image and mask to accumulate data for histogram generation
        [dataLab, pixels] = ROILab(ILab, ~Mask);
        listPixel = [listPixel; (dataLab)];
    end
    % Generate histogram from accumulated pixel data
    [cie_ch, cie_lc, cie_lh, c1] = Pixels2Hist2DCHLCLH(listPixel);
        
end
%end