define [
  'settings'
  'reporter'
  'promise'
  'helpers/url_helper'
], (Settings, Reporter, Promise, URLHelper)->

  ###
    ActionsManager Class

    ActionsManager handles the Analytics Actions. It is responsible to parse the
    collected Analytics Actions in Settings.actions_queue, prepare them, and
    finally pass them to Reporter. Also, will invoke all callbacks or redirects
    if any is set.
  ###
  class ActionsManager

    ###
      Constructs a new ActionsManager object

      Check actions in Settings.actions_queue, parse them and prepare them for
      report.
    ###
    constructor: () ->
      @reporter = new Reporter()
      @parsed_settings = {}
      @callbacks = []
      @actions = []
      @shop_code = null
      @actions_queue = Settings.actions_queue
      @redirect_data = null

      @_parseActions()

    ###
      Executes the redirect action

      The method is invoked after all actions have been reported.

      @param [String] analytics_session The current Analytics Session ID
      @return [ActionsManager] This object
    ###
    redirect: (analytics_session) ->
      return unless @redirect_data
      data = {}
      data[Settings.params.analytics_session] = analytics_session
      url = URLHelper.appendData @redirect_data.url, URLHelper.serialize(data)
      setTimeout (->
        Settings.redirectTo url
      ), @redirect_data.time
      @

    ###
      Sends actions to Reporter

      @param [String] url The base endpoint to create a new Analytics Action
      @return [Promise] The Reporter promise
    ###
    sendTo: (url) ->
      payload = @_prepareData(@actions)

      @reporter.report(url, payload).then =>
        callback() for callback in @callbacks

    ###
      Gets the parsed settings that hold our sites' session

      @return [Object] The parsed settings
    ###
    getSettings: -> @parsed_settings

    ###
      Prepares the payload with proper format and properties

      The payload is constructed as an array of Action objects. The array will
      contain only 1 item when the Application runs in single beacon mode, and
      1 or more items when in multiple beacon mode.

      @see Settings.single_beacon Set the beacon mode of Application

      @param [Object] data The parsed Analytics Actions
      @return [Array] The array of actions ready for Reporter

      @todo Refactor me.
    ###
    _prepareData: (data)->
      result = []
      params = Settings.params

      ## TODO REFACTOR
      if Settings.single_beacon
        payload = {}
        payload[params.url] = Settings.url.current
        payload[params.shop_code] = @shop_code if @shop_code
        payload[params.actions] = data
        result.push payload
      else
        for action in data
          payload = {}
          payload[params.url] = Settings.url.current
          payload[params.shop_code] = @shop_code if @shop_code
          payload[params.actions] = [action]
          result.push payload

      return result

    ###
      Parses the collected Analytics Actions

      Loops the Analytics Actions queue and constructs an Array of internal
      actions (callback functions and redirects) and the actions to be reported.

      If no actions were defined, it will push an `site:pageview` action.

      @see Settings.api The Analytics API literals to expect
    ###
    _parseActions: ->
      api = Settings.api
      while item = @actions_queue.pop()
        switch item[1]
          when api.settings.yogurt_session
            @parsed_settings.yogurt_session = item[2]
          when api.settings.set_account
            @shop_code = item[2]
          when api.settings.set_callback
            @callbacks.push item[2]
          when api.settings.redirect_to
            @redirect_data =
              url: item[2]
              time: parseInt(item[3],10) or 0
          else
            action = {
              category: item[0]
              type: item[1]
              data: item[2]
            }
            action.sig = item[3] if item[0] is api.ecommerce.key and item[3]

            @actions.push action

      @actions.push {category: api.site.key, type: api.site.send_pageview} unless @actions.length

      return

  return ActionsManager
