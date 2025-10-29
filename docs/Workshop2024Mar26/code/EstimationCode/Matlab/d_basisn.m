function dB = d_basisn(degree,df,derivs,intercept,x,knots)
% if intercept is true, the input will be 1, otherwise 0.
if nargin < 6
    nknots = df - degree - intercept;
    espace = linspace(0,1,nknots+2);
    max_x = max(x);
    min_x = min(x);
    max_xx = repmat(max_x,1,degree+1);
    min_xx = repmat(min_x,1,degree+1);
    wknots = quantileR(x,espace);
    wsize = size(wknots);
    iknots = wknots(2:wsize(:,2)-1);
    knots = [min_xx iknots max_xx];
end



K = size(knots);
iiknots = knots(1+derivs:K(:,2)-derivs);
b_mat = bspline_basismatrix(degree-derivs+1,iiknots,x); 

iknots = knots(degree+2:K(:,2)-degree-1);
max_x = max(knots);
min_x = min(knots);

for iter = 1:derivs
ord = degree - derivs + iter + 1;
maxx = repmat(max_x,1,ord);
minx = repmat(min_x,1,ord);

kknots = [minx iknots maxx];

denom = [];
for lag = 1:length(kknots)- ord +1
    denom(lag) = kknots(lag+ord-1) - kknots(lag);
end
    
facVec = [];

for i = 1:length(denom)
   if denom(i) == 0
       facVec(i) = 0;
   else
       facVec(i) = (ord-1)/denom(i);
   end
end

b_size = size(b_mat);
b_mat0 = [zeros(b_size(:,1),1) b_mat zeros(b_size(:,1),1)];

db_mat = [];

for j = 1:df-derivs+iter
idx = j:j+1;    
tmp_mat = b_mat0(:,idx);
db_mat(:,j) = facVec(idx(:,1))*tmp_mat(:,1) - facVec(idx(:,2))*tmp_mat(:,2);
end

b_mat = db_mat;
    
end

dB = b_mat;

function [B,x] = bspline_basismatrix(n,t,x)
% B-spline basis function value matrix B(n) for x.
%
% Input arguments:
% n:
%    B-spline order (2 for linear, 3 for quadratic, etc.)
% t:
%    knot vector
% x (optional):
%    an m-dimensional vector of values where the basis function is to be
%    evaluated
%
% Output arguments:
% B:
%    a matrix of m rows and numel(t)-n columns

% Copyright 2010 Levente Hunyadi

if nargin > 2
    B = zeros(numel(x),numel(t)-n);
    for j = 0 : numel(t)-n-1
        B(:,j+1) = bspline_basis(j,n,t,x);
    end
else
    [b,x] = bspline_basis(0,n,t);
    B = zeros(numel(x),numel(t)-n);
    B(:,1) = b;
    for j = 1 : numel(t)-n-1
        B(:,j+1) = bspline_basis(j,n,t,x);
    end
end
