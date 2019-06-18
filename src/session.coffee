define [
  'settings'
  'promise'
  'runnable'
  'biskoto'
  'session_engines/xdomain_engine'
  'analytics_url'
  'domain_extractor'
], (Settings, Promise, Runnable, Biskoto, XDomainEngine, AnalyticsUrl, DomainExtractor) ->
  class Session
    Session::[key] = method for key, method of Runnable

    constructor: (@plugins_manager) ->
      @promise = new Promise()
      @domain = new DomainExtractor(Settings.url.hostname).get()
      @_cleanUpCookies()
      @analytics_session = @_getSessionFromCookie()

    then: (success, fail) -> @promise.then(success, fail)

    _commands:
      session:
        create: (shop_code, flavor, metadata) ->
          @shop_code = shop_code
          @flavor = flavor
          @metadata = metadata

          @_extractAnalyticsSessionOnCreate()

        connect: (shop_code)->
          # connect should be called only once
          return console?.warn?('Connect called multiple times') if @shop_code

          @shop_code = shop_code
          @metadata = @_getMetadataFromCookie()

          @plugins_manager.session = @
          @plugins_manager.notify('connect', {})

          skr_prm = new AnalyticsUrl(Settings.url.current).read_params()
          @_setAnalyticsSession(skr_prm)
          @_setAnalyticsMetadata(skr_prm)

          @analytics_session ||= @_getSessionFromCacheCookie()
          return @promise.resolve(@) if @analytics_session

          @_extractAnalyticsSessionOnConnect('connect', shop_code)

    _cleanUpCookies: ->
      cookie_settings = Settings.cookies
      options = { domain: @domain } if @domain

      for cookie_name in [cookie_settings.analytics.name, cookie_settings.session.name]
        cookie_data = Biskoto.get(cookie_name)
        continue unless cookie_data

        if cookie_data.version isnt cookie_settings.version
          Biskoto.expire(cookie_name, options)

    _getSessionFromCacheCookie: ->
      data = Biskoto.get(Settings.cookies.analytics.name)
      if data then data.analytics_session else null

    _getSessionFromCookie: ->
      data = Biskoto.get(Settings.cookies.session.name)
      if data then data.session else null

    _getMetadataFromCookie: ->
      Biskoto.get(Settings.cookies.meta.name)

    _extractAnalyticsSessionOnCreate: ->
      new XDomainEngine('create',
                        @shop_code,
                        @flavor,
                        @analytics_session,
                        encodeURIComponent(JSON.stringify(@metadata)))
        .then(@_onCreateSessionSuccess, @_onSessionError)

    _extractAnalyticsSessionOnConnect: ->
      new XDomainEngine('connect', @shop_code)
        .then(@_onConnectSessionSuccess, @_onSessionError)

    _onSessionError: => @promise.reject()

    _onCreateSessionSuccess: (session) =>
      if session
        @analytics_session = session
        @_createSessionCookie()

        @promise.resolve(@)
      else
        @promise.reject()

    _onConnectSessionSuccess: (session) =>
      if session
        @analytics_session = session
        @_createSessionCacheCookie(session)

        @promise.resolve(@)
      else
        @promise.reject()

    _setAnalyticsSession: (skr_prm) ->
      return unless skr_prm?.session

      @analytics_session = skr_prm.session
      @_createSessionCookie()

    _setAnalyticsMetadata: (skr_prm) ->
      return unless skr_prm?.metadata

      @metadata = skr_prm.metadata
      @_createMetadataCookie()

    _createSessionCacheCookie: (analytics_session) ->
      cookie_data =
        version: Settings.cookies.version
        analytics_session: analytics_session

      options = expires: Settings.cookies.analytics.duration
      options.domain = @domain if @domain

      Biskoto.set Settings.cookies.analytics.name, cookie_data, options

    _createSessionCookie: ->
      session_data =
        version: Settings.cookies.version
        session: @analytics_session

      options = expires: Settings.cookies.session.duration
      options.domain = @domain if @domain

      Biskoto.set Settings.cookies.session.name, session_data, options

    _createMetadataCookie: ->
      options = { domain: @domain } if @domain

      Biskoto.set Settings.cookies.meta.name, @metadata, options

  return Session
