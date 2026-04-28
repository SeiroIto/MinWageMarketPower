# MinWageMarketPower — Task Record

Reference material: variable glossary, dataset lineage, chunk maps, cross-file
symbol dependencies, geographic-level taxonomy. **Not** a bug list (see
`CLAUDE_StandingIssues.md`).

xref.sqlite caveats (2026-04-15):
* Tokenizer tracks `<-` and named `=` as writes; `:=` inside data.table `[` is NOT captured as `is_write=1`. Definition lines for `:=` variables confirmed by direct grep.
* `rm()` calls now captured as `is_write = 2` (termination) — `build_xref.R` updated 2026-04-15. Multi-rm per line handled via `gregexpr`. DB rebuilt: 126,929 rows / 50 files.
* `uid`/`UID` are interchangeable in all workflow files: IRP5Condense fills each from the other (`irp5pnl[is.na(uid) & !is.na(UID), uid := UID]` and vice versa). Never flag `uid` vs `UID` as a bug downstream.
* Object lifecycle query pending — to be added as `## Object lifecycle` section once build_xref.R is updated and re-run.

---

## Geographic-level taxonomy

`setup.rmd` defines two parallel vectors used throughout all workflow files:

```r
GeoLevel <- c("Prv", "Dis", "Loc", "Mai")          # short labels
geovars  <- c("busprov_geo", "busdistmuni_geo",
               "buslocmuni_geo", "busmainplc_geo")  # column names
```

Hierarchy (coarsest → finest):

| Short | Column name        | Level                 |
|-------|--------------------|-----------------------|
| Prv   | busprov_geo        | Province              |
| Dis   | busdistmuni_geo    | District municipality |
| Loc   | buslocmuni_geo     | Local municipality    |
| Mai   | busmainplc_geo     | Main Place (analysis level) |

Analysis uses **Main Place** (`busmainplc_geo`) for maximum granularity. Early
years (2008–2012) have many missing Main Place values → sample shrinks when
conditioning on location.

---

## Key variables — definition locations

### Fraction Affected (FA) variables
Defined in `IRP5HHI.rmd` on `ipyrc`:

| Variable  | Line | Definition |
|-----------|------|------------|
| `FA`      | L274 | `:= round(NumSubMW / Jobs, 6)` — firm-level, jobs-weighted |
| `FAe`     | L275 | `:= round(NumSubMWe / Employees, 6)` — firm-level, worker-weighted |
| `FAMP`    | L276 | `:= round(NumSubMWMP / JobsMP, 6)` — Main Place level, jobs-weighted |
| `FAeMP`   | L277 | `:= round(NumSubMWeMP / EmployeesMP, 6)` — Main Place level, worker-weighted |

### HHI variable
Defined in `IRP5HHI.rmd` on `lshare`:

| Variable  | Line  | Definition |
|-----------|-------|------------|
| `HHI`     | L1031 | `:= sum(Share^2, na.rm=T), by = byvar` — raw HHI |
| `nHHI`    | L1032 | `:= (HHI - 1/WorkersInMarket) / (1 - 1/WorkersInMarket)` — normalised |

### Baseline and outcome variables
Defined in `IRP5MergeData.rmd` on `faa`:

| Variable   | Line | Definition |
|------------|------|------------|
| `FA0`      | L178 | `:=` (vector assign with Jobs0, FAMP0, JobsMP0) — first observed FA (non-zero, non-NA) per establishment |
| `Jobs0`    | L178 | same vector assign — first observed job count |
| `FAMP0`    | L178 | same vector assign — first observed FAMP |
| `JobsMP0`  | L178 | same vector assign — first observed MP job count |
| `rJobsMP`  | L192 | `:= dJobsMP / JobsMP0` — % change in MP jobs relative to base year |

### Establishment and sample identifiers
Defined in `IRP5MergeData.rmd` on `Lf`:

| Variable           | Line | Definition |
|--------------------|------|------------|
| `EstID`            | L250 | `:= factor(as.numeric(factor(paste0(geo × taxrefno))))` — establishment ID |
| `ExistedBefore2013`| L141–145 | `:=` on `LSMa`; then L218–223 on `Lf` — `1L` if establishment appears before 2013 |

Note: `ExistedBefore2013` is first built on `LSMa` (L141–145) then applied to
the main sample `Lf` (L218–223). Both use the same three-step pattern:
initialise `NA`, set `1L` for `taxyear < 2013`, carry forward within
establishment, fill remaining `NA` with `0L`.

### Derived/display variables (IRP5Impacts.rmd)

