define [
  'settings'
  'promise'
  'runnable'
  'biskoto'
  'session_engines/xdomain_engine'
  'analytics_url'
  'domain_extractor'
  'helpers/uuid_helper'
], (Settings, Promise, Runnable, Biskoto, XDomainEngine, AnalyticsUrl, DomainExtractor, UUID) ->
  class Session
    Session::[key] = method for key, method of Runnable

    constructor: (@plugins_manager) ->
      @promise = new Promise()
      @domain = new DomainExtractor(Settings.url.hostname).get()
      @_cleanUpCookies()
      [@analytics_session, @cookie_policy] = @_getSessionFromCookie()
      @transaction_id = UUID.generate()

    then: (success, fail) -> @promise.then(success, fail)

    _commands:
      session:
        create: (shop_code, flavor, metadata) ->
          @cookie_policy = if metadata.cp == 'b' then 'basic' else 'full'

          @shop_code = shop_code
          @flavor = flavor
          @metadata = metadata

          @_extractAnalyticsSessionOnCreate()

        connect: (shop_code)->
          # connect should be called only once
          return console?.warn?('Connect called multiple times') if @shop_code

          @shop_code = shop_code
          @metadata = @_getMetadataFromCookie() if @cookie_policy

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
      Biskoto.get(Settings.cookies[@cookie_policy].meta.name)

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
        try
          session = JSON.parse(session)

          @analytics_session = session.session
          @cookie_policy = session.cookie_policy
        catch # TODO remove me after successfully transition to new mechanism
          @analytics_session = session
          @cookie_policy = 'full'

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

      options = expires: Settings.cookies[@cookie_policy].analytics.duration
      options.domain = @domain if @domain

      Biskoto.set Settings.cookies[@cookie_policy].analytics.name, cookie_data, options

    _createSessionCookie: ->
      session_data =
        version: Settings.cookies.version
        session: @analytics_session

      options = expires: Settings.cookies[@cookie_policy].session.duration
      options.domain = @domain if @domain

      Biskoto.set Settings.cookies[@cookie_policy].session.name, session_data, options

      # Delete other's cookie policy's cookie
      delete_cookie = if @cookie_policy == 'basic' then 'full' else 'basic'
      Biskoto.expire Settings.cookies[delete_cookie].session.name, options

    _createMetadataCookie: ->
      options = { domain: @domain } if @domain

      Biskoto.set Settings.cookies[@cookie_policy].meta.name, @metadata, options

      # Delete other's cookie policy's cookie
      delete_cookie = if @cookie_policy == 'basic' then 'full' else 'basic'
      Biskoto.expire Settings.cookies[delete_cookie].meta.name, options

  return Session
