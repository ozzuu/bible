switch("path", "$projectDir/../src")
switch("path", "$projectDir/../../src")
switch("path", "$projectDir/../../../src")
switch("path", "$projectDir/../../../../src")
switch("path", "$projectDir/../../../../../src")

switch("define", "ssl")

when not defined(windows):
  switch("threads", "on")
