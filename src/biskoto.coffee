define ->
  class Biskoto
    encode = encodeURIComponent
    decode = decodeURIComponent

    @get: (name) ->
      if document.cookie
        cookies = decode(document.cookie).split(/;\s/g)

        for cookie in cookies
          if cookie.indexOf(name) is 0
            try
              return JSON.parse(cookie.split('=')[1])
            catch err
              return cookie.split('=')[1]

      return null

    @set: (name, value, options = {}) ->
      document.cookie = "#{name}=#{JSON.stringify(value)}#{@_cookieOptions(options)}"

    @expire: (name, options = {}) ->
      options.expires = -1
      @set(name, '', options)

    ###
      options = {
        expires : Integer (seconds)
        secure  : Boolean
        domain  : String
        path    : String
      }
    ###
    @_cookieOptions: (options = {}) ->
      cookie_str = ''

      for key, value of options
        if key is 'expires'
          cookie_str += "; expires=#{@_createExpireDate(options.expires)}"
        # else if key is 'secure' and window.location.href.indexOf('https') is 0
        #   cookie_str += "; secure"
        else if key is 'domain'
          cookie_str += "; domain=#{value}"

      cookie_str += "; path=#{if options.path then options.path else '/'}"

    @_createExpireDate: (seconds) ->
      new Date(
        +new Date() + (seconds * 1000)
      ).toUTCString()

  window.Biskoto = Biskoto
  return Biskoto
