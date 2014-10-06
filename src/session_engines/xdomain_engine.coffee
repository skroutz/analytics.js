define [
  'settings'
  'promise'
  'easyxdm'
], (Settings, Promise, easyXDM)->
  class XDomainEngine
    constructor: (yogurt_session = '', yogurt_user_id = '', shop_code = '')->
      @promise = new Promise()
      @socket = @_createSocket @_socketUrl(yogurt_session, yogurt_user_id, shop_code)
      @timeout = @_checkForSocketTimeout()

    then: (success, fail)-> @promise.then(success, fail)

    _checkForSocketTimeout: -> setTimeout (=> @promise.reject('timeout')), Settings.xdomain_session_timeout

    _onSocketReady: => @socket.postMessage(Settings.iframe_message)

    _onSocketMessage: (analytics_session, origin)=>
      return unless origin is Settings.url.base
      @timeout and clearTimeout(@timeout)
      @promise.resolve analytics_session

    _socketUrl: (yogurt_session, yogurt_user_id, shop_code)->
      url = Settings.url.analytics_session
      if yogurt_session
        url.create(yogurt_session, yogurt_user_id, shop_code)
      else
        url.connect(shop_code)

    _createSocket: (url)-> new easyXDM.Socket
      remote: url
      onMessage: @_onSocketMessage
      onReady: @_onSocketReady

  return XDomainEngine