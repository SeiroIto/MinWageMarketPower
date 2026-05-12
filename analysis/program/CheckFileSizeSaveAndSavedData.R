filenames <- c( "irp5_BeforeDroppingRepetitiveUIDs.qs", 
  "irp5_WithRepetetiveUIDs.qs"
  "GeoLocationFile.qs", 
  "GeoLocFile.qs", 
  "smallIRP5.qs", 
  "GeoLF.qs"
  "irp5_MergedGeoLF.qs", 
  "irp5_CopiedLocMuniFromGeoLoc.qs", 
  "irp5_RevReports.qs", 
  "ObPattern.qs",
  "irp5Clean.qs", 
  "irp5.qs",
  "irp5a.qs",
  "MeanStdNOfEmployment.tsv")
pathsavefiles <- paste0(pathdata, filenames)
pathsaveddatafiles <- paste0(pathsaveddata, filenames)
fsize <- function(x) file.info(x)$size
(SizeCompare <- data.table(
      filename      = filenames,
    , pathsave      = unlist(lapply(pathsavefiles, fsize))
    , pathsaveddata = unlist(lapply(pathsaveddatafiles, fsize))
  ))

