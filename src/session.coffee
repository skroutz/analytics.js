define [
  'settings'
  'promise'
  'easyxdm'
  'biskoto'
  'helpers/url_helper'
], (Settings, Promise, easyXDM, Biskoto, URLHelper)->
  class Session
    constructor: ()->
      @easyXDM = easyXDM
      @promise = new Promise()

      @analytics_session = Biskoto.get(Settings.cookies.analytics.name)
      @yogurt_session = Biskoto.get(Settings.cookies.yogurt.name)

      if @analytics_session isnt null
        ## TODO: SHOULD BE RE-SET expires ATTRIBUTE IF COOKIE ALREADY EXISTS?
        @promise.resolve @analytics_session
      else
        @socket = @_createSocket @_socketUrl(@yogurt_session)
        @_getAnalyticsSession()

    then: (success, fail)-> @promise.then(success, fail)

    _getAnalyticsSession: ->
      Promise.all([
        @_extractIframe()
        @_extractGetParam()
      ]).then (results) =>
        analytics_session = results[0] or results[1]

        if analytics_session
          @_createFirstPartyCookie(analytics_session)
          @_registerAnalyticsSession(analytics_session)
        else
          @promise.reject()

    _createFirstPartyCookie: (analytics_session)->
      return unless Settings.cookies.first_party_enabled

      Biskoto.set Settings.cookies.analytics.name, analytics_session,
        expires: Settings.cookies.analytics.duration

    _registerAnalyticsSession: (analytics_session)->
      @analytics_session = analytics_session
      @promise.resolve analytics_session

    _extractGetParam: ->
      promise = new Promise()
      promise.resolve URLHelper.extractGetParam(Settings.get_param_name)

    _extractIframe: ->
      @socket.promise = new Promise()
      @socket.postMessage('get_analytics_session')
      @socket.promise

    _onSocketMessage: (analytics_session, origin)=>
      return unless origin is Settings.url.base
      @socket.promise.resolve analytics_session

    _socketUrl: (yogurt_session)->
      if yogurt_session
        socket_url = Settings.url.analytics_session.create(yogurt_session)
      else
        socket_url = Settings.url.analytics_session.connect()
      socket_url

    _createSocket: (url)->
      new @easyXDM.Socket
        remote    : url
        onMessage : @_onSocketMessage

  return Session