| Variable      | Line | Definition |
|---------------|------|------------|
| `HHI0`        | L129 | `:= HHI[!is.na(HHI)][1], by = EstID` — first non-NA HHI |
| `Pre2013HHI`  | L136 | `:= HHI[!is.na(HHI) & taxyear < 2013][1], by = EstID` |
| `Pre2013FAMP0`| L163 | `:= FAMP[taxyear < 2013 & !is.na(FAMP)][1], by = EstID` |
| `FAclass0`    | L158–160 | categorical from `FAMP0`: `"low"` (≤.2), `"mid"` (.2–.5), `"high"` (>.5) |

---

## Path variables (defined in `setup.rmd` and re-defined in `IRP5MergeData.rmd`)

| Variable        | setup.rmd | MergeData | Value                          | Used by |
|-----------------|-----------|-----------|--------------------------------|---------|
| `path`          | L79       | L88       | `"W:/epguest/seiro_ito/"`      | base only |
| `pathprogram`   | L80       | L89       | `paste0(path, "outfiles/")`    | Impacts |
| `pathdata`      | L81       | L90       | `paste0(path, "data/")`        | all 4 workflow files |
| `pathsaveddata` | L82       | —         | `paste0(path, "saveddata/")`   | Condense, HHI, MergeData, Impacts |
| `pathresults`   | L83       | L91       | `paste0(path, "results/")`     | HHI, Impacts |
| `pathdataCITIRP`| L84       | —         | `"U:/CIT-IRP5 Panel/"`         | setup only |
| `pathdataIRP`   | L85       | L93       | `"U:/IRP5/Job level/v5/beta/"` | Condense |

---

## Utility functions (all defined in `setup.rmd` and copied into each workflow file)

| Function         | setup.rmd | Workflow copies | Purpose |
|------------------|-----------|-----------------|---------|
| `grepout(str,x)` | L40       | Condense L41, HHI L105, MergeData L79, Impacts L74 | returns matching elements (not positions) |
| `mask_dots(x,keep)` | L46    | Condense L47    | anonymises taxrefno/uid for display; keeps chars at positions `c(3,6,7,8,11)` |
| `write.tablev`   | L70       | Impacts L92     | tab-delimited write wrapper |
| `read.tablev`    | L56       | —               | tab-delimited read wrapper |
| `GeoLevel`       | L74       | Condense L57, HHI L109, MergeData L83, Impacts L96 | geographic level short labels |
| `geovars`        | L75       | Condense L58, HHI L110, MergeData L84, Impacts L97 | geographic column names |

Each workflow file re-defines `grepout`, `GeoLevel`, `geovars` locally at its
own setup chunk — redundant with `setup.rmd` but ensures standalone
renderability.

---

## Dataset lineage (disk files, not tracked in xref.sqlite)

```
IRP5Condense.rmd
  reads:  pathdataIRP/*.* (raw IRP5 annual files, v5/beta)
  writes: irp5.qs, irp5a.qs        → pathdata
          irp5Clean.qs              → pathdata
          irp5_CopiedLocMuni*.qs    → pathdata

IRP5HHI.rmd
  reads:  irp5.qs / irp5a.qs / irp5Clean.qs  (from pathdata)
  writes: FA<yr>.qs                 → pathdata   (one per year)
          FAD.qs                    → pathdata
          FAOfAgri.qs               → pathdata
          LShareHHI.qs              → pathdata
          irp5M*.qs, irp5Ma.qs      → pathdata

IRP5MergeData.rmd
  reads:  FAD.qs, FAOfAgri.qs, LShareHHI.qs, irp5Ma.qs (from pathdata)
  writes: EstSample_Ag.qs           → pathsaveddata

IRP5Impacts.rmd
  reads:  EstSample_Ag.qs           (from pathsaveddata)
  writes: result tables             → pathresults
          figures                   → pathresults
```

**Data note — IRP5 2009:** anomalously few observations (1.4M vs ~12M other
years); known data quality issue, not a bug.

**Data note — 2012:** uses `ipyrsClean.qs` instead of `irp512.qs`.

**Data note — location:** `payereferenceno` unreliable as establishment ID;
use `geovars + taxrefno + irp5it3aid`. Location missing for many pre-2013
rows; code copies 2015 location backward to fill.

**Agriculture filter:** `imp_mic_sic7_3d` matching
`"^Anim|^Plant pro|crops|Logging|forest"`.

---

## Cross-file R symbol dependencies (from xref.sqlite + grep, Session 2 2026-04-15)

### setup.rmd → all workflow files

