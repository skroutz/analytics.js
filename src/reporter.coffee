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
      @chunk_RE = new RegExp(".{1,#{Settings.transport_url_length}}", 'g')

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

      ## WE HAVE A VALID data_string THAT CONTAINS THE PAYLOAD
      ## WE MUST CHECK THAT THE data_string.length IS BELOW THE MAXIMUM ALLOWED
      ## OTHERWISE WE SHOULD CHUNK THE string AND SEND MULTIPLE TRANSPORTS
      if data.length > Settings.transport_url_length - url.length
        ## SHOULD BE MORE UNIQUE
        analytics_session = URLHelper.extractGetParam(Settings.get_param_name, url)
        chunk_package_id = "#{analytics_session}_#{+new Date()}"
        chunks = data.match(@chunk_RE)
        length = chunks.length
        chunk_promises = []

        for chunk, index in chunks
          chunk_promise = new Promise()

          chunk_data = URLHelper.serialize
            chunk_package_id : chunk_package_id
            chunks_length    : length
            chunk_id         : index
            message          : chunk

          chunk_url = URLHelper.appendData(url, chunk_data)
          chunk_promises.push @_createTransport(chunk_promise, chunk_url)

        Promise.all(chunk_promises).then( ->
          promise.resolve()
        , ->
          promise.reject()
        )

      else
        console.log data
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
