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

      @_determineTransport().then @_enableProperJobHandler

    report: (url, payload) ->
      promise = new Promise()

      @_handleJob url, payload, promise
      promise

    _determineTransport: ->
      BrowserHelper.checkImages().then (images_enabled)->
        @transport = 'script' unless images_enabled

    _enableProperJobHandler: =>
      @_handleJob = @_properHandleJob
      while job_args = @queue.reverse().pop()
        @_handleJob.apply this, job_args

    _handleJob: -> @queue.push arguments

    _properHandleJob: (url, payload, promise)->
      data = URLHelper.serialize payload, true
      url = URLHelper.appendData(url, data)

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