| Symbol          | setup.rmd line | Consumers |
|-----------------|---------------|-----------|
| `attr.source`   | L34           | Condense, HHI, MergeData, Impacts |
| `grepout`       | L40           | Condense, HHI, MergeData, Impacts |
| `mask_dots`     | L46           | Condense |
| `write.tablev`  | L70           | Impacts |
| `GeoLevel`      | L74           | HHI |
| `geovars`       | L75           | Condense, HHI, MergeData, Impacts |
| `pathprogram`   | L80           | Impacts |
| `pathdata`      | L81           | Condense, HHI, MergeData, Impacts |
| `pathsaveddata` | L82           | Condense, HHI, MergeData, Impacts |
| `pathresults`   | L83           | HHI, Impacts |
| `pathdataIRP`   | L85           | Condense |

### IRP5Condense.rmd → IRP5HHI.rmd (in-memory symbols)

| Symbol      | Written at | Read at  |
|-------------|-----------|----------|
| `grepout`   | L41       | HHI L35  |
| `GeoLevel`  | L57       | HHI L35  |
| `geovars`   | L58       | HHI L35  |
| `FilesToCopy`| L350     | HHI L474 |
| `irp5gi`    | L468      | HHI L132 |
| `irp5gir`   | L648      | HHI L133 |
| `taxrefno`  | L762      | HHI L126 |
| `irp5Clean` | L818      | HHI L134 |
| `idvar`     | L867      | HHI L581 |

### IRP5HHI.rmd → IRP5MergeData.rmd (in-memory symbols)

| Symbol           | Written at | Read at        |
|------------------|-----------|----------------|
| `AggFA`          | L322      | MergeData L294 |
| `AggFirmFA`      | L324      | MergeData L294 |
| `TotalEmployees` | L329      | MergeData L276 |
| `FilesToCopy`    | L464      | MergeData L159 |
| `TotalJobs`      | L493      | MergeData L137 |
| `AggFAe`         | L540      | MergeData L294 |
| `irp5Ma`         | L686      | MergeData L110 |
| `taxyear`        | L770      | MergeData L105 |
| `busmainplc_geo` | L780      | MergeData L85  |
| `buslocmuni_geo` | L790      | MergeData L85  |
| `busdistmuni_geo`| L800      | MergeData L84  |

### IRP5MergeData.rmd → IRP5Impacts.rmd (in-memory symbols)

| Symbol              | Written at | Read at      |
|---------------------|-----------|--------------|
| `pathprogram`       | L89       | Impacts L10  |
| `pathdata`          | L90       | Impacts L211 |
| `pathresults`       | L91       | Impacts L244 |
| `ExistedBefore2013` | L218–223  | Impacts L191 |
| `geovars`           | L84       | Impacts L187 |

### Notable observations

* `FilesToCopy` is defined in Condense (L350), HHI (L464), and MergeData (L156)
  and read by the others — a staging list; each file carries its own copy for
  standalone rendering.
* `AggFA`/`AggFirmFA`/`TotalJobs` appear defined in both HHI and MergeData —
  MergeData re-derives them from its own merged table.
* `pathdataIRP` written by MergeData L93 and "read" by Condense L106 is likely
  a false positive — Condense runs before MergeData; xref cannot distinguish
  render order.

---

## Object lifecycle (workflow files only; xref.sqlite 2026-04-15)

Notes:
- `Created` = first `<-`/`=` assignment line (xref); `:=` definitions not captured — see Key variables section above.
- `Used` = read lines per file, consecutive runs compressed to ranges.
- Short variable names (e.g. `irp5M`) may have false-positive reads in files where the symbol appears inside longer names — verify with grep if in doubt.
- `LShareHHI`, `EstSample`, `EstSample_Ag`, `busprov_geo` show `—` for Created because they are defined with `:=` (not captured by xref tokenizer).

