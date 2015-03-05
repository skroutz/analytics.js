define [
  'settings'
  'promise'
  'easyxdm'
], (Settings, Promise, easyXDM)->
  class XDomainEngine
    constructor: (type, shop_code = '', yogurt_session = '',
                  yogurt_user_id = '')->
      @promise = new Promise()
      @url = Settings.url.analytics_session[type](shop_code, yogurt_session,
        yogurt_user_id)

      @socket = @_createSocket @url
      @timeout = @_checkForSocketTimeout()
    then: (success, fail)-> @promise.then(success, fail)

    _timeout_message: 'XDomain retrieval of analytics_session timed out'
    _nonexistant_message: 'Analytics_session does not exist'

    _checkForSocketTimeout: ->
      setTimeout((=> @promise.reject(@_timeout_message)),
        Settings.xdomain_session_timeout)

    _onSocketReady: => @socket.postMessage(Settings.iframe_message)

    _onSocketMessage: (analytics_session, origin)=>
      return unless origin is Settings.url.base
      @timeout and clearTimeout(@timeout)

      if analytics_session is ''
        @promise.reject(@_nonexistant_message)
      else
        @promise.resolve(analytics_session)

    _createSocket: (url)-> new easyXDM.Socket
      remote: url
      onMessage: @_onSocketMessage
      onReady: @_onSocketReady

  return XDomainEngine
