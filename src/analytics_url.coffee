define [
  'helpers/url_helper'
  'helpers/base64_helper'
], (URLHelper, Base64)->

  ###
  Handles encoding/appending and decoding of Analytics params in URLs.
  Links created by this module will have a life of `TTL` milliseconds, encoded in them.
  ###
  class AnalyticsUrl
    URL_PARAM_NAME = 'skr_prm'
    TTL = 60 * 1000 # milliseconds

    ###
    Creates an AnalyticsUrl handler for the given `url`, either for appending Analytics params or reading them.
    @param [String] url The URL to process
    ###
    constructor: (@url) ->

    ###
    Formats Analytics params into this URL as a single, base64 encoded, param.
    The returned url will also contain encoded info about its expiration.

    `mode` specifies the way the param should be appended and must contain the field `type`.
    `mode.type` can be:
    * "default" - the param is appended into the url
    * "append_to_param_link_url" - the actual target link is encoded in a param of the url
      eg. https://link.go/?lnkurl=https%3A%2F%2Fshop.gr%2Fproduct so the Analytics param is inserted into
      the link param specified by `mode.param` ("lnkurl" in the above example).
      It is expected that the user will eventually be redirected to the actual target link.

    @param [Object] mode How to append the data into the url
    @param [String] session Analytics session
    @param [Object] metadata Extra data such as app type and tags
    @return [String] A new url containing the Analytics params
    ###
    format_params: (mode, session, metadata = {}) ->
      params = [session, @_expiration(), metadata]
      param_hash = Base64.encodeURI JSON.stringify(params)

      switch mode.type
        when 'no_append'
          @url
        when 'append_to_param_link_url'
          link = URLHelper.extractGetParam(mode.param, @url)
          new_link = URLHelper.appendData(link, "#{URL_PARAM_NAME}=#{param_hash}")

          URLHelper.replaceParam(@url, mode.param, new_link)
        else # treat all other cases as { type: 'default' }
          URLHelper.appendData(@url, "#{URL_PARAM_NAME}=#{param_hash}")

    ###
    Reads Analytics params as encoded by #format_params.
    Returns null if the url has expired or the data are missing or malformed.

    @return [Object, null] { session: [String], metadata: [Object] }
    ###
    read_params: ->
      url_param = Base64.decode URLHelper.extractGetParam(URL_PARAM_NAME, @url)
      try
        params = JSON.parse(url_param)
      catch err # invalid JSON
        return null

      [session, expiration, metadata] = params

      return null if expiration < new Date().getTime() # current link has expired

      { session, metadata }

    _expiration: ->
      new Date().getTime() + TTL

  return AnalyticsUrl
