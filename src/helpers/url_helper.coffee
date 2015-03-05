define ['settings'], (Settings)->
  URLHelper =
    appendData: (url, payload) ->
      sign = if url.indexOf('?') isnt -1 then '&' else '?'
      "#{url}#{sign}#{payload}"

    serialize: (object) ->
      return false if !object or typeof object isnt 'object'
      query_string = ''

      for key, value of object
        value = JSON.stringify(value) if typeof value isnt 'string'
        query_string += "#{encodeURIComponent(key)}="
        query_string += "#{encodeURIComponent(value)}&"

      query_string[0...-1]

    extractGetParam: (name, url) ->
      extracted = URLHelper.getParamsFromUrl(url)
      return extracted[name] or null

    getParamsFromUrl: (url = Settings.url.current) ->
      regex  = /[?&;](.+?)=([^&;]+)/g
      params = {}
      if url
        while match = regex.exec(url)
          params[match[1]] = decodeURIComponent(match[2])
      return params

  return URLHelper
