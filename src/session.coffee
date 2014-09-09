define [
  'settings'
  'promise'
  'easyxdm'
  'biskoto'
  'helpers/url_helper'
], (Settings, Promise, easyXDM, Biskoto, URLHelper)->

  ###
    Session Class

    Session is responsible to establish and maintain an cross-domain Analytics
    Tracking Session. It looks up for 1st and 3rd party cookies and if they do
    exist it (re-)connects to a Session, else it creates a new one. It utilizes
    the easyXDM plugin for cross-domain communication.

    @see https://github.com/hull/easyXDM easyXDM - easy Cross-Domain Messaging
  ###
  class Session

    ###
      Constructs a new Session object

      Clear expired cookies and try to establish an Analytics Tracking Session.

      @option [Object] parsed_settings The object that holds our Sites' Session
        ID.
    ###
    constructor: (parsed_settings = {})->
      @easyXDM = easyXDM
      @promise = new Promise()

      @_cleanUpCookies()

      @yogurt_session = parsed_settings.yogurt_session or null
      @analytics_session = @_getCookieAnalyticsSession()

      @_establishSession(@yogurt_session, @analytics_session)

    ###
      Provides access to the current or eventual value or reason

      @param [Function] success The callback to invoke after promise is fulfilled
      @param [Function] fail The callback to invoke after promise is rejected
    ###
    then: (success, fail)-> @promise.then(success, fail)

    ###
      Establishes the Session

      @param [String] yogurt_session Our Sites' Session ID
      @param [String] analytics_session The Analytics Session ID
      @return [Promise] The promise to establish (or not) a session
    ###
    _establishSession: (yogurt_session, analytics_session)->
      # When in `/track/create/` phase, always create 3rd party cookie on
      # Analytics domain.
      if analytics_session isnt null and yogurt_session is null
        # @todo Should `expires` attr be reset if cookie already exists?
        @promise.resolve analytics_session
      else
        @socket = @_createSocket @_socketUrl(yogurt_session)
        @_extractAnalyticsSession()

    ###
      Retrieves the Analytics Tracking Session

      Try to extract an existing Analytics Tracking Session either from a 3rd
      party cookie or a GET param.

      @return [Promise] The promise of Analytics Tracking Session extraction
    ###
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

    ###
      Clears expired cookies
    ###
    _cleanUpCookies: ->
      cookie_settings = Settings.cookies
      cookie_name = cookie_settings.analytics.name
      cookie_data = Biskoto.get(cookie_name)
      return unless cookie_data

      if cookie_data.version isnt cookie_settings.version or !cookie_settings.first_party_enabled
        Biskoto.expire(cookie_name)

    ###
      Extracts the Analytics Session ID from `document.cookie`

      @return [String, null] The Analytics Session ID if exists or null
    ###
    _getCookieAnalyticsSession: ->
      data = Biskoto.get(Settings.cookies.analytics.name)
      if data then data.analytics_session else null

    ###
      Persists a 1st party cookie with the Analytics Session ID

      @param [String] analytics_session The Analytics Session ID
    ###
    _createFirstPartyCookie: (analytics_session)->
      return unless Settings.cookies.first_party_enabled

      cookie_data =
        version: Settings.cookies.version
        analytics_session: analytics_session

      Biskoto.set Settings.cookies.analytics.name, cookie_data,
        expires: Settings.cookies.analytics.duration

    ###
      Registers the Analytics Tracking Session

      @param [String] analytics_session The Analytics Session ID
      @return [Promise] The current session's promise
    ###
    _registerAnalyticsSession: (analytics_session)->
      @analytics_session = analytics_session
      @promise.resolve analytics_session

    ###
      Extracts the Analytics Session ID from GET params

      @return [Promise] The current session's promise
    ###
    _extractFromGetParam: ->
      promise = new Promise()
      promise.resolve URLHelper.extractGetParam(Settings.params.analytics_session)

    ###
      Extracts the Analytics Session ID from the Analytics iFrame

      @return [Promise] The current session's socket promise
    ###
    _extractFromIframe: ->
      @socket.promise = new Promise()
      @socket.postMessage(Settings.iframe_message)
      @socket.promise

    ###
      Listens for easyXDM.Socket messages

      @param [String] analytics_session The incoming message
      @param [String] origin The origin of the message
    ###
    _onSocketMessage: (analytics_session, origin)=>
      return unless origin is Settings.url.base
      @socket.promise.resolve analytics_session

    ###
      Retrieves the proper easyXDM.Socket url

      When within our sites the url points at the new Analytics Tracking Session
      endpoint.
      When within one of our partners' website the url points at the connect to
      an existing Analytics Tracking Session.

      @param [String] yogurt_session Our Site's Session ID
      @return [String] The proper Analytics Session endpoint
    ###
    _socketUrl: (yogurt_session)->
      if yogurt_session
        socket_url = Settings.url.analytics_session.create(yogurt_session)
      else
        socket_url = Settings.url.analytics_session.connect()
      socket_url

    ###
      Registers an easyXDM.Socket

      @see https://github.com/hull/easyXDM easyXDM - easy Cross-Domain Messaging

      @param [String] url The endpoint to listen
      @return [easyXDM.Socket] The easyXDM.Socket object
    ###
    _createSocket: (url)->
      new @easyXDM.Socket
        remote    : url
        onMessage : @_onSocketMessage

  return Session
