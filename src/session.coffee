define [
  'settings'
  'promise'
  'biskoto'
  'session_engines/get_param_engine'
  'session_engines/xdomain_engine'
], (Settings, Promise, Biskoto, GetParamEngine, XDomainEngine)->
  class Session
    constructor: (parsed_settings = {})->
      @promise = new Promise()

      @_cleanUpCookies()

      @yogurt_session = parsed_settings.yogurt_session or null
      @shop_code = parsed_settings.shop_code or null
      @yogurt_user_id = parsed_settings.yogurt_user_id or ''

      @analytics_session = @_getCookieAnalyticsSession()

      @_establishSession(@yogurt_session, @analytics_session, @yogurt_user_id, @shop_code)

    then: (success, fail)-> @promise.then(success, fail)

    _establishSession: (yogurt_session, analytics_session, yogurt_user_id, shop_code)->
      # Always create third party cookie on analytics domain
      # if on create phase
      if analytics_session isnt null and yogurt_session is null
        ## TODO: SHOULD BE RE-SET expires ATTRIBUTE IF COOKIE ALREADY EXISTS?
        @promise.resolve analytics_session
      else
        @_extractAnalyticsSession(yogurt_session, yogurt_user_id, shop_code)

    _extractAnalyticsSession: (yogurt_session, yogurt_user_id, shop_code)->
      Promise.all([
        (new XDomainEngine(yogurt_session, yogurt_user_id, shop_code))
        (new GetParamEngine())
      ]).then ((results)=>
        analytics_session = results[0] or results[1]

        if analytics_session
          @_createFirstPartyCookie(analytics_session)
          @_registerAnalyticsSession(analytics_session)
        else
          @promise.reject()
      ), =>
         @promise.reject()

    _cleanUpCookies: ->
      cookie_settings = Settings.cookies
      cookie_name = cookie_settings.analytics.name
      cookie_data = Biskoto.get(cookie_name)
      return unless cookie_data

      if cookie_data.version isnt cookie_settings.version or !cookie_settings.first_party_enabled
        Biskoto.expire(cookie_name)

    _getCookieAnalyticsSession: ->
      data = Biskoto.get(Settings.cookies.analytics.name)
      if data then data.analytics_session else null

    _createFirstPartyCookie: (analytics_session)->
      return unless Settings.cookies.first_party_enabled

      cookie_data =
        version: Settings.cookies.version
        analytics_session: analytics_session

      Biskoto.set Settings.cookies.analytics.name, cookie_data,
        expires: Settings.cookies.analytics.duration

    _registerAnalyticsSession: (analytics_session)->
      @analytics_session = analytics_session
      @promise.resolve analytics_session

  return Session