| Symbol | Created | Used | Terminated |
|--------|---------|------|-----------|
| `FAdata` | HHI: 242<br>Impacts: 594 | HHI: 252-259,290,292,303-311,343,345,351,353,355,358,362-364,367,373,378-379,391,395,397,413,415,418,422-423,427,433,451,455,457,465,625-632,663,665,675-676,688,690,693,697-698,702,708,726,730,732,748,750,753,757-758,762,768,786,790,792,959,962-968,1030<br>Impacts: 445,603,606-612,674,679,681,684,688-689,693,699,717,721,723 | — |
| `ipyrc` | HHI: 126<br>Impacts: 473 | HHI: 130,133,136-137,139-140,145,147,149,151-152,154-157,160,163-167,169,172,174,176,178-183,185,187-189,191-193,196,200,206-207,209,212,214-216,218,220-228,233,236-237,242,250-251,253,255,257,259,261-262,265,268,271,274-278,286-287,292,313,328,473,503,506,509-510,512-513,518,520,522,524-525,527-529,538,542,553,555,558,560-562,564,566,573,579,593-601,609-610,615,634,648,820,836-839,841-844,846,848,854,857,866,868,870,872-873,875-876,879,886,892,906-914,926-928,931,937,939-943,946-947,950,970,982,996,1031<br>Impacts: 444,464,480-483,485-488,490,492,498,501,510,512,514,516-517,519-520,523,530,536,550-558,570-572,575,581,583-587,590-591,594,614,626,640,675 | — |
| `ipyr` | Condense: 37<br>HHI: 317<br>Impacts: 290 | Condense: 20,23,30,32-35,39-49,52,54-56,58-67,69-73,92,94,100-101,107,109,115,117-119,125,128,130,132-136,140-141,143,146,148,153,160,167,398,404,422,426,429,432,437,440,450,457,460,465,468,714,716,722,743,758,760,766,769,777,780,787,792<br>HHI: 323,377,444-446,736,743,798,871-873,989,996,1051,1142-1144<br>Impacts: 296,349,416-418 | — |
| `irp5pnl` | Condense: 178 | Condense: 189,197,199-203,205-207,290,292-293,295,313,320-321,323-325 | — |
| `irp5gi` | Condense: 468 | Condense: 467,470-473,476-479,481,484-487,489,491,493,495,498,502,505,510,516,522,527,532-533,541,544,552,601,605-607,609,611,634-635,638,648-649,1019 | Condense: 705<br>HHI: 132 |
| `irp5gir` | Condense: 648 | Condense: 649-651,656-659,663-666,668-669,673,675,678,680,686,692,698,704,809,818-819,1019 | Condense: 839<br>HHI: 133 |
| `irp5Clean` | Condense: 288 | Condense: 290,351,354,461,463,465,467,489,492,494,819,821,823,840,846,981,987-989,1019 | Condense: 1004<br>HHI: 134 |
| `lshare` | HHI: 347<br>Impacts: 320 | HHI: 351-352,357-361,772-773,778-782,1025-1026,1031-1035<br>Impacts: 324-325,330-334 | — |
| `LShare` | HHI: 318<br>Impacts: 291 | HHI: 52,363-365,367,373,375,378,382-384,392,413,428-429,434,446,452,456,460,464,784-786,788,794,796,799,803-805,813,834,857-858,863,873,879,883,887,891,1037-1039,1041,1047,1049,1052,1056-1058,1066,1087,1129-1130,1135,1144,1150,1154,1158,1162<br>Impacts: 336-338,340,345,347,350,354-356,364,385,400-401,406,418,423,427,431,435 | — |
| `LShareHHI` | — (`:=`) | — | — |
| `irp5Ma` | HHI: 296<br>MergeData: 140 | HHI: 297,479,492-494,652,654,687,689,691-695,711,952,1042,1055-1057,1084,1094<br>MergeData: 83,91,110,141,168,196,198,200-204,225-227 | — |
| `irp5M` | HHI: 732<br>Impacts: 461 | Condense: 324<br>HHI: 49-50,84,108,114-117,144-146,270,274,285,289,296,306,313,317,487-489,520,684,688,699,703,710,718,720,725,736,753,824-825,925,929,940,944,951,955,969,971,976,984,989,1083<br>MergeData: 145,194<br>Impacts: 248,252,264,268,279,468-469 | — |
| `FAD` | HHI: 299<br>MergeData: 112 | HHI: 40-41,306,308,313,315,364-366,381,383,388,416,419,421,463,465-466,484,488-489,659,678,680,1047,1051-1052,1083-1084,1092-1093<br>MergeData: 81-82,84,101,103,110,113,115-117,140,142-143,145,147-148,150,152,207-208 | HHI: 755 |
| `faa` | HHI: 330<br>MergeData: 121 | HHI: 40,331-345,348,368,416,439-453,456,468,514,661-663,732<br>MergeData: 86,96,105,117,122-128,158-174,176,178,180,189-192,208-209,222,224-227,264-265,319<br>Impacts: 145 | HHI: 756 |
| `Lf` | MergeData: 217<br>Impacts: 68 | MergeData: 113,174,208,218-219,221,223-231,233,235,237,240-241,243,245-246,250,257-258,264-267,269-280,282,284,286,288,293-294,317,319<br>Impacts: 69-72,74,115,118-120,122-123,129-130,132,134,136-137,139,141,157-161,163-167,169-170,182,189,204,209,211,284,504,660,663-665,667,669-673,675-679,681-682,687,695,828 | — |
| `LSMa` | MergeData: 133 | MergeData: 96,115,123-124,127,129-135,137,139-143,145-146,148,150-151,155,157,196,222,231,234,236-240,242-243,245-246,249 | — |
| `fadata` | HHI: 324<br>MergeData: 116 | HHI: 325-326,328,400,429-430,433,435,490,1053,1094<br>MergeData: 86,118-119,147,149,153-155,164,168,209 | HHI: 755 |
| `fadata2` | HHI: 328<br>MergeData: 119 | HHI: 329<br>MergeData: 121,153-154,156 | HHI: 756 |
| `fadata3` | HHI: 329 | HHI: 330<br>MergeData: 156-158 | HHI: 756 |
| `AggFA` | HHI: 269<br>MergeData: 286<br>Impacts: 622 | HHI: 472<br>MergeData: 294 | — |
| `AggFirmFA` | HHI: 271<br>MergeData: 288<br>Impacts: 624 | HHI: 472<br>MergeData: 294 | — |
| `AggFAe` | HHI: 540<br>MergeData: 287 | MergeData: 294 | — |
| `TotalJobs` | HHI: 493<br>MergeData: 274 | HHI: 336,444,499,502,538-539,688,690,697,700<br>MergeData: 127,131,135,137,142,151,164,197,199,206,209,234,243,284,286,290,292 | — |
| `TotalEmployees` | HHI: 262<br>Impacts: 615 | HHI: 268-269,283-284,315,321-322,336-337,472,493,495,523,538,540,641-642,656-657,977-978,990-991,1029<br>MergeData: 276,284,287,291<br>Impacts: 621-622,634-635,673 | — |
| `ipGeo` | HHI: 323<br>Impacts: 296 | HHI: 326-328,334,337-338,340-341,343-345,347,349,746-749,755,758-759,761-762,764-766,768,770,999-1002,1008,1011-1012,1014-1015,1017-1019,1021,1023<br>Impacts: 299-301,307,310-311,313-314,316-318,320,322 | — |
| `EstSample` | — | — | — |
| `EstSample_Ag` | — (`:=`) | MergeData: 319 | — |
| `idyrW` | Condense: 866 | Condense: 874-878,880,882,888,903-906,908,910-911,916,918,920,926,930,933-934,936,944-945,947,949-950,955,957,963,966-967,969,972 | — |
| `dropthese` | Condense: 792 | Condense: 136,139-140,142-143,146-147,149,288,349,394,422,440,443-444,447,460,468,471-472,475,488,710,786-787,790-791,795,799-800,803,818 | — |
| `taxrefno` | Condense: 762 | setup: 45<br>Condense: 9,18-23,28-30,46,51-58,60,63-65,67,69-71,73-74,81-82,89-92,94,100,102,104,109,111,114,118,121-123,125-130,132-138,140-147,149,151,153,158,160-162,164-166,168-169,171,173,178,186,191,195,197-199,201-202,214-215,219,221,224-226,231,235,245,247-249,251,253,255-257,262-264,270,275-276,280,282-284,286,288,292,310,314,316-318,320,332,336-337,339-340,342-345,347-349,357-362,364,368,391,393,406,408,410,418,422,427,430,433-434,436-443,446,450-451,455,458,460-462,465-471,485,488,508,510,512,514,517,558,566,637,654,663-666,668,670,673,676,724,726,731,739,743,745,751,753-755,759,767-768,773,777-780,784,787-790,792-794,799,818,831,833,847,859,862<br>HHI: 93,116,126,146,152,179,207,234,245,264-265,278-279,295,311,317-318,328,331-332,339,345,348,366-367,369,389,402-403,411,420,435,439,444-445,447,453,457,466,470,489,493,495,498,525,529,531,580,618,637-638,651-652,662,664,687,689,693,696,769,788,815,818,821,825,843,847,871-872,893,913,919,928,953,973-974,985-986,1002,1022,1041,1056,1058,1061,1095,1104,1111,1114,1120,1129,1142-1143<br>MergeData: 88-89,97,102-104,111,114,118-119,125,129-130,132-136,139-141,144,146-147,156-157,159,167,169,173,187,196,198,202,204-205,208-210,213-216,218,220,222,224-226,228,231-232,236-237,241-242,244-245,252,255,260,264-267,271,273,282,319,325,334<br>Impacts: 68,70-71,74,81,84,87,91,94,97,100,154,280,321,340,416-417,459,462,465,469,487,512,515,518,522,525,529,532,535,537,552,597,617-618,629-630,646,752,758,767,824,1057,1060,1063,1067,1070,1074,1077,1080,1084,1087,1090,1093,1098,1101,1104,1107,1111,1114,1117,1120,1150 | — |
| `idvar` | Condense: 867<br>HHI: 498<br>MergeData: 231<br>Impacts: 758 | HHI: 390,393,450,453,581,584,725,728,785,788<br>Impacts: 716,719 | — |
| `FilesToCopy` | Condense: 350<br>HHI: 464<br>MergeData: 156 | Condense: 354,441,1031<br>HHI: 474,957,1117<br>MergeData: 159,322 | — |
| `byvar` | HHI: 321<br>Impacts: 294 | HHI: 325,327,337,343,348,357,359,745-746,748,758,764,769,778,780,998-999,1001,1011,1017,1022,1031,1033<br>Impacts: 298,300,310,316,321,330,332 | — |
| `taxyear` | HHI: 119<br>Impacts: 98 | Condense: 56,64,68,76,122,139,144,151,158,165-166,168,186,188,190-191,207,209,215,225,235,245,247-248,250,252,267,269,276-278,289-290,292-294,296,300-302,304,306,310,312,315,318-320,323,325-327,330,336-339,341,344-345,357-362,364,367-368,373,379-380,385-388,391,393,407,413,472,474-476,478,493,495,502,505-506,513-514,516,518,525,529,532,539,573-575,586-587,590,593,605-607,609,611,617,620,623-625,628,630-632,635,641-643,650,663-666,668,671,673,676,681,687,693,699,846,873,884,920,922,1014<br>HHI: 45,126,131-132,135,153-155,158-159,162,172-179,181-182,186,188-189,191,211-216,218-219,222-226,229,235,254,256,258,260,264,267,270,273,279,281,285,288,290,303,308,317-318,326,334,336,338,341,343,345,351,364,366,369,378,383,389,394,402,412,418,420,422,444,446,453,457,466,470,475,493-496,498-501,504-505,508,527-528,535,537,559,561-562,564,586-593,595-598,602,608,625-629,633,638-640,646-647,654,661-665,667,674-675,680,687-690,692,696-697,700,715,722,732,736-737,827-834,839,845,847,866-871,874-875,877,879-881,908-911,915,927-928,939-940,988-990,1001,1038,1056-1059,1061,1063-1064,1071,1093,1111,1180<br>MergeData: 86,88,98,102,105,112-114,118,122,127,129-134,136-144,146-147,149-152,164,166,173,179-180,196-199,201,205-207,209,214,216,219,226-229,231,233-234,236-237,239,241,244-245,257,261,263,265-267,269-271,281,283,290,292-294<br>Impacts: 68,70,72,74,76-77,81-82,84-85,87-88,91-92,94-95,97-98,100-101,116,119-122,127,130,132,136-137,139,150-157,163,169,186,189-193,195-199,202-208,265-268,274,276,280,288-290,294-295,300-301,343,368,388-389,424,440,465,473,489,491,512-513,515-516,518-519,521-523,525-526,529-530,532-533,535-536,551-555,559,571-572,583-584,632,645,661,664-667,675,681,700,703,705,709-710,712,729,742-750,754-762,822,824,838-839,844-845,850-851,901,921-922,957,973,998,1021,1057-1058,1060-1061,1063-1064,1067-1068,1070-1071,1074-1075,1077-1078,1080-1081,1084-1085,1087-1088,1090-1091,1093-1094,1098-1099,1101-1102,1104-1105,1107-1108,1111-1112,1114-1115,1117-1118,1120-1121,1149 | — |
| `busmainplc_geo` | HHI: 129<br>Impacts: 107 | setup: 76<br>Condense: 45-46,50,55,57,59-61,63,67-68,74,115,120-122,126,129,131,133-134,136-137,141,144,154,157,161,164,168,175,186,190,193,198,205,207,214-215,219,222,226,250,255,257,262,267,275,309,344,347,353,360,363-364,386,388,392-393,414,416,419,430,433,438,441,447,458,461,466,469,659,666,674,677,700,702,740,759,761,767,770,778,781,788,793,796,830-831,847,852,858,869,974,984<br>HHI: 111,116,118,146,152,161,179,193-194,201,206-207,220-221,228-229,233-234,244,264,267,270,273,279,294,317,322,329,334,345,354,356,359,366,368,393,414,416,419-420,435,437,449,453,457,461,465,489,500,525,532,565-567,570,574-575,579-580,584,602,610,612,615,617,666,689,691,694,714,725,728,742,749,751,754-755,769,787-789,816,821,825,843,864,876,879-880,884,887-888,892-893,915,917,919,952,976,995,1002,1008,1040,1042,1063,1111,1118,1120,1136,1147,1151,1155,1159,1163<br>MergeData: 85,120,125,132,135,144,146-147,157,173,187,196,204,212,216,222,232-233,241-242,244-245,249,252,254,260,266-267,271,273,323,325<br>Impacts: 74,81-82,84-85,87-88,91-92,94-95,97-98,100-101,139,154,280,295,307,339,341,407,420,424,428,432,436,465,469,487,512-513,515-516,518-519,522-526,529-533,535-537,553,559,596,646,680,682,685,719,756,758,824,1057-1058,1060-1061,1063-1064,1067-1068,1070-1071,1074-1075,1077-1078,1080-1081,1084-1085,1087-1088,1090-1091,1093-1094,1098-1099,1101-1102,1104-1105,1107-1108,1111-1112,1114-1115,1117-1118,1120-1121,1151 | — |
| `buslocmuni_geo` | HHI: 138<br>Impacts: 116 | setup: 76<br>Condense: 54,57,59-62,66,68,73,121,131,136,154,157,161,164,183,190,197,204,206,213,254,275,309,343,346,352,359,361,363-364,380,382,408,410,487,498,507,515,519,528,536-537,542-543,658,665,668,671,674,677,694,696,830-831,847,851,857,869,974,983<br>HHI: 111,117,128,160,244,264,267,270,273,294,317,322,353,366,368,393,413,420,453,531,542,564,574,584,609,617,688,728,742,748,768,779,787-789,815,919,952,995,1002,1040,1042,1110,1120<br>MergeData: 85,125,131,135,144,146,156,187,204,216,221,232,241-242,244-245,252-253,260,270,273,325<br>Impacts: 96,98,106,138,154,275,279,295,339,341,596,646,679,719,758,823 | — |
| `busdistmuni_geo` | HHI: 147<br>Impacts: 125 | setup: 75<br>Condense: 54,57-58,60-62,66,68,73,121,131,136,153,156,160,163,180,187,190,196,203,205,212,254,275,309,343,346,351,358,374,376,387,389,392-393,657,664,688,690,830-831,846,850,856,868,973,982<br>HHI: 110,116,127,137,159,244,263,266,269,272,294,316,321,353,365,368,382,393,413,419,453,530,541,551,564,573,584,609,617,688,728,741,748,767,778,786,788-789,803,814,919,952,994,1001,1039,1042,1056,1110,1120<br>MergeData: 84,124,131,134,144-146,156,186,203,215,221,231,241-242,244-245,251-252,259,270,273,325<br>Impacts: 95,97,105,115,137,153,275,279,294,338,341,354,596,645,679,719,758,823 | — |
| `busprov_geo` | — (`:=`) | setup: 75<br>Condense: 54,57-59,61-62,66,68,73,114,120-121,126,129,131,133-134,136-137,141,144,153,156,160,163,177,184,189,195,202,204,211,214,219,221,226,250,254-255,257,262,274,308,343,346,350,357,368,370,381,383,418,430,433,438,441,446,458,461,466,469,656,663,682,684,739,759,761,767,770,778,781,788,793,796,846,868,973<br>HHI: 110,115,126,136,146,158,243,263,266,269,272,281,283,293,316,321,334,336,365,368,419,435,449,453,457,461,465,472,529,540,550,560,572,616,654,656,741,766,777,786,788-789,799,813,864,876,880,884,888,892,919,951,988,990,994,1001,1039,1042,1110,1120,1136,1147,1151,1155,1159,1163<br>MergeData: 84,124,131,134,144-146,156,186,203,215,221,231,241,245,251,259,270,273,325<br>Impacts: 94,97,104,114,124,136,153,294,338,341,407,420,424,428,432,436,595,632,634,645,758 | — |

