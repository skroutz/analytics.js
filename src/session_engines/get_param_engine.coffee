define [
  'settings'
  'promise'
  'helpers/url_helper'
], (Settings, Promise, URLHelper)->
  class GetParamEngine
    constructor: ->
      @promise = new Promise()

      value = URLHelper.extractGetParam(Settings.params.analytics_session) or null

      @promise.resolve(value)

    then: (success, fail)-> @promise.then(success, fail)

  return GetParamEngine