define ['settings'], (Settings)->
  URLHelper =
    appendData: (url, payload) ->
        sign = if url.indexOf('?') isnt -1 then '&' else '?'
        "#{url}#{sign}#{payload}"

    serialize: (object, should_stringify = false) ->
      query_string = ''

      for key, value of object
        value = JSON.stringify(value) if should_stringify
        query_string += "#{encodeURIComponent(key)}=#{encodeURIComponent(value)}&"

      query_string[0...-1]

    extractGetParam: (name) ->
      extracted = URLHelper.getParamsFromUrl()
      return extracted[name] or null

    getParamsFromUrl: (url = Settings.window.location.href) ->
      regex  = /[?&;](.+?)=([^&;]+)/g
      params = {}
      if url
        while match = regex.exec(url)
          params[match[1]] = decodeURIComponent(match[2])
      return params

  return URLHelper
