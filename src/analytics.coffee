define [
  'settings'
  'session'
  'plugins_manager'
  'actions_manager'
], (Settings, Session, PluginsManager, ActionsManager) ->
  class Analytics
    constructor: ->
      plugins_manager = new PluginsManager

      new Session(plugins_manager).run().then (session) =>
        @actions = new ActionsManager(session, plugins_manager).run()
        @_live()

    ###
    Replaces our queue appending global function with one which immediately
    runs commands. Intended for programmatic usage and/or lazy command declaration.
    ###
    _live: ->
      Settings.window[Settings.command_queue_name] = =>
        (Settings.window[Settings.command_queue_name].q ||= []).push(arguments)
        @actions.run()

  return Analytics
