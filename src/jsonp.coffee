define [
  'promise'
  'helpers/url_helper'
], (Promise, URLHelper) ->
  ###
  Tiny library to handle JSONP requests
  ###
  uid = 0

  class JSONP
    CALLBACK_PARAM = 'callback'

    ###
    Get JSONP data for cross-domain AJAX requests

    @example JSONP.fetch(http://example.com, { param: 'param',.. })

    @param [String] url The URL of the JSONP request
    @param [Object] data Any additional data passed as url parameters
    @return [Promise] A promise in order to get the response
    ###
    @fetch  = (url, data = {}) ->
      promise = new Promise()
      callback_name = JSONP._callbackName()
      window[callback_name] = (response) -> promise.resolve(response)

      data[CALLBACK_PARAM] = callback_name

      JSONP.load(url, data)

      promise

    ###
    Insert script tag into the DOM (append to <head>)

    Note: Can also be used to load scripts.

    @example JSONP.load(http://example.com, { param: 'param',.. })

    @param [String] url The URL of the external resource to load
    @param [Object] data Any additional data passed as url parameters
    ###
    @load = (url, data) ->
      done = false
      script = document.createElement('script')
      script.type = 'text/javascript'
      script.src = if data then JSONP._query(url, data) else url
      script.async = true

      script.onload = script.onreadystatechange = ->
        if !done && (!@readyState || (@readyState in ['loaded', 'complete']))
          done = true
          # Handle memory leak in IE
          script.onload = script.onreadystatechange = null
          # Remove the script
          script.parentNode.removeChild(script) if script && script.parentNode

      document.getElementsByTagName('head')[0].appendChild(script)

    @_callbackName = -> "analytics_jsonp_#{++uid}"
    @_query = (url, data) -> URLHelper.appendData(url, URLHelper.serialize(data))

  return JSONP
