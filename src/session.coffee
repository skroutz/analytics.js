define [
  'settings'
  'promise'
  'easyxdm'
  'biskoto'
  'helpers/url_helper'
], (Settings, Promise, easyXDM, Biskoto, URLHelper)->
  class Session
    constructor: (parsed_settings = {})->
      @easyXDM = easyXDM
      @promise = new Promise()

      @_cleanUpCookies()

      @yogurt_session = parsed_settings.yogurt_session or null
      @analytics_session = @_getCookieAnalyticsSession()

      @_establishSession(@yogurt_session, @analytics_session)

    then: (success, fail)-> @promise.then(success, fail)

    _establishSession: (yogurt_session, analytics_session)->
      # Always create third party cookie on analytics domain
      # if on create phase
      if analytics_session isnt null and yogurt_session is null
        ## TODO: SHOULD BE RE-SET expires ATTRIBUTE IF COOKIE ALREADY EXISTS?
        @promise.resolve analytics_session
      else
        @socket = @_createSocket @_socketUrl(yogurt_session)
        @_extractAnalyticsSession()

    _extractAnalyticsSession: ->
      Promise.all([
        @_extractFromIframe()
        @_extractFromGetParam()
      ]).then (results) =>
        analytics_session = results[0] or results[1]

        if analytics_session
          @_createFirstPartyCookie(analytics_session)
          @_registerAnalyticsSession(analytics_session)
        else
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

    _extractFromGetParam: ->
      promise = new Promise()
      promise.resolve URLHelper.extractGetParam(Settings.params.analytics_session)

    _extractFromIframe: ->
      @socket.promise = new Promise()
      @socket.postMessage(Settings.iframe_message)
      @socket.promise

    _onSocketMessage: (analytics_session, origin)=>
      return unless origin is Settings.url.base
      @socket.promise.resolve analytics_session

    _socketUrl: (yogurt_session)->
      if yogurt_session
        socket_url = Settings.url.analytics_session.create(yogurt_session)
      else
        socket_url = Settings.url.analytics_session.connect()
      URLHelper.appendData socket_url, "cookie_version=#{Settings.cookies.version}"

    _createSocket: (url)->
      new @easyXDM.Socket
        remote    : url
        onMessage : @_onSocketMessage

  return Session
