allTestFiles = []
TEST_REGEXP = /(spec|test)\.js$/i

Object.keys(window.__karma__.files).forEach (file) ->
  allTestFiles.push(file) if TEST_REGEXP.test(file)

require.config
  #Karma serves files under /base, which is the basePath from your config file
  baseUrl: '/base/src'
  paths: {
    'easyxdm': '../compiled/vendor/easyXDM'
  }
  #dynamically load all test files
  deps: allTestFiles

  # we have to kickoff jasmine, as it is asynchronous
  callback: window.__karma__.start
