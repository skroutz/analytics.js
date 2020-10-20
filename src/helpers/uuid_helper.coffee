###
Tiny library to generate version 4 UUIDs

References:
  http://www.ietf.org/rfc/rfc4122.txt
  https://github.com/kelektiv/node-uuid
  https://gist.github.com/jed/982883
###
define ->
  if window.crypto
    random = -> window.crypto.getRandomValues(new Uint32Array(1))[0] / 4294967295
    rng = 'cr'
  else if window.msCrypto # for IE 11
    random = -> window.msCrypto.getRandomValues(new Uint32Array(1))[0] / 4294967295
    rng = 'ms'
  else
    random = Math.random
    rng = 'ra'

  UUID_TEMPLATE = "#{rng}-10000000-1000-4000-8000-100000000000"

  # algorithm from https://gist.github.com/jed/982883
  UUID =
    generate: (placeholder) ->
      if placeholder
        # if the placeholder was passed,
        # return a random number from 0 to 15
        # unless placeholder is 8,
        # in which case a random number from 8 to 11
        # in hexadecimal
        (placeholder ^ random() * 16 >> placeholder/4).toString(16)
      else
        # or otherwise a template string replacing
        # zeroes, ones, and eights with random hex digits
        UUID_TEMPLATE.replace(/[018]/g, UUID.generate)

  return UUID
