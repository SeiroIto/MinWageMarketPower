function [obj,grad]= smoothed_gmm_Horowitz_gr(alpha, B, r_vec,tau_vec, N, kron_bs_mLag, Omega,bn)

    u=(B*alpha-r_vec)/bn;
    Horowitz=(1/2+(105/64)*(u-(5/3)*u.^3+(7/5)*u.^5-(3/7)*u.^7)).*(u<=1).*(u>=-1)+(u>1);
    p_L=Horowitz-tau_vec;
    w_L=(1/N)*kron_bs_mLag.'*p_L;
    obj=w_L.'*Omega*w_L; 

    if nargout > 1 % gradient required 
        dHorowitz = (1/bn)*(105/64)*(1-5*u.^2+7*u.^4-3*u.^6).*(u<=1).*(u>=-1);  
        dw_L = (1/N)*kron_bs_mLag'*(kron(dHorowitz,ones(1,size(B,2))).*B);  
        grad=2*dw_L'*Omega*w_L;    
    end 

end
