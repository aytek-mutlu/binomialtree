function f = put_random(BinTree,Strike,rate_matrix,p_up_matrix,p_down_matrix)

    treeLength = length(BinTree);
    OptPrice(:,treeLength) = max(0,Strike - BinTree(:,treeLength));
    for i = treeLength-1:-1:1
        for j=1:i
            OptPrice(j,i) = (OptPrice(j,i+1)*p_up_matrix(i) + OptPrice(j+1,i+1)*p_down_matrix(i))/(1+rate_matrix(i));
        end
    end
    f = OptPrice(1,1);
end