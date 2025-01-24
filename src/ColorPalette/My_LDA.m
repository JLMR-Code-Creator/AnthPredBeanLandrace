function [eigenvectors,eigenvalues,projections] = My_LDA(data,labels)
    % Function to obtain the eigenvalues, eigenvectors and projections
    % of a dataset 'data' and class labels 'labels' with LDA
    
    % Obtention of general information of the dataset
    classes = unique(labels);
    n_classes = length(classes);
    [rows,cols] = size(data);
    meanData = mean(data);

    % Calculate SB and SW
    SB = zeros(cols); % Between-class scatter of the original samples 
    SW = zeros(cols); % Within-class scatter matrix of the original samples 
    for k = 1:n_classes
        class = classes(k);
        idx = labels==class;
        dataclass = data(idx,:);
        [m_class,~] = size(dataclass);
        class_mean = mean(dataclass);
        SB = SB + m_class*(class_mean - meanData)'*(class_mean - meanData);
        SW = SW + (dataclass - class_mean)'*(dataclass - class_mean); 
    end

    % S = 𝑆_𝑊^(−1) 𝑆_𝐵
    if det(SW) < 1*(10^-6)
        % Note
        disp('LDA fails to obtain a lower dimensional space.')  
        disp('The within-class scatter matrix is not invertible:')
        if rows < cols
            disp('The dataset has more variables (columns) than observations (rows) (Small sample problem).')
        end
        % Aquí detener el proceso
        eigenvectors = NaN;
        eigenvalues = NaN;
        projections = NaN;
        return
    else
       S = inv(SW) * SB;
    end
    
    % Eigenvalues and eigenvectors 
    [eigenvectors, eigenvalues] = eig(S);

    % Analysis of complex eigenvalues
    if isreal(eigenvalues)
        %Projections
        projections = data * eigenvectors;
    else
        if sum(diag(imag(eigenvalues)) > 1*10^(-6)) == 0
            % Note
            disp('Some eigenvalues are complex numbers, but they are small enough to consider only the real part to order the linear discriminant importance.')
            eigenvalues = real(eigenvalues);
            %Projections
            projections = data * eigenvectors;
        else
            % Note
            disp('LDA fails to obtain a lower dimensional space.')  
            disp('Some eigenvalues are complex numbers, and they are not small enough to consider only the real part to order the linear discriminant importance.')
            % Aquí detener el proceso
            eigenvectors = NaN;
            eigenvalues = NaN;
            projections = NaN;
            return
        end 
    end
end