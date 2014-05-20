define ['settings','reporter'], (Settings, Reporter)->
  class ActionsManager
    constructor: () ->
      @reporter = new Reporter()
      @callbacks = []
      @actions = []
      @shop_code_val = null
      @actions_queue = Settings.actions_queue

      @_parseActions()

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
        else
          @actions.push type: item[0], data: (item[1] || '')

      @actions.push {type: 'visit'} unless @actions.length
      return

  return ActionsManager
