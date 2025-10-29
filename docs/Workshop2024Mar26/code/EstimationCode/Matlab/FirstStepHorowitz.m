function  [beta,u_hat, fval,exitflag] = FirstStepHorowitz(df,degree,dfIV,degreeIV,data, L, fminconopt, lag)
% simple version: March 21, 2024
% Yoichi Sugita
% smoothed gmm

%  clear all;

intercept=1;
   tic

  % load data
  
    if lag==0
         m=data.m_4;
         r=data.r_4;
         mL=data.m_2; 
         u=data.u_4;
    else 
        m=data.m_3;
         r=data.r_3;
         mL=data.m_1; 
         u=data.u_3;
    end 

    eps1=1/L;
    eps2=1-1/L;

    interval=1/L;
    tau_seq=transpose(eps1:interval:eps2);
            
    N=size(m);
    
    one_L=ones(L-1,1);
    one_tau=ones(N);
% sigma L inverse
    % diagonal elements
    vdiag=ones(L-1,1)*2;
    % sub/superdiagonal elements
    vsubdiag=ones(L-2,1)*(-1);

    P=diag(vdiag)+diag(vsubdiag,1)+diag(vsubdiag,-1);
    P(1,1)=(eps2-eps1)/(eps1*L+eps2-eps1)+1;
    P(L-1,L-1)=(eps2-eps1)/((1-eps2)*L+eps2-eps1)+1;

    sigma_L_inv=P*L/(eps2-eps1);

 % kronecker product of data
    m_vec=kron(one_L,m); 

    r_vec=kron(one_L,r);

    % m_{t-1}
    mL_vec=mL;
    tau_vec=kron(tau_seq,one_tau);

% B-spline basis functions
    
    knots_m = bspline_knots(df,degree,intercept,m_vec);
    knots_mLag = bspline_knots(dfIV,degreeIV,intercept,mL_vec);
    knots_tau = bspline_knots(df,degree,intercept,tau_vec);

    bs_m = bspline_basismatrixn(df,degree,intercept,m_vec,knots_m);
    bs_mLag = bspline_basismatrixn(dfIV,degreeIV,intercept,mL_vec,knots_mLag);
    bs_tau = bspline_basismatrixn(df,degree,intercept,tau_vec,knots_tau);
    

    B = (kr(bs_m.',bs_tau.')).';

    kron_bs_mLag=kron(diag(one_L),bs_mLag);

% sigma M
    [n,D]=size(data);
    sigma_M=bs_mLag.'*bs_mLag/n;
    Omega=kron(sigma_L_inv,inv(sigma_M));

% bandwidth
    bn = 1.06*std(r)*n^(-1/5);

% smoothed GMM objective function
    objective = @(alpha)smoothed_gmm_Horowitz_gr(alpha, B, r_vec, tau_vec, n, kron_bs_mLag, Omega, bn);


% initial alpha
    a_ols=((B.'*B)^-1)*B.'*r_vec;


%%%% constraned using "fmincon" %%%%%%


    dbs_m = d_basisn(degree,df,1,intercept,m_vec,knots_m); 
    dbs_tau = d_basisn(degree,df,1,intercept,tau_vec,knots_tau); 

    dB_m = (kr(dbs_m.',bs_tau.')).';
    dB_tau = (kr(bs_m.',dbs_tau.')).';

    dB=[dB_m;dB_tau];
    [K,l]=size(dB);
    b=ones(K,1)*1e-9;
     
 %%%%% constraint     dB*alpha>0  =>  b=0.001:  b-dB*alpha<=0
    % fmincon
    
    [beta,fval,exitflag]=fmincon(objective,a_ols,-dB,-b,[],[],[],[],[],fminconopt);    


    % -dB*alpha<=-b


    
%%%%%% obtain u_hat %%%%%%%%%%%%
    % grid search for u_i such that min_u abs(r_i - phi(m_i,u))
    % 10000 grid points for u in [0,1]

    L0=L*100;

    one_L0=ones(L0-1,1);
    interval0=1/L0;
     tau_seq0= transpose(1/L0:interval0:(1-1/L0));  
    m_vec0=kron(one_L0,m); 
    r_vec0=kron(one_L0,r);

    tau_vec0=kron(tau_seq0,one_tau);
    bs_m0 = bspline_basismatrixn(df,degree,intercept,m_vec0,knots_m);
    bs_tau0 = bspline_basismatrixn(df,degree,intercept,tau_vec0,knots_tau);

    B0 = (kr(bs_m0.',bs_tau0.')).';

    dr=abs(r_vec0-B0*beta);
    dr_mat=reshape(dr,[n,L0-1]);
    [min_dr, argmin_dr]=min(dr_mat.');
    u_hat_ind=argmin_dr.';
    u_hat=tau_seq0(u_hat_ind);
    
    



end

