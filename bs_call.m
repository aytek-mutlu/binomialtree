function f = bs_call(price,strike,int_rate,expiry,vol)
    lso = (log(price/strike)+(int_rate+(vol.*vol)/2)*expiry);
    d1 = lso/(vol*sqrt(expiry));
    d2 = d1 - vol*sqrt(expiry);
    f = price*normcdf(d1)-strike*exp(-int_rate*expiry)*normcdf(d2);
end