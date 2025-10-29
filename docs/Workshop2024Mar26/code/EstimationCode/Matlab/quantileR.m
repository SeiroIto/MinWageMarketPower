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