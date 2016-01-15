define [
  'settings'
  'session'
  'plugins_manager'
  'actions_manager'
], (Settings, Session, PluginsManager, ActionsManager) ->
  class Analytics
    constructor: ->
      new Session().run().then (session) =>
        plugins_manager = new PluginsManager(session)
        @actions = new ActionsManager(session, plugins_manager).run()
        @_live()

    ###
    Replaces our queue appending global function with one which immediately
    runs commands. Intended for programmatic usage and/or lazy command declaration.
    ###
    _live: ->
      Settings.window.sa = =>
        (Settings.window.sa.q ||= []).push(arguments)
        @actions.run()

  return Analytics
