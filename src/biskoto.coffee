define ->
  ###
    A light version of the [Biskoto](https://github.com/skroutz/biskoto) module
    to manipulate the `document.cookie`.
  ###
  class Biskoto
    encode = encodeURIComponent
    decode = decodeURIComponent

    ###
      Retrieves the value for a given property of `document.cookie`

      @example Get the Analytics Session ID from `document.cookie`.
        Biskoto.get('analytics_session')

      @param [String] name The name of the property to retrieve
      @return [Object, null] The retrieved value as key-value object
    ###
    @get: (name) ->
      if document.cookie
        cookies = document.cookie.split(/;\s/g)

        for cookie in cookies
          if cookie.indexOf(name) is 0
            value = decode(cookie.split('=')[1])
            try
              return JSON.parse(value)
            catch err
              return value

      return null

    ###
      Sets a new `document.cookie` property

      @example Set the Analytics Session ID to `document.cookie`.
        Biskoto.set('analytics_session', 'analytics-47fd-8df3-277e55b7',
          {expires: 60})

      @param [String] name The key of the property to set
      @param [Object] value The value of the property to set
      @option [Object] options The options for the new property
    ###
    @set: (name, value, options = {}) ->
      document.cookie = "#{name}=#{encode( JSON.stringify(value) )}#{@_cookieOptions(options)}"

    ###
      Forces a cookie to expire

      @param [String] name The name of the cookie to expire
      @option [Object] options Options for the cookie to expire

      @todo Clean up. Param options really needed?
    ###
    @expire: (name, options = {}) ->
      options.expires = -1
      @set(name, '', options)

    ###
      Constructs a string out of a given set of options that is ready to be
        appended to `document.cookie`.

      @example Build the cookie string for given options
        Biskoto._cookieOptions({
          expires : 60                    // Integer in seconds
          secure  : false                 // Boolean
          domain  : 'http://example.com'  // String
          path    : '/foo/bar/'           // String
        })

      @option [Object] options The options to parse
      @return [String] The `document.cookie` ready string
    ###
    @_cookieOptions: (options = {}) ->
      cookie_str = ''

      for key, value of options
        if key is 'expires'
          cookie_str += "; expires=#{@_createExpireDate(options.expires)}"
        else if key is 'domain'
          cookie_str += "; domain=#{value}"

      cookie_str += "; path=#{if options.path then options.path else '/'}"

    ###
      Calculates the expiration date of a cookie for given seconds

      @param [Number] seconds The time to live of cookie in seconds
      @return [String] The expiration date of the cookie
    ###
    @_createExpireDate: (seconds) ->
      new Date(
        +new Date() + (seconds * 1000)
      ).toUTCString()

  return Biskoto
