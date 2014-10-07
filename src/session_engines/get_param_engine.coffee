define [
  'settings'
  'promise'
  'helpers/url_helper'
], (Settings, Promise, URLHelper)->
  class GetParamEngine
    constructor: ->
      @promise = new Promise()

      value = URLHelper.extractGetParam(Settings.params.analytics_session) or null
      if value then @promise.resolve(value) else @promise.reject(@_nonexistant_message)
      return

    then: (success, fail)-> @promise.then(success, fail)

    _nonexistant_message: 'Analytics_session does not exist'

  return GetParamEngine