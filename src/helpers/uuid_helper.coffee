###
Library to generate version 4 UUIDs

Code taken from:
  https://github.com/kelektiv/node-uuid/tree/v3.3.3

References:
  http://www.ietf.org/rfc/rfc4122.txt
###
define ->
  UUID =
    # _cryptoObj, _rng(), _whatwgRNG() and _mathRNG() were taken from:
    # https://github.com/kelektiv/node-uuid/blob/v3.3.3/lib/rng-browser.js
    _cryptoObj: window.crypto or window.msCrypto # for IE 11

    # Unique ID creation requires a high quality random # generator.  In the
    # browser this is a little complicated due to unknown quality of Math.random()
    # and inconsistent support for the `crypto` API.  We do the best we can via
    # feature-detection
    _rng: () -> if UUID._cryptoObj then UUID._whatwgRNG() else UUID._mathRNG()

    # WHATWG crypto RNG - http://wiki.whatwg.org/wiki/Crypto
    _whatwgRNG: () ->
      rnds8 = new Uint8Array(16);

      UUID._cryptoObj.getRandomValues(rnds8)

      rnds8

    # Math.random()-based (RNG)

    # If all else fails, use Math.random().  It's fast, but is of unspecified
    # quality.
    _mathRNG: () ->
      rnds = new Array(16);

      for i in [0...16]
        r = Math.random() * 0x100000000 if (i & 0x03) == 0
        rnds[i] = r >>> (i & 0x03) << 3 & 0xff

      rnds

    # _bytesToUuid() and _byteToHex were taken from:
    # https://github.com/kelektiv/node-uuid/blob/v3.3.3/lib/bytesToUuid.js
    #
    # Convert array of 16 byte values to UUID string format of the form:
    # XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
    _byteToHex: do ->
      byteToHex = []
      byteToHex[i] = (i + 0x100).toString(16).substr(1) for i in [0...256]

    _bytesToUuid: (buf, offset) ->
      i = offset or 0
      bth = UUID._byteToHex
      # join used to fix memory issue caused by concatenation: https://bugs.chromium.org/p/v8/issues/detail?id=3175#c4
      [
        bth[buf[i++]], bth[buf[i++]]
        bth[buf[i++]], bth[buf[i++]], '-'
        bth[buf[i++]], bth[buf[i++]], '-'
        bth[buf[i++]], bth[buf[i++]], '-'
        bth[buf[i++]], bth[buf[i++]], '-'
        bth[buf[i++]], bth[buf[i++]]
        bth[buf[i++]], bth[buf[i++]]
        bth[buf[i++]], bth[buf[i++]]
      ].join ''

    # generate() was taken from:
    # https://github.com/kelektiv/node-uuid/blob/v3.3.3/v4.js
    generate: (options, buf, offset) ->
      i = buf and offset or 0

      if typeof options == 'string'
        buf = if options == 'binary' then new Array(16) else null
        options = null
      options = options or {}

      rnds = options.random or (options.rng or UUID._rng)()

      # Per 4.4, set bits for version and `clock_seq_hi_and_reserved`
      rnds[6] = rnds[6] & 0x0f | 0x40
      rnds[8] = rnds[8] & 0x3f | 0x80

      # Copy bytes to buffer, if provided
      (buf[i + ii] = rnds[ii] for ii in [0...16]) if buf

      buf or UUID._bytesToUuid(rnds)

  return UUID
