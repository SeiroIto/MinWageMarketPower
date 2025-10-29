function [initial_alpha, sum_e] = initial_value_finder3(Phi_1,A,c,m,beq,ubn)

    x=ones(1,m);
    
    lb = repmat(-ubn,m,1);
    ub = repmat(ubn,m,1);
    
    [initial,fval_lin,exitflag_lin,output_lin] = linprog(x,A,c, Phi_1,beq,lb,ub);
    
    sum_e=exitflag_lin-1;
    initial_alpha = initial;
    
end