function f = call(BinTree,Strike,rate,p_up,p_down)

    treeLength = length(BinTree);
    OptPrice(:,treeLength) = max(0,BinTree(:,treeLength) - Strike);
    for i = treeLength-1:-1:1
        for j=1:i
            OptPrice(j,i) = (OptPrice(j,i+1)*p_up + OptPrice(j+1,i+1)*p_down)/(1+rate);
        end
    end
    f = OptPrice(1,1);
end