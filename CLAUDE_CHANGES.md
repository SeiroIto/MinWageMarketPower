<span style="font-size: 1.6em; font-weight: bold;">MinWageMarketPower — Claude Changes</span>

# Session 0 Pre-logging fixes (IRP5HHI.rmd)

Note
:   Pre-logging fixes have only the "+" side (the applied fix description) and no "-" side (the original buggy code), because the CLAUDE_CHANGES.md before/after format had not yet been decided when these fixes were made. The "+" descriptions are recorded in CLAUDE_LOG.md under "Session 0 Pre-logging fixes (IRP5HHI.rmd)". This entry is a cross-reference only; no code is duplicated here.

# Session 1 Blue Heron | 2026-04-12

No code changes yet this session.

# Sandbox

<!-- Raw per-edit notes. Promoted to canonical section at orderly sign-off. Append-only. -->
* 2026-04-14 | IRP5Condense.rmd L44 | added `mask_dots(x, keep=c(3,6,7,8,11))` helper in setup chunk
* 2026-04-14 | IRP5Condense.rmd L496-501 | replaced `gsub("....$", "....", gsub("^....", "....", x))` trick + invalid `(c("taxrefno.","uid.")) = lapply(...)` with direct `.(taxrefno = mask_dots(taxrefno), uid = mask_dots(uid), ...)` inline in the select
* 2026-04-14 | IRP5Condense.rmd L649, L650-651 | wrapped taxrefno/uid with mask_dots in two bare-expression displays
* 2026-04-14 | IRP5Condense.rmd L702, L703 | dupuid[n > 10,] → explicit `.()` with mask_dots; print(unique(dupuid[,uid])) → wrapped in mask_dots
* 2026-04-14 | IRP5Condense.rmd L716 | tb[1:20] → `{ t <- tb[1:20]; names(t) <- mask_dots(names(t)); t }` (taxrefno values leaked via table names)
* 2026-04-14 | IRP5Condense.rmd L718, L719 | dupuid[...,] bare selects → explicit `.()` with mask_dots
* 2026-04-14 | IRP5Condense.rmd L721-722, L724-726, L729-731 | ipyr[...] selects → mask_dots in .()
* 2026-04-14 | IRP5Condense.rmd L732-736 | split `(dropthese <- ipyr[...])` into raw assign + masked display; table(dropthese[, .(uid, taxrefno)]) and table(dropthese[, uid]) both wrapped with mask_dots. Raw `dropthese` preserved for L754 downstream filter.

