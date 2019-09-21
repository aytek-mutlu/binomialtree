function [f,t] = call_american(BinTree,Strike,rate,p_up,p_down)
    early_exercise = false;
    treeLength = length(BinTree);
    OptPrice(:,treeLength) = max(0,BinTree(:,treeLength) - Strike);
    for i = treeLength-1:-1:1
        for j=1:i
            if (BinTree(j,i) - Strike) >( OptPrice(j,i+1)*p_up + OptPrice(j+1,i+1)*p_down)/(1+rate)
                early_exercise = true;
            end
            OptPrice(j,i) = max((BinTree(j,i) - Strike),(OptPrice(j,i+1)*p_up + OptPrice(j+1,i+1)*p_down)/(1+rate));
        end
    end
    f = OptPrice(1,1);
    t = early_exercise;
end