switch("path", "$projectDir/../src")
switch("path", "$projectDir/../../src")
switch("path", "$projectDir/../../../src")
switch("path", "$projectDir/../../../../src")
switch("path", "$projectDir/../../../../../src")

switch("define", "ssl")
switch("define", "logueRouteLoose")
switch("deepcopy", "on")

when not defined(windows):
  switch("threads", "on")
