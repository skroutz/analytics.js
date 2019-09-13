define [
  'promise'
  'helpers/browser_helper'
  'helpers/url_helper'
], (Promise, BrowserHelper, URLHelper)->
  unique_id = 0

  class Reporter
    constructor: ->
      @transport = 'img'
      @transport_ready = @_determineTransport()

    then: (success, fail) -> @transport_ready.then(success, fail)

    sendBeacon: (url, data) ->
      promise = new Promise()
      @transport_ready.then => @_handleJob url, data, promise
      promise

    _determineTransport: ->
      BrowserHelper.checkImages().then (images_enabled) =>
        @transport = 'script' unless images_enabled

    _handleJob: (url, payload, promise)->
      data = URLHelper.serialize(payload)

      url = URLHelper.appendData(url, data)

      ## WE HAVE A VALID URL THAT CONTAINS THE PAYLOAD
      ## WE MUST CHECK THAT THE URL.length IS BELOW THE MAXIMUM ALLOWED
      ## OTHERWISE WE SHOULD CHUNK THE string AND SEND MULTIPLE TRANSPORTS
      @_createTransport(url, promise)

    _createTransport: (url, promise) ->
      transport_options =
        buster: "#{+new Date()}_#{unique_id++}"

      transport_options.no_images = '' if @transport is 'script'

      element = document.createElement(@transport)
      element.onload = =>
        @_removeElement(element)
        promise.resolve()

      element.onerror = =>
        @_removeElement(element)
        promise.reject()

      element.src = URLHelper.appendData url, URLHelper.serialize(transport_options)

      sibling = document.getElementsByTagName('script')[0]
      sibling.parentNode.insertBefore(element, sibling)

      promise

    _removeElement: (elem) -> elem.parentNode.removeChild(elem) if elem && elem.parentNode

  return Reporter