---

## Cross-file dependency chart

Objects and disk files passed between workflow files. In-memory = passed within a single knitr/litedown session; disk = written to `.qs` file and re-read by the next file.

```tree
setup.rmd
│  defines: attr.source, grepout, mask_dots, write.tablev, read.tablev,
│           GeoLevel, geovars, path, pathdata, pathsaveddata, pathresults,
│           pathprogram, pathdataIRP
│  (all workflow files source setup.rmd at their setup chunk)
│
└──► IRP5Condense.rmd
     │  reads (disk): pathdataIRP/*.* (raw IRP5 annual files, v5/beta)
     │  writes (disk): irp5.qs, irp5a.qs → pathdata
     │                 irp5Clean.qs → pathdata
     │                 irp5_CopiedLocMuni*.qs → pathdata
     │  passes (in-memory):
     │    grepout (L41), GeoLevel (L57), geovars (L58)
     │    FilesToCopy (L350), irp5gi (L468), irp5gir (L648)
     │    taxrefno (L762), irp5Clean (L818), idvar (L867)
     │
     └──► IRP5HHI.rmd
          │  reads (disk): irp5.qs / irp5a.qs / irp5Clean.qs ← pathdata
          │  writes (disk): FA<yr>.qs → pathdata
          │                 FAD.qs → pathdata
          │                 FAOfAgri.qs → pathdata
          │                 LShareHHI.qs → pathdata
          │                 irp5M*.qs, irp5Ma.qs → pathdata
          │  passes (in-memory):
          │    AggFA (L269), AggFirmFA (L271), TotalEmployees (L262)
          │    FilesToCopy (L464), TotalJobs (L493), AggFAe (L540)
          │    irp5Ma (L686), taxyear (L770), busmainplc_geo (L780)
          │    buslocmuni_geo (L790), busdistmuni_geo (L800)
          │
          └──► IRP5MergeData.rmd
               │  reads (disk): FAD.qs, FAOfAgri.qs, LShareHHI.qs,
               │                irp5Ma.qs ← pathdata
               │  writes (disk): EstSample_Ag.qs → pathsaveddata
               │  passes (in-memory):
               │    pathprogram (L89), pathdata (L90), pathresults (L91)
               │    ExistedBefore2013 (L218-223), geovars (L84)
               │
               └──► IRP5Impacts.rmd
                    reads (disk): EstSample_Ag.qs ← pathsaveddata
                    writes (disk): result tables, figures → pathresults
```

