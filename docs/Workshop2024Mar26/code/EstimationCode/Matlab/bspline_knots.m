function knots = bspline_knots(df,degree,intercept,x)
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

    function qR = quantileR(x,probs)
n = length(x);
np = length(probs);

index = 1 + (n - 1)*probs;
lo = floor(index);
hi = ceil(index);
xs = sort(x);
qs = xs(lo)';

idxdetect = [index;lo];
i = find(idxdetect(1,:)>idxdetect(2,:));

h = (index - lo);
hn = h(i);

qs(i) = (1-hn).*qs(i) + hn.*(xs(hi(i))');

qR =qs;



