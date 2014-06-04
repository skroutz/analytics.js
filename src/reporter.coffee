define [
  'settings'
  'promise'
  'helpers/browser_helper'
  'helpers/url_helper'
], (Settings, Promise, BrowserHelper, URLHelper)->
  unique_id = 1

  class Reporter
    constructor: (options)->
      @base = Settings.url.base
      @queue = []
      @transport = 'img'

      @transport_ready = @_determineTransport()

    then: (success, fail) -> @transport_ready.then(success, fail)

    report: (url, actions) ->
      if Settings.single_beacon
        promise = new Promise()
        @transport_ready.then =>
          @_handleJob url, actions, promise
        promises = [promise]
      else
        promises =
          for action in actions
            promise = new Promise()
            @transport_ready.then =>
              @_handleJob url, action, promise
            promise

      Promise.all(promises)

    _determineTransport: ->
      BrowserHelper.checkImages().then (images_enabled) =>
        @transport = 'script' unless images_enabled

    _handleJob: (url, payload, promise)->
      if payload instanceof Array
        data = URLHelper.serialize(payload, true)
      else
        data = URLHelper.serialize(payload)

      url = URLHelper.appendData(url, data)

      ## WE HAVE A VALID URL THAT CONTAINS THE PAYLOAD
      ## WE MUST CHECK THAT THE URL.length IS BELOW THE MAXIMUM ALLOWED
      ## OTHERWISE WE SHOULD CHUNK THE string AND SEND MULTIPLE TRANSPORTS
      @_createTransport(promise, url)

    _createTransport: (promise, url) ->
      cache_buster = "buster=#{+new Date()}_#{unique_id++}"
      element = document.createElement(@transport)

      element.onload = -> promise.resolve()
      element.onerror = -> promise.reject()
      element.src = URLHelper.appendData(url, cache_buster)

      sibling = document.getElementsByTagName('script')[0]
      sibling.parentNode.insertBefore(element, sibling)

      promise

  return Reporter
