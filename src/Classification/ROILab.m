function [dataLab] = ROILab(ILab, Mask)

 [global_rows, global_cols, ~] = size(ILab);
 MaskV=reshape(Mask,global_rows * global_cols, 1);
 indices = find(MaskV == 0);

 img=ILab;
 data_raw=reshape(img,global_rows*global_cols,3);
 dataLab=data_raw(indices,:);

end

