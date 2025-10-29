    clear all;
    clc;

% load dataset
    data0 = readtable("../../1_DGP/DGPGameMA1AR1_1000x300_CD_20230426.csv");
    data = data0(data0.trial_id==1,:);

% setting up parameters

L=100; % the number of equal-spaced quantile partitions of [0,1]
% B-spline parameters in step 1
    degree1 = 3;
    df1 = 5; % number of knots =df-1-degree
% B-spline parameters for IV in step 1
    degreeIV = 3;
    dfIV = 5;
% B-spline parameters in step 2
    degree2 = 3;
    df2 = 5; % number of knots =df-1-degree
% fmincon option in step 1


% Step 1
fmincon_opt1 = optimoptions(@fmincon,"Algorithm","sqp-legacy","OptimalityTolerance",1e-8, "Display", "iter",...
    'SpecifyObjectiveGradient',true,...
        "MaxIterations",10000,"MaxFunctionEvaluations",1000000,"StepTolerance",1e-8, ...
        "UseParallel",true);

[beta,u_4_hat, fval,exitflag] = FirstStepHorowitz(df1,degree1,dfIV,degreeIV,data, L, fmincon_opt1, 0);
[beta_lag,u_3_hat, fval_lag,exitflag_lag] = FirstStepHorowitz(df1,degree1,dfIV,degreeIV,data, L, fmincon_opt1, 1);

% Step 2 and Step 3
fmincon_opt2= optimoptions(@fmincon,"Algorithm","sqp-legacy", "OptimalityTolerance",1e-8, "Display", "iter",...
    'SpecifyObjectiveGradient',true,...
        "MaxIterations",10000,"MaxFunctionEvaluations",1000000,"StepTolerance",1e-8, ...
        "UseParallel",true);

[th_m,th_k,th_l, fval_PL,exitflag_PL,output_PL, x_PL,...
        output,error] = SecondStepCD(df2,degree2,df1,degree1, L, data, u_4_hat, u_3_hat, beta, fmincon_opt2);
data_final=horzcat(data,output);

% Output

writetable(data_final, "output.csv")