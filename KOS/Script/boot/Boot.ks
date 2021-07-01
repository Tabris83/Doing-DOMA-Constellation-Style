//Generic Boot File

set progFile to core:tag:split("|")[0].
if core:tag:split("|"):length > 1
{

  set progParams to core:tag:split("|")[1].
  copypath("0:/"+progFile+".ks","1:/").
  if exists("1:/" + progFile + ".ks"){runpath("1:/" + progFile + ".ks",progParams).}
  else {runpath("0:/" + progFile + ".ks",progParams).}
}
ELSE
{
  copypath("0:/"+progFile+".ks","1:/").
  if exists("1:/" + progFile + ".ks"){runpath("1:/" + progFile + ".ks").}
  else {runpath("0:/" + progFile + ".ks").}
}
