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
    SHOP_COOKIE_OPTIONS = ['full', 'basic']

    constructor: (@plugins_manager) ->
      @promise = new Promise()
      @domain = new DomainExtractor(Settings.url.hostname).get()
      @_cleanUpCookies()
      [@analytics_session, @cookie_policy] = @_getSessionFromCookie()

    then: (success, fail) -> @promise.then(success, fail)

    _commands:
      session:
        create: (shop_code, flavor, metadata) ->
          @cookie_policy = if metadata.cp == 'b' then 'basic' else 'full'

          @shop_code = shop_code
          @flavor = flavor
          @metadata = metadata
          @shop_cookie_policy = 'full'

          @_extractAnalyticsSessionOnCreate()

        connect: (shop_code, shop_cookie_policy = 'full')->
          return console?.warn?('Connect called without a shop code') unless shop_code

          # connect should be called only once
          return console?.warn?('Connect called multiple times') if @shop_code

          @shop_code = shop_code
          @shop_cookie_policy = if shop_cookie_policy in SHOP_COOKIE_OPTIONS then shop_cookie_policy else 'full'
          @metadata = @_getMetadataFromCookie() if @cookie_policy

          @_unsetFullCookies() if @shop_cookie_policy == 'basic'

          @plugins_manager.session = @
          @plugins_manager.notify('connect', {})

          skr_prm = new AnalyticsUrl(Settings.url.current).read_params()
          @_setAnalyticsSession(skr_prm)
          @_setAnalyticsMetadata(skr_prm)

          [@analytics_session, @cookie_policy] = @_getSessionFromCacheCookie() unless @analytics_session

          return @promise.resolve(@) if @analytics_session

          @_extractAnalyticsSessionOnConnect('connect', shop_code)

    _cleanUpCookies: ->
      cookie_settings = Settings.cookies
      options = { domain: @domain } if @domain

      cookies = [
        cookie_settings.basic.analytics.name, cookie_settings.basic.session.name
        cookie_settings.full.analytics.name, cookie_settings.full.session.name
      ]

      for cookie_name in cookies
        cookie_data = Biskoto.get(cookie_name)
        continue unless cookie_data

        if cookie_data.version isnt cookie_settings.version
          Biskoto.expire(cookie_name, options)

    _getSessionFromCacheCookie: ->
      if data = Biskoto.get(Settings.cookies.full.analytics.name)
        [data.analytics_session, 'full']
      else if data = Biskoto.get(Settings.cookies.basic.analytics.name)
        [data.analytics_session, 'basic']
      else
        [null, null]

    _getSessionFromCookie: ->
      if data = Biskoto.get(Settings.cookies.full.session.name)
        [data.session, 'full']
      else if data = Biskoto.get(Settings.cookies.basic.session.name)
        [data.session, 'basic']
      else
        [null, null]

    _getMetadataFromCookie: ->
      if data = Biskoto.get(Settings.cookies.full.meta.name)
        data
      else
        Biskoto.get(Settings.cookies.basic.meta.name)

    _extractAnalyticsSessionOnCreate: ->
      new XDomainEngine('create',
                        @shop_code,
                        @flavor,
                        @analytics_session,
                        @cookie_policy,
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
        session = JSON.parse(session)

        @analytics_session = session.session
        @cookie_policy = session.cookie_policy

        @_createSessionCacheCookie(@analytics_session)

        @promise.resolve(@)
      else
        @promise.reject()

    _setAnalyticsSession: (skr_prm) ->
      return unless skr_prm?.session

      @analytics_session = skr_prm.session
      @cookie_policy = if skr_prm.metadata.cp == 'b' then 'basic' else 'full'

      @_createSessionCookie()

    _setAnalyticsMetadata: (skr_prm) ->
      return unless skr_prm?.metadata

      @metadata = skr_prm.metadata
      @_createMetadataCookie()

    _createSessionCacheCookie: (analytics_session) ->
      cookie_data =
        version: Settings.cookies.version
        analytics_session: analytics_session

      basic_options = expires: Settings.cookies.basic.analytics.duration
      basic_options.domain = @domain if @domain
      Biskoto.set Settings.cookies.basic.analytics.name, cookie_data, basic_options

      if @cookie_policy == 'full' && @shop_cookie_policy == 'full'
        full_options = expires: Settings.cookies.full.analytics.duration
        full_options.domain = @domain if @domain
        Biskoto.set Settings.cookies.full.analytics.name, cookie_data, full_options

    _createSessionCookie: ->
      session_data =
        version: Settings.cookies.version
        session: @analytics_session

      basic_options = expires: Settings.cookies.basic.session.duration
      basic_options.domain = @domain if @domain
      Biskoto.set Settings.cookies.basic.session.name, session_data, basic_options

      full_options = expires: Settings.cookies.full.session.duration
      full_options.domain = @domain if @domain
      if @cookie_policy == 'full' && @shop_cookie_policy == 'full'
        Biskoto.set Settings.cookies.full.session.name, session_data, full_options

      # Delete full cookie if user changed preferences
      full_cookie = Biskoto.get Settings.cookies.full.session.name
      if full_cookie && (@cookie_policy == 'basic' || @shop_cookie_policy == 'basic')
        Biskoto.expire Settings.cookies.full.session.name, full_options

    _createMetadataCookie: ->
      options = { domain: @domain } if @domain

      Biskoto.set Settings.cookies.basic.meta.name, @metadata, options
      if @cookie_policy == 'full' && @shop_cookie_policy == 'full'
        Biskoto.set Settings.cookies.full.meta.name, @metadata, options

      # Delete full cookie if user changed preferences
      full_cookie = Biskoto.get Settings.cookies.full.meta.name
      if full_cookie && (@cookie_policy == 'basic' || @shop_cookie_policy == 'basic')
        Biskoto.expire Settings.cookies.full.meta.name, options

    _unsetFullCookies: ->
      if @analytics_session
        options = expires: Settings.cookies.full.session.duration
        options.domain = @domain if @domain
        session_cookie = Biskoto.get Settings.cookies.full.session.name
        Biskoto.expire Settings.cookies.full.session.name, options if session_cookie

      if @metadata
        options = { domain: @domain } if @domain
        metadata_cookie = Biskoto.get Settings.cookies.full.meta.name
        Biskoto.expire Settings.cookies.full.meta.name, options if metadata_cookie

      options = expires: Settings.cookies.full.analytics.duration
      options.domain = @domain if @domain
      cache_cookie = Biskoto.get(Settings.cookies.full.analytics.name)
      Biskoto.expire Settings.cookies.full.analytics.name, options if cache_cookie

  return Session
