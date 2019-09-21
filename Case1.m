
%%%Case 1

%%%read data
filename = '^GSPC.csv';
sp_500 = readtable(filename);

%%calculate returns
[returns,intervals] = price2ret(sp_500.('AdjClose'));
sp_500_returns = returns;

%%%statistical properties
mean_sp_500_returns = mean(sp_500_returns);
std_sp_500_returns = std(sp_500_returns);
skewness_sp_500_returns = skewness(sp_500_returns);
kurtosis_sp_500_returns = kurtosis(sp_500_returns);

max_sp_500_returns = max(sp_500_returns);
min_sp_500_returns = min(sp_500_returns);

%%plot
plot((1:length(sp_500_returns)),sp_500_returns)
title('S&P 500 returns by each month end')

%%lastprice and dates
last_price = sp_500.('AdjClose')(end);
NumPeriods = 3;
int_rate = 0.01;
compound_freq = 0.25;
option_maturity = 0.25;
annual_simple_int_rate = power((1+int_rate*compound_freq),1/compound_freq)-1;

[BinTree,rate,p_up,p_down] = tree(last_price,std_sp_500_returns,NumPeriods,annual_simple_int_rate,option_maturity);

%%3000 strike european call
europ_call_3000 = call(BinTree,3000,rate,p_up,p_down);
europ_call_3000_bs  = bs_call(last_price,3000,annual_simple_int_rate,option_maturity,(std_sp_500_returns*sqrt(12)));

%%%european put strike 3000
europ_put_3000 = put(BinTree,3000,rate,p_up,p_down);
europ_put_3000_bs  = bs_put(last_price,3000,annual_simple_int_rate,option_maturity,std_sp_500_returns*sqrt(12));



%%%build tree with dif. number of steps
steps = [3,4,5,6,7,8,9,10,25, 50,75, 100, 150, 200, 250];
europ_call_3000_prices = zeros(1,length(steps));
europ_put_3000_prices = zeros(1,length(steps));

step_count = 1;

for NumPeriods = steps
    [BinTree,rate,p_up,p_down] = tree(last_price,std_sp_500_returns,NumPeriods,annual_simple_int_rate,option_maturity);

    europ_call_3000_prices(1,step_count) = call(BinTree,3000,rate,p_up,p_down);
    europ_put_3000_prices(1,step_count) = put(BinTree,3000,rate,p_up,p_down);

    step_count=step_count+1;
end

subplot(2,1,1);
plot(steps,europ_call_3000_prices,steps,europ_call_3000_bs*ones(1,length(steps)));
title('Call @3000 Strike vs. Black-Scholes')
subplot(2,1,2);
plot(steps,europ_put_3000_prices,steps,europ_put_3000_bs*ones(1,length(steps)));
title('Put @3000 Strike vs. Black-Scholes')


%%%put-call parity
strike_pv = 3000/(1+annual_simple_int_rate*option_maturity);
put_call_parity_check  = ((europ_call_3000 + strike_pv) - (europ_put_3000 + last_price))


%%option prices for all strikes
NumPeriods = 3;
[BinTree,rate,p_up,p_down] = tree(last_price,std_sp_500_returns,NumPeriods,annual_simple_int_rate,option_maturity);


strikes = 2500:100:3500;
call_prices = zeros(1,length(strikes));
put_prices = zeros(1,length(strikes));
call_prices_bs = zeros(1,length(strikes));
put_prices_bs = zeros(1,length(strikes));
strike_count=1;

for strike=strikes
    call_prices(1,strike_count) = call(BinTree,strike,rate,p_up,p_down);
    put_prices(1,strike_count) = put(BinTree,strike,rate,p_up,p_down);
    call_prices_bs(1,strike_count) = bs_call(last_price,strike,annual_simple_int_rate,option_maturity,std_sp_500_returns*sqrt(12));
    put_prices_bs(1,strike_count) = bs_put(last_price,strike,annual_simple_int_rate,option_maturity,std_sp_500_returns*sqrt(12));
    strike_count = strike_count+1;
end

subplot(2,1,1);
plot(strikes,call_prices,strikes,call_prices_bs);
title('Call prices with different strikes')
legend('Binomial tree','Black-Scholes')

subplot(2,1,2);
plot(strikes,put_prices,strikes,put_prices_bs);
title('Put prices with different strikes')
legend('Binomial tree','Black-Scholes')

%%%%american call and american put
strike = 3000;
[american_call_3000,american_call_3000_early_exercise] = call_american(BinTree,strike,rate,p_up,p_down);
[american_put_3000,american_put_3000_early_exercise] = put_american(BinTree,strike,rate,p_up,p_down);


%%%european exotic
strikes = 2500:250:3500;
european_exotic_prices = zeros(1,length(strikes));
strike_count=1;
for strike=strikes
    european_exotic_prices(1,strike_count) = european_exotic(BinTree,strike,rate,p_up,p_down);
    strike_count = strike_count+1;
end

plot(strikes,european_exotic_prices);
title('European Exotic Option Price vs. different strikes')

%%%%1000 independent scenario
numScenario = 1000;
strike  = 3000;
NumPeriods = 250;
mean = annual_simple_int_rate;
std = std_sp_500_returns * sqrt(12);
pd  = makedist('normal','mu',mean,'sigma',std);
int_rates_random = random(pd,numScenario,NumPeriods);
europ_call_3000_prices_random = zeros(1,length(numScenario));
europ_put_3000_prices_random = zeros(1,length(numScenario));

path_count = 1;
for i=1:length(int_rates_random)
    rate_random = int_rates_random(i,:);
    [BinTree,rate_matrix,p_up_matrix,p_down_matrix] = tree_random(last_price,std_sp_500_returns,NumPeriods,rate_random,option_maturity);
    
    europ_call_3000_prices_random(1,path_count) = call_random(BinTree,strike,rate_matrix,p_up_matrix,p_down_matrix);
    europ_put_3000_prices_random(1,path_count) = put_random(BinTree,strike,rate_matrix,p_up_matrix,p_down_matrix);

    path_count = path_count + 1;
end
europ_call_3000_random = sum(europ_call_3000_prices_random)/numScenario;
europ_put_3000_random = sum(europ_put_3000_prices_random)/numScenario;


subplot(2,1,1);
plot(steps,europ_call_3000_prices,steps,europ_call_3000_bs*ones(1,length(steps)),steps,europ_call_3000_random*ones(1,length(steps)));
title('Comparison of Call @3000 Strike with single Binomial Tree, random 1000 independent paths and Black-Scholes')
legend('Single Binomial tree','1000 independent Binomial Trees','Black-Scholes')

subplot(2,1,2);
plot(steps,europ_put_3000_prices,steps,europ_put_3000_bs*ones(1,length(steps)),steps,europ_put_3000_random*ones(1,length(steps)));
title('Comparison of Put @3000 Strike with single Binomial Tree, random 1000 independent paths and Black-Scholes')
legend('Single Binomial tree','1000 independent Binomial Trees','Black-Scholes')




