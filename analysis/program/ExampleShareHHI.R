z <- data.table(read.table(textConnection("
busdistmuni_geo buslocmuni_geo busmainplc_geo AreaLevel Txrf taxrefno Total EachNum Share HHI nHHI TotalG
UMgungundlovu Impendle NA Loc ACQQBCKQCZ ACQQBCKQCZ 264 4 0.01515152 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc BJBXTTAGQZ BJBXTTAGQZ 264 1 0.00378788 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc CXBAZBXXBZ CXBAZBXXBZ 264 16 0.06060606 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc CXBQTBKKCZ CXBQTBKKCZ 264 2 0.00757576 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc GJBJTCCTGZ GJBJTCCTGZ 264 1 0.00378788 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc GovEntity NULL 264 22 0.08333333 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc GovEntity missing 264 22 0.08333333 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc JCQQZCBAAZ JCQQZCBAAZ 264 6 0.02272727 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc JGBJQGCTQZ JGBJQGCTQZ 264 153 0.57954545 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc KCQGZJTABZ KCQGZJTABZ 264 2 0.00757576 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc KKBAAAGXQZ KKBAAAGXQZ 264 17 0.06439394 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc QGJKXCGBJZ QGJKXCGBJZ 264 6 0.02272727 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc QJBJZQBAQZ QJBJZQBAQZ 264 1 0.00378788 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc XCQGACJQKB XCQGACJQKB 264 2 0.00757576 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc XCQJTCQXZQ XCQJTCQXZQ 264 1 0.00378788 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc XQGZCQCBCZ XQGZCQCBCZ 264 1 0.00378788 0.3711547 0.3687637 242
UMgungundlovu Impendle NA Loc ZTBQZZBABZ ZTBQZZBABZ 264 29 0.10984848 0.3711547 0.3687637 242
UMgungundlovu Impendle Cibelichle Mai ACQQBCKQCZ ACQQBCKQCZ 258 4 0.01550388 0.3783727 0.3759539 241
UMgungundlovu Impendle Cibelichle Mai BJBXTTAGQZ BJBXTTAGQZ 258 1 0.00387597 0.3783727 0.3759539 241
UMgungundlovu Impendle Cibelichle Mai CXBAZBXXBZ CXBAZBXXBZ 258 16 0.06201550 0.3783727 0.3759539 241
UMgungundlovu Impendle Cibelichle Mai CXBQTBKKCZ CXBQTBKKCZ 258 2 0.00775194 0.3783727 0.3759539 241
UMgungundlovu Impendle Cibelichle Mai GJBJTCCTGZ GJBJTCCTGZ 258 1 0.00387597 0.3783727 0.3759539 241
UMgungundlovu Impendle Cibelichle Mai GovEntity NULL 258 17 0.06589147 0.3783727 0.3759539 241
UMgungundlovu Impendle Cibelichle Mai JCQQZCBAAZ JCQQZCBAAZ 258 6 0.02325581 0.3783727 0.3759539 241
UMgungundlovu Impendle Cibelichle Mai JGBJQGCTQZ JGBJQGCTQZ 258 153 0.59302326 0.3783727 0.3759539 241
UMgungundlovu Impendle Cibelichle Mai KCQGZJTABZ KCQGZJTABZ 258 1 0.00387597 0.3783727 0.3759539 241
UMgungundlovu Impendle Cibelichle Mai KKBAAAGXQZ KKBAAAGXQZ 258 17 0.06589147 0.3783727 0.3759539 241
UMgungundlovu Impendle Cibelichle Mai QGJKXCGBJZ QGJKXCGBJZ 258 6 0.02325581 0.3783727 0.3759539 241
UMgungundlovu Impendle Cibelichle Mai QJBJZQBAQZ QJBJZQBAQZ 258 1 0.00387597 0.3783727 0.3759539 241
UMgungundlovu Impendle Cibelichle Mai XCQGACJQKB XCQGACJQKB 258 2 0.00775194 0.3783727 0.3759539 241
UMgungundlovu Impendle Cibelichle Mai XCQJTCQXZQ XCQJTCQXZQ 258 1 0.00387597 0.3783727 0.3759539 241
UMgungundlovu Impendle Cibelichle Mai XQGZCQCBCZ XQGZCQCBCZ 258 1 0.00387597 0.3783727 0.3759539 241
UMgungundlovu Impendle Cibelichle Mai ZTBQZZBABZ ZTBQZZBABZ 258 29 0.11240310 0.3783727 0.3759539 241
UMgungundlovu Impendle MpofanaNU Mai GovEntity missing 6 5 0.83333333 0.7222222 0.6666667 1
UMgungundlovu Impendle MpofanaNU Mai KCQGZJTABZ KCQGZJTABZ 6 1 0.16666667 0.7222222 0.6666667 1
"), header = T))


w <- data.table(read.table(textConnection("
busdistmuni_geo buslocmuni_geo busmainplc_geo AreaLevel TaxRef Total EachNum Share HHI nHHI TotalG
UMgungundlovu Impendle NA Loc 25 261 4 0.01532567 0.3708254 0.3684055 242
UMgungundlovu Impendle NA Loc 98 261 1 0.00383142 0.3708254 0.3684055 242
UMgungundlovu Impendle NA Loc 160 261 16 0.06130268 0.3708254 0.3684055 242
UMgungundlovu Impendle NA Loc 162 261 2 0.00766284 0.3708254 0.3684055 242
UMgungundlovu Impendle NA Loc 195 261 1 0.00383142 0.3708254 0.3684055 242
UMgungundlovu Impendle NA Loc NA 261 19 0.07279693 0.3708254 0.3684055 242
UMgungundlovu Impendle NA Loc 247 261 6 0.02298851 0.3708254 0.3684055 242
UMgungundlovu Impendle NA Loc 252 261 153 0.58620690 0.3708254 0.3684055 242
UMgungundlovu Impendle NA Loc 295 261 2 0.00766284 0.3708254 0.3684055 242
UMgungundlovu Impendle NA Loc 313 261 17 0.06513410 0.3708254 0.3684055 242
UMgungundlovu Impendle NA Loc 363 261 6 0.02298851 0.3708254 0.3684055 242
UMgungundlovu Impendle NA Loc 366 261 1 0.00383142 0.3708254 0.3684055 242
UMgungundlovu Impendle NA Loc 457 261 2 0.00766284 0.3708254 0.3684055 242
UMgungundlovu Impendle NA Loc 458 261 1 0.00383142 0.3708254 0.3684055 242
UMgungundlovu Impendle NA Loc 488 261 1 0.00383142 0.3708254 0.3684055 242
UMgungundlovu Impendle NA Loc 546 261 29 0.11111111 0.3708254 0.3684055 242
UMgungundlovu Impendle Cibelichle Mai 25 256 4 0.01562500 0.3833313 0.380913 241
UMgungundlovu Impendle Cibelichle Mai 98 256 1 0.00390625 0.3833313 0.380913 241
UMgungundlovu Impendle Cibelichle Mai 160 256 16 0.06250000 0.3833313 0.380913 241
UMgungundlovu Impendle Cibelichle Mai 162 256 2 0.00781250 0.3833313 0.380913 241
UMgungundlovu Impendle Cibelichle Mai 195 256 1 0.00390625 0.3833313 0.380913 241
UMgungundlovu Impendle Cibelichle Mai NA 256 15 0.05859375 0.3833313 0.380913 241
UMgungundlovu Impendle Cibelichle Mai 247 256 6 0.02343750 0.3833313 0.380913 241
UMgungundlovu Impendle Cibelichle Mai 252 256 153 0.59765625 0.3833313 0.380913 241
UMgungundlovu Impendle Cibelichle Mai 295 256 1 0.00390625 0.3833313 0.380913 241
UMgungundlovu Impendle Cibelichle Mai 313 256 17 0.06640625 0.3833313 0.380913 241
UMgungundlovu Impendle Cibelichle Mai 363 256 6 0.02343750 0.3833313 0.380913 241
UMgungundlovu Impendle Cibelichle Mai 366 256 1 0.00390625 0.3833313 0.380913 241
UMgungundlovu Impendle Cibelichle Mai 457 256 2 0.00781250 0.3833313 0.380913 241
UMgungundlovu Impendle Cibelichle Mai 458 256 1 0.00390625 0.3833313 0.380913 241
UMgungundlovu Impendle Cibelichle Mai 488 256 1 0.00390625 0.3833313 0.380913 241
UMgungundlovu Impendle Cibelichle Mai 546 256 29 0.11328125 0.3833313 0.380913 241
UMgungundlovu Impendle MpofanaNU Mai NA 5 4 0.80000000 0.6800000 0.600000 1
UMgungundlovu Impendle MpofanaNU Mai 295 5 1 0.20000000 0.6800000 0.600000 1
"), header = T))


#### taxrefno missing for duplicated GovEntity entries
#### mask taxrefno to communicate with Noreen
z[grepl("missing", taxrefno), taxrefno := ""]
z[, TaxRef := as.numeric(as.factor(taxrefno))]
table(z[, .(Txrf, TaxRef)])
z[, Gov := 0L]
z[grepl("Gov", Txrf), Gov := 1L]
z[, Txrf := as.character(TaxRef)]
z[Gov == 1, Txrf := "GovEntity"]
z[, taxrefno := NULL]
#### There are 4 GovEntity but 1 is a duplicate
#### Duplicated entries for GovEntity, one with taxrefno == "" and another with NULL
#### This is produced while defining GovEntity
#### Drop 2nd GovEntity at each geo level
z[, Gov2 := 0L]
z[grepl("Gov", Txrf), Gov2 := as.integer(1:.N), by = busprov_geo]
z[grepl("Gov", Txrf), Gov2 := as.integer(1:.N), by = busdistmuni_geo]
z[grepl("Gov", Txrf), Gov2 := as.integer(1:.N), by = buslocmuni_geo]
z[grepl("Gov", Txrf), Gov2 := as.integer(1:.N), by = busmainplc_geo]
z[grepl("Gov", Txrf), .(buslocmuni_geo, busmainplc_geo, AreaLevel, Txrf, TaxRef,  EachNum, Gov2)]
z <- z[Gov2 != 2, ]
z1 <- z[grepl("Loc", AreaLevel), ]
z1[, Total := sum(EachNum)]
z1[, Share := EachNum/Total]
z1[, HHI := sum(Share^(2)), by = buslocmuni_geo]
z2 <- z[!grepl("Loc", AreaLevel), ]
z2[, Total := sum(EachNum), by = busmainplc_geo]
z2[, Share := EachNum/Total]
z2[, HHI := sum(Share^(2)), by = busmainplc_geo]
rbindlist(list(z1, z2))[, 
  .(AreaLevel, buslocmuni_geo, busmainplc_geo, Txrf, EachNum, Total, Share, HHI)]

#### taxrefno missing for duplicated GovEntity entries
#### mask taxrefno to communicate with Noreen
w[, Txrf := as.character(TaxRef)]
w[is.na(TaxRef), Txrf := "GovEntity"]
#### There are 4 GovEntity but 1 is a duplicate
#### Duplicated entries for GovEntity, one with taxrefno == "" and another with NULL
#### This is produced while defining GovEntity
#### Drop 2nd GovEntity at each geo level
w[, Gov2 := 0L]
w[grepl("Gov", Txrf), Gov2 := as.integer(1:.N), by = busprov_geo]
w[grepl("Gov", Txrf), Gov2 := as.integer(1:.N), by = busdistmuni_geo]
w[grepl("Gov", Txrf), Gov2 := as.integer(1:.N), by = buslocmuni_geo]
w[grepl("Gov", Txrf), Gov2 := as.integer(1:.N), by = busmainplc_geo]
w[grepl("Gov", Txrf), .(buslocmuni_geo, busmainplc_geo, AreaLevel, Txrf, TaxRef,  EachNum, Gov2)]
w <- w[Gov2 != 2, ]
w1 <- w[grepl("Loc", AreaLevel), ]
w1[, Total := sum(EachNum)]
w1[, Share := EachNum/Total]
w1[, HHI := sum(Share^(2)), by = buslocmuni_geo]
w2 <- w[!grepl("Loc", AreaLevel), ]
w2[, Total := sum(EachNum), by = busmainplc_geo]
w2[, Share := EachNum/Total]
w2[, HHI := sum(Share^(2)), by = busmainplc_geo]
rbindlist(list(w1, w2))[, 
  .(AreaLevel, buslocmuni_geo, busmainplc_geo, Txrf, EachNum, Total, Share, HHI)]
