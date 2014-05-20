define [
  'settings'
  'promise'
  'easyxdm'
  'biskoto'
], (Settings, Promise, easyXDM, Biskoto)->
  class Session
    constructor: ()->
      @easyXDM = easyXDM
      @promise = new Promise()

      @analytics_session = null
      @yogurt_session = Biskoto.get('yogurt_session')

      @socket = @_createSocket()
      @_requestTrackingId()

    then: (callback)-> @promise.then(callback)

    _onSocketMessage: (message, origin)=>
      ## TODO Implement more? security checks on origin
      return unless origin is Settings.url.base

      @analytics_session = message
      @promise.resolve message

    _createSocket: ->
      if @yogurt_session
        url = Settings.url.analytics_session.create(yogurt_session)
      else
        url = Settings.url.analytics_session.connect()

      new @easyXDM.Socket
        remote    : url
        onMessage : @_onSocketMessage

    _requestTrackingId: -> @socket.postMessage('get_analytics_session')

  return Session
