define [
  'settings'
  'promise'
  'runnable'
  'biskoto'
  'session_engines/get_param_engine'
  'session_engines/xdomain_engine'
], (Settings, Promise, Runnable, Biskoto, GetParamEngine, XDomainEngine) ->
  class Session
    Session::[key] = method for key, method of Runnable

    constructor: ->
      @promise = new Promise()
      @_cleanUpCookies()
      @analytics_session = @_getCookieAnalyticsSession()

    then: (success, fail) -> @promise.then(success, fail)

    _commands:
      session:
        create: (shop_code, yogurt_session, yogurt_user_id, flavor) ->
          @shop_code = shop_code
          @yogurt_session = yogurt_session
          @yogurt_user_id = yogurt_user_id
          @flavor = flavor

          @_extractAnalyticsSession('create', shop_code, yogurt_session, yogurt_user_id, flavor)

        connect: (shop_code)->
          @shop_code = shop_code

          return @promise.resolve(@) if @analytics_session

          @_extractAnalyticsSession('connect', shop_code)

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

    _extractAnalyticsSession: (type, shop_code, yogurt_session, yogurt_user_id, flavor) ->
      Promise.any([
        (new XDomainEngine(type, shop_code, yogurt_session, yogurt_user_id, flavor))
        (new GetParamEngine())
      ]).then(@_onSessionSuccess, @_onSessionError)

    _onSessionError: => @promise.reject()

    _onSessionSuccess: (results) =>
      if analytics_session = results[0] or results[1]
        @_createFirstPartyCookie(analytics_session)
        @analytics_session = analytics_session
        @promise.resolve(@)
      else
        @promise.reject()

    _createFirstPartyCookie: (analytics_session) ->
      return unless Settings.cookies.first_party_enabled

      cookie_data =
        version: Settings.cookies.version
        analytics_session: analytics_session

      Biskoto.set Settings.cookies.analytics.name, cookie_data,
        expires: Settings.cookies.analytics.duration

  return Session
