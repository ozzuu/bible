switch("path", "$projectDir/../src")
switch("path", "$projectDir/../../src")
switch("path", "$projectDir/../../../src")
switch("path", "$projectDir/../../../../src")
switch("path", "$projectDir/../../../../../src")

switch("define", "ssl")
switch("define", "logueRouteLoose")

when not defined(windows):
  switch("threads", "on")
