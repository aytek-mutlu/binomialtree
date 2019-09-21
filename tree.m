function [BinTree,rate,p_up,p_down] = tree(last_price,std_sp_500_returns,NumPeriods,annual_simple_int_rate,option_maturity)
    u = exp(std_sp_500_returns*sqrt(3/NumPeriods));
    d = 1/u;
    
    BinTree = zeros(NumPeriods+1);

    %%build tree by hand
    for i = 1:NumPeriods+1
        for j=1:i
            BinTree(j,i) = last_price * power(u,i-j) * power(d,j-1);
        end
    end
    
    rate = exp(annual_simple_int_rate*option_maturity/NumPeriods)-1;
    p_up = (1+rate-d)/(u-d);
    p_down = 1-p_up;
end