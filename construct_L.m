function L = construct_L(STmp, p1, p2, beta, num_sample, num_view)
total = p1 + p2;
theta = ones(total, 1);
theta(p1+1:total, 1) = -beta;
Li = [-ones(1,total); eye(total)] * diag(theta) * [-ones(total, 1), eye(total)];

L = 0;
for v = 1 : num_view
    for i = 1 : num_sample
    
       Si = zeros(num_sample*num_view, total+1); 
       F = STmp((v-1)*num_sample+i,:); 
        for p = 1 : num_sample*num_view
            for q = 1 : total+1       
                if(p == F(q))
                    Si(p, q) = 1;
                end           
            end
        end
        L = L + Si*Li*(Si.');
        
    end
end
end