---

## Where to pick up

**Session 4 Stone Reed | 2026-04-21**

IRP5HHI.rmd — session-3 sandbox bugs, all resolved:
* ~~Bug 3 (L755-756): rm(fadata2)/rm(fadata3) — confirmed already fixed by user~~
* ~~Bug 5 (L828-831): length(unique()) → uniqueN() — FIXED CLAUDE opt~~
* ~~Bug 6 (L997-999): copy(ipyr) redundant — FIXED CLAUDE rdn~~
* ~~Bug 4 (L762-808): LocGranular 60-scan loop → fcase() single pass — FIXED CLAUDE opt~~

IRP5HHI.rmd — still open:
* Bug 1: xlim `c(1,100)` on FA density plot (should be `c(0,1)`)
\* ~~Bug 2: `ag1` chunk — `JobsPerWorker` in `.()` inflates `sum(TotalEmployees)` — FIXED CLAUDE tpo~~

IRP5Condense.rmd L672-675: 2015 location copy guard — FIXED CLAUDE tpo

**Session 8 Iron Tern | 2026-04-23**

Completed:
* IRP5HHI.rmd L1017–1023: irp5M wiring — 5 edits applied, HHI now uses firm-level filter
* IRP5HHI.rmd L772: irp5/M/L/D/P ASCII tree inserted

Open in IRP5HHI.rmd:
* Bug 1: `xlim = c(1, 100)` on FA density plot (L720) — should be `c(0, 1)`

**Next:** IRP5HHI.rmd L720 xlim fix (`c(1,100)` → `c(0,1)`). Then continue IRP5MergeData.rmd review — item 2 (L206) fixed; item 3 (L221–222 ExistedBefore2013 firm-level propagation) kept alive in StandingIssues for monitoring.

**Session 10 (continuation) | 2026-04-24**

Completed:
* HHI structural finding: HHI in Lf is a constant per establishment (LSMa2 single-row right join); HHI0 = Pre2013HHI = HHI for incumbents; HHILevel = HHILevel0 for regression sample
* HHILevel/HHILevel0 corrected definitions established (see LOG Session 10)
* setorder(faa, taxyear) applied at MergeData L178 — StandingIssues item closed
* !is.na() in any() confirmed correct; comment block added at HHI L816 with trace example

Open:
* IRP5HHI.rmd L720: xlim `c(1,100)` → `c(0,1)` on FA density plot — still open
* StandingIssues: Lf sort before qsave (low priority); HHILevel0 dead code; threshold year consistency; ExistedBefore2013 firm-level propagation (monitoring)

**Next:** IRP5HHI.rmd L720 xlim fix.
