define [
  'settings'
  'reporter'
  'promise'
  'helpers/url_helper'
], (Settings, Reporter, Promise, URLHelper)->
  class ActionsManager
    constructor: () ->
      @reporter = new Reporter()
      @callbacks = []
      @actions = []
      @shop_code_val = null
      @actions_queue = window[Settings.actions_queue_name] ?= []
      @redirect_data = null

      @_parseActions()

    redirect: (analytics_session) ->
      return unless @redirect_data
      data = {}
      data[Settings.get_param_name] = analytics_session
      url = URLHelper.appendData @redirect_data.url, URLHelper.serialize(data)
      setTimeout (->
        window.location.replace url
      ), @redirect_data.time
      @

    sendTo: (url) ->
      promises =
        (for action in @actions
          action.url = Settings.url.current
          action.shop_code_val = @shop_code_val if @shop_code_val

          @reporter.report(url, action)
        )

      Promise.all(promises).then => callback() for callback in @callbacks

    _parseActions: ->
      while item = @actions_queue.pop()
        if typeof item is 'function' then @callbacks.push item
        else if item[0] is Settings.api.shop_code_key then @shop_code_val = item[1]
        else if item[0] is Settings.api.redirect_key
          @redirect_data =
            url: item[1]
            time: parseInt(item[2],10) or 0
        else
          @actions.push type: item[0], data: (item[1] || '')

      @actions.push {type: 'visit'} unless @actions.length
      return

  return ActionsManager
