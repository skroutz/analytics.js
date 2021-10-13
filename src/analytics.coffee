define [
  'settings'
  'session'
  'plugins_manager'
  'actions_manager'
], (Settings, Session, PluginsManager, ActionsManager) ->
  class Analytics
    constructor: ->
      console.log('Kokolala2')
      @plugins_manager = new PluginsManager
      @session = new Session(@plugins_manager)
      @actions = null

      if Settings.window[Settings.command_queue_name].q?.length > 0
        @_handle_session()
      else
        ###
        Replaces our queue appending global function with one which immediately
        runs commands when the commands array is empty or undefined.
        Intended for programmatic usage and/or lazy command declaration.
        ###
        Settings.window[Settings.command_queue_name] = =>
          (Settings.window[Settings.command_queue_name].q ||= []).push(arguments)
          @_handle_session()

    ###
    Handles the session commands. If a session is acquired the promise is resolved and
    the ActionManager is instantiated. If a session is not acquired then this function
    will be called for every command that enters the queue until we acquire a session.
    ###
    _handle_session: ->
      @session.run().then (session) =>
        return unless session

        @actions = new ActionsManager(session, @plugins_manager)
        @_live()

    ###
    Replaces our queue appending global function with one which immediately
    runs commands. Intended for programmatic usage and/or lazy command declaration.
    ###
    _live: ->
      @actions.run()

      Settings.window[Settings.command_queue_name] = =>
        (Settings.window[Settings.command_queue_name].q ||= []).push(arguments)
        @actions.run()

  return Analytics
