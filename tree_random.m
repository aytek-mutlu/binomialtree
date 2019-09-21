function [BinTree,rate_matrix,p_up_matrix,p_down_matrix] = tree_random(last_price,std_sp_500_returns,NumPeriods,rate_random_matrix,option_maturity)
    u = exp(std_sp_500_returns*sqrt(3/NumPeriods));
    d = 1/u;
    
    BinTree = zeros(NumPeriods+1);

    %%build tree by hand
    for i = 1:NumPeriods+1
        for j=1:i
            BinTree(j,i) = last_price * power(u,i-j) * power(d,j-1);
        end
    end
    
    rate_matrix = exp(rate_random_matrix*option_maturity/NumPeriods)-1;

    p_up_matrix = (1+rate_matrix-d)/(u-d);
    p_down_matrix = 1-p_up_matrix;
end