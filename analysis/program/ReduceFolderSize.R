library(readstata13)
datadat <-  data.table(read.dta13("seiro_ito.dta"))
datadat[, folder := factor(gsub("^.*ito\\/(.*?)\\/.*", "\\1", dirname))]
datadat[, folder := factor(gsub(".*michael.*", "michael", folder))]
datadat[, subfolder := factor(gsub("^.*ito\\/(.*?\\/.*?)\\/.*", "\\1", dirname))]
unique(datadat[, folder])
datadat[, unique(dirname), by = folder]
datadat[, fsizeGB := round(fsize/1e+9, 1)]
datadat[grep("data$", folder), .(GB = round(sum(fsize)/1e+9, 1)), by =  folder]
datadat[grepl("ito\\/data$", dirname), ][order(-fsize)][1:50, .(filename, fsizeGB)]

