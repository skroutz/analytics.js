define ['settings'], (Settings)->

  ###
    URLHelper module

    A collection of helper methods to handle URIs.
  ###
  URLHelper =

    ###
      Appends a properly constructed query string to the given URL

      @example Append data to a url
        URLHelper.appendData('http://example.com?k=v',
          'foo=bar&shop_code=SA-XXXX-Y')

      @param [String] url The url to append the data to
      @param [String] payload The query string to be appended
      @return [String] The constructed url
    ###
    appendData: (url, payload) ->
      sign = if url.indexOf('?') isnt -1 then '&' else '?'
      "#{url}#{sign}#{payload}"

    ###
      Serializes an object

      @example Serialize an object
        URLHelper.serialize({
          category: 'yogurt'
          type: 'productClick'
          data: {
            product_id: '15400722'
            shop_product_id: '752'
            shop_id: '2032'
          }
        })

      @param [Object] object The object to serialize
      @return [String] The constructed string
    ###
    serialize: (object) ->
      return false if !object or typeof object isnt 'object'
      query_string = ''

      for key, value of object
        value = JSON.stringify(value) if typeof value isnt 'string'
        query_string += "#{encodeURIComponent(key)}=#{encodeURIComponent(value)}&"

      query_string[0...-1]

    ###
      Extracts the requested GET param from a given URL

      @example Extract param from a url
        URLHelper.extractGetParam('shop_code',
          'http://example.com?k=v&foo=bar&shop_code=SA-XXXX-Y')

      @param [String] name The name of the GET param to extract
      @param [String] url The url to query for the requested GET param
      @return [String, null] The value of the requested param or null
    ###
    extractGetParam: (name, url) ->
      extracted = URLHelper.getParamsFromUrl(url)
      return extracted[name] or null

    ###
      Get params from a given URL

      @example Get all params from a URL
        URLHelper.getParamsFromUrl(
          'http://example.com?k=v&foo=bar&shop_code=SA-XXXX-Y')

      @param [String] url The url to extract the GET params from
      @return [Object] The object with the extracted GET params
    ###
    getParamsFromUrl: (url = Settings.url.current) ->
      regex  = /[?&;](.+?)=([^&;]+)/g
      params = {}
      if url
        while match = regex.exec(url)
          params[match[1]] = decodeURIComponent(match[2])
      return params

  return URLHelper
