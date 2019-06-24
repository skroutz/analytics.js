define [
  'settings'
  'promise'
  'runnable'
  'biskoto'
  'session_engines/xdomain_engine'
], (Settings, Promise, Runnable, Biskoto, XDomainEngine) ->
  class Session
    Session::[key] = method for key, method of Runnable

    constructor: (@plugins_manager) ->
      @promise = new Promise()
      @_cleanUpCookies()
      @analytics_session = @_getCookieAnalyticsSession()

    then: (success, fail) -> @promise.then(success, fail)

    _commands:
      session:
        create: (shop_code, flavor, metadata) ->
          @shop_code = shop_code
          @metadata = metadata

          @_extractAnalyticsSession('create', shop_code, flavor, encodeURIComponent(JSON.stringify(metadata)))

        connect: (shop_code)->
          # connect should be called only once
          return console?.warn?('Connect called multiple times') if @shop_code

          @shop_code = shop_code
          @plugins_manager.session = @

          @plugins_manager.notify('connect', {})

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

    _extractAnalyticsSession: (type, shop_code, flavor, metadata) ->
      new XDomainEngine(type, shop_code, flavor, metadata)
        .then(@_onSessionSuccess, @_onSessionError)

    _onSessionError: => @promise.reject()

    _onSessionSuccess: (result) =>
      if analytics_session = result
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
