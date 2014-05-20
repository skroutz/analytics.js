define ->
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

  return URLHelper
