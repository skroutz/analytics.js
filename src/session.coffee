define [
  'settings'
  'promise'
  'biskoto'
  'session_engines/get_param_engine'
  'session_engines/xdomain_engine'
], (Settings, Promise, Biskoto, GetParamEngine, XDomainEngine)->
  class Session
    constructor: (type, data = {})->
      @promise = new Promise()

      @_cleanUpCookies()
      @analytics_session = @_getCookieAnalyticsSession()

      @shop_code = data.shop_code or null
      @yogurt_session = data.yogurt_session or null
      @yogurt_user_id = data.yogurt_user_id or null

      if type is 'connect' and @analytics_session
        @promise.resolve @analytics_session
      else
        # Always try to create third party cookie in 'create'
        @_extractAnalyticsSession(type, @shop_code, @yogurt_session,
          @yogurt_user_id)

    then: (success, fail)-> @promise.then(success, fail)

    _cleanUpCookies: ->
      cookie_settings = Settings.cookies
      cookie_name = cookie_settings.analytics.name
      cookie_data = Biskoto.get(cookie_name)
      return unless cookie_data

      cookies_enabled = cookie_settings.first_party_enabled

      if cookie_data.version isnt cookie_settings.version or !cookies_enabled
        Biskoto.expire(cookie_name)

    _getCookieAnalyticsSession: ->
      data = Biskoto.get(Settings.cookies.analytics.name)
      if data then data.analytics_session else null

    _extractAnalyticsSession: (type, shop_code, yogurt_session,
                               yogurt_user_id)->
      Promise.any([
        (new XDomainEngine(type, shop_code, yogurt_session, yogurt_user_id))
        (new GetParamEngine())
      ]).then @_onSessionSuccess, @_onSessionError

    _onSessionError: => @promise.reject()

    _onSessionSuccess: (results) =>
      if analytics_session = results[0] or results[1]
        @_createFirstPartyCookie(analytics_session)
        @analytics_session = analytics_session
        @promise.resolve analytics_session
      else
        @promise.reject()

    _createFirstPartyCookie: (analytics_session)->
      return unless Settings.cookies.first_party_enabled

      cookie_data =
        version: Settings.cookies.version
        analytics_session: analytics_session

      Biskoto.set Settings.cookies.analytics.name, cookie_data,
        expires: Settings.cookies.analytics.duration

  return Session
