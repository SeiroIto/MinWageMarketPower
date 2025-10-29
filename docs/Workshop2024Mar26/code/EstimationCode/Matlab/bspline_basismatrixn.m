function [B,knots] = bspline_basismatrixn(df,degree,intercept,x,knots)

if nargin < 5
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


n = degree +1;
t = knots;
B = zeros(numel(x),numel(t)-n);
    for j = 0 : numel(t)-n-1
        B(:,j+1) = bspline_basis(j,n,t,x);
    end
    
    function [y,x] = bspline_basis(j,n,t,x)
% B-spline basis function value B(j,n) at x.
%
% Input arguments:
% j:
%    interval index, 0 =< j < numel(t)-n
% n:
%    B-spline order (2 for linear, 3 for quadratic, etc.)
% t:
%    knot vector
% x (optional):
%    value where the basis function is to be evaluated
%
% Output arguments:
% y:
%    B-spline basis function value, nonzero for a knot span of n

% Copyright 2010 Levente Hunyadi

validateattributes(j, {'numeric'}, {'nonnegative','integer','scalar'});
validateattributes(n, {'numeric'}, {'positive','integer','scalar'});
validateattributes(t, {'numeric'}, {'real','vector'});
assert(all( t(2:end)-t(1:end-1) >= 0 ), ...
    'Knot vector values should be nondecreasing.');
if nargin < 4
    x = linspace(t(n), t(end-n+1), 100);  % allocate points uniformly
else
    validateattributes(x, {'numeric'}, {'real','vector'});
end
assert(0 <= j && j < numel(t)-n, ...
    'Invalid interval index j = %d, expected 0 =< j < %d (0 =< j < numel(t)-n).', j, numel(t)-n);

y = bspline_basis_recurrence(j,n,t,x);

function y = bspline_basis_recurrence(j,n,t,x)

y = zeros(size(x));
if n > 1
    b = bspline_basis(j,n-1,t,x);
    dn = x - t(j+1);
    dd = t(j+n) - t(j+1);
    if dd ~= 0  % indeterminate forms 0/0 are deemed to be zero
        y = y + b.*(dn./dd);
    end
    b = bspline_basis(j+1,n-1,t,x);
    dn = t(j+n+1) - x;
    dd = t(j+n+1) - t(j+1+1);
    if dd ~= 0
        y = y + b.*(dn./dd);
    end
elseif t(j+2) < t(end)  % treat last element of knot vector as a special case
	y(t(j+1) <= x & x < t(j+2)) = 1;
else
	y(t(j+1) <= x) = 1;
end
    
    
    