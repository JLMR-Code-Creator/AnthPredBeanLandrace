function r=rmse(Y,y)
   %I = ~isnan(Y) & ~isnan(y); 
   %Y = Y(I); y = y(I);
   r=sqrt(sum((Y(:)-y(:)).^2)/numel(Y));
end