define [
  'settings'
  'promise'
  'helpers/browser_helper'
], (Settings, Promise, BrowserHelper)->
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
      data = @_serialize payload
      url = @_appendToURL(url, data)

      @_createTransport(promise, url)

    _appendToURL: (url, payload) ->
      sign = if url.indexOf('?') isnt -1 then '&' else '?'
      "#{url}#{sign}#{payload}"

    _serialize: (object) ->
      query_string = ''

      for key, value of object
        value = JSON.stringify(value)
        query_string += "#{encodeURIComponent(key)}=#{encodeURIComponent(value)}&"

      query_string[0...-1]

    _createTransport: (promise, url) ->
      cache_buster = "buster=#{+new Date()}_#{unique_id++}"
      element = document.createElement(@transport)

      element.onload = -> promise.resolve()
      element.onerror = -> promise.reject()
      element.src = @_appendToURL(url, cache_buster)

      sibling = document.getElementsByTagName('script')[0]
      sibling.parentNode.insertBefore(element, sibling)

      promise

  return Reporter
