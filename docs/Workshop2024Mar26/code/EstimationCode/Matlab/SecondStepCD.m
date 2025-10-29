    
function  [th_m,th_k,th_l, fval_PL,exitflag_PL,output_PL, x_PL,...
    output,error] = SecondStepCD(df2,degree2,df1,degree1, L, data, u_4_hat, u_3_hat, beta, options_PL)

    % B-splines and knot vectors


    intercept=1;     

    % FirstStep result
    tau_seq=transpose(1/L:1/L:(1-1/L));
    tau_vec=kron(tau_seq,ones(size(data.m_4)));
    knots_u1 = bspline_knots(df1,degree1,intercept,tau_vec);
    
    knots_m1 = bspline_knots(df1,degree1,intercept,data.m_4);
    dbs_m1 = d_basisn(degree1,df1,1,intercept,data.m_4,knots_m1); 
    bs_u1 = bspline_basismatrixn(df1,degree1,intercept,u_4_hat,knots_u1);
    dX_m1 =(kr(dbs_m1.',bs_u1.')).';
    dm_phi1=dX_m1*beta;

    % B spline
    knots_m = bspline_knots(df2,degree2,intercept,data.m_4);
    knots_k = bspline_knots(df2,degree2,intercept,data.k_4);
    knots_l = bspline_knots(df2,degree2,intercept,data.l_4);
    knots_u = bspline_knots(df1,degree1,intercept,u_4_hat);

    knots_m_lag = bspline_knots(df2,degree2,intercept,data.m_3);
    knots_k_lag = bspline_knots(df2,degree2,intercept,data.k_3);
    knots_l_lag = bspline_knots(df2,degree2,intercept,data.l_3);
    knots_u_lag = bspline_knots(df2,degree2,intercept,u_3_hat);

    
    bs_m = bspline_basismatrixn(df2,degree2,intercept,data.m_4,knots_m);
    bs_k = bspline_basismatrixn(df2,degree2,intercept,data.k_4,knots_k);
    bs_l = bspline_basismatrixn(df2,degree2,intercept,data.l_4,knots_l);
    bs_u = bspline_basismatrixn(df2,degree2,intercept,u_4_hat,knots_u);

    bs_m_lag = bspline_basismatrixn(df2,degree2,intercept,data.m_3,knots_m_lag);
    bs_k_lag = bspline_basismatrixn(df2,degree2,intercept,data.k_3,knots_k_lag);
    bs_l_lag = bspline_basismatrixn(df2,degree2+1,intercept,data.l_3,knots_l_lag);
    bs_u_lag = bspline_basismatrixn(df2,degree2,intercept,u_3_hat,knots_u_lag);


    X_m = (kr(bs_m.',bs_u.')).';
    X_m_lag=kr(bs_m_lag.',bs_u_lag.').'; 
    X_h = [data.k_4,data.l_4,data.k_3,data.l_3,X_m_lag];  % Cobb-Douglas wrt k and l

    % B-spline derivatives
    dbs_m = d_basisn(degree2,df2,1,intercept,data.m_4,knots_m); 
    dX_m =(kr(dbs_m.',bs_u.')).';

    % 2nd step
        
    m_sh =exp(data.pm_4+data.m_4-data.r_4); 
    % constraints

    m2575=quantileR(data.m_4,[0.25,0.75]).'; 
    u5050=[0.5;0.5];
    bs_u50 = bspline_basismatrixn(df2,degree2,intercept,u5050,knots_u);
    bs_m2575 = bspline_basismatrixn(df2,degree2,intercept,m2575,knots_m);
    beq=[0;1];
    
    Phi_1 =(kr(bs_m2575.',bs_u50.')).';
    Phi_2 = dX_m;
    A=[-dX_m];
    c0=[repmat(-1/10000,size(m_sh,1),1)];
    s_phi = size(Phi_2);
    m = s_phi(:,2);
    n = s_phi(:,1);


    % Find an initial value that satifies the constraints


        [alpha_initial,sum_e] = initial_value_finder3(Phi_1,A,c0,m,beq, 10);
        error=0;
            if sum_e ~=0
                 [alpha_initial,sum_e] = initial_value_finder3(Phi_1,A,c0,m,beq, 500);
                sum_e
            end
            if sum_e ~=0
                  error=0.5;
            end
    

    % PL estimator

        M_xh = X_h*((X_h.'*X_h)^(-1))*X_h.';

        I = eye(size(M_xh));
        Psi = (I - M_xh)*X_m;

        Psi_ijs = zeros(n,m,n);
        for i = 1:n
            Psi_ij = Psi-repmat(Psi(i,:),n,1);
            Psi_ijs(:,:,i) = Psi_ij;
        end

  

        [check,g] = create_PL(alpha_initial,Phi_2,Psi,Psi_ijs,m,n);
        objective = @(alpha)create_PL(alpha,Phi_2,Psi,Psi_ijs,m,n);



        [x_PL,fval_PL,exitflag_PL, output_PL] = fmincon(objective,alpha_initial,A,...
            c0,Phi_1,beq,[],[],[],options_PL);
    

    % get theta_k and theta_l
        lambda= X_m*x_PL;
        gamma=((X_h.'*X_h)^(-1))*X_h.'*lambda;

    % 3rd step
        th_k0=gamma(1,1);
        th_l0=gamma(2,1);
        th_m0= median(m_sh.*(dX_m*x_PL)./(dm_phi1-m_sh));
        
    % Normalization
        b = th_m0+th_k0+th_l0;

        th_m = th_m0/b;
        th_k  = th_k0/b;
        th_l  = th_l0/b;

        omega_4_hat= lambda/b-data.l_4*th_l-data.k_4*th_k;

        mu_4_hat=(th_m)./m_sh;

        
    % output quantity and price
        y_4_hat= th_m*data.m_4+ th_k*data.k_4+th_l*data.l_4+omega_4_hat;
        p_4_hat= data.r_4-y_4_hat;


        output=table(mu_4_hat,omega_4_hat,y_4_hat,p_4_hat);

 end



