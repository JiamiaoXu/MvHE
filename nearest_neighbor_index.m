function S = nearest_neighbor_index(X_multiview, Labels, k, flag)

num_view = length(X_multiview);
num_sample = size(X_multiview{1}, 2);

S = cell(1, num_view);
for v = 1 : num_view  
    sTmp = zeros(num_sample, k);
    
    for i = 1 : num_sample
        xtmp = X_multiview{v}(:, i);
        
        if flag == 1 % within-class nearest neighbors
            index = (Labels == Labels(i));
            index(i) = 0;
        else         % between-class nearest neighbors
            index = (Labels ~= Labels(i));
        end
        
        XTmp = X_multiview{v}(:, index);
        
        IDX = knnsearch(XTmp.', xtmp.', 'K', k);
        
        pos = [];
        for t = 1 : num_sample
            if(index(t) == 1)
                pos = [pos, t];
            end
        end
        
        for t = 1 : k
           sTmp(i, t) = pos(IDX(t)); 
        end
        
    end
    
    S{v} = sTmp;
end

end
