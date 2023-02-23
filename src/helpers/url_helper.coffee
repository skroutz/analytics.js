define ['settings'], (Settings)->
  URLHelper =
    appendData: (url, payload) ->
      hash_index = url.indexOf('#')
      [main_url, hash] = if hash_index isnt -1
                           [url.substring(0, hash_index), url.substring(hash_index)]
                         else
                           [url, '']

      sign = if main_url.indexOf('?') isnt -1 then '&' else '?'
      "#{main_url}#{sign}#{payload}#{hash}"

    replaceParam: (url, name, new_value) ->
      # Find param escaped or not
      # Note: param name with regex special characters is not supported
      regex = new RegExp("(.*[?&;](#{encodeURIComponent(name)}|#{name})=)([^&;]+)(.*)")

      url.replace(regex, "$1#{encodeURIComponent(new_value)}$4") # https://stackoverflow.com/a/3954957

    serialize: (object) ->
      return false if !object or typeof object isnt 'object'
      query_string = ''

      for key, value of object
        value = JSON.stringify(value) if typeof value isnt 'string'
        query_string += "#{encodeURIComponent(key)}=#{encodeURIComponent(value)}&"

      query_string[0...-1]

    extractGetParam: (name, url) ->
      extracted = URLHelper.getParamsFromUrl(url)
      return extracted[name] or null

    # https://stackoverflow.com/a/1099670/4375736
    getParamsFromUrl: (url = Settings.url.current) ->
      url = url.split('#')[0] # drop hash from url, if exists
      regex  = /[?&;](.*?)=([^&;]*)/g
      params = {}

      while match = regex.exec(url)
        params[decodeURIComponent(match[1])] = decodeURIComponent(match[2])

      params

  return URLHelper
