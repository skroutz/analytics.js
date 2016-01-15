define [
  'settings'
  'session'
  'actions_manager'
], (Settings, Session, ActionsManager) ->
  class Analytics
    constructor: ->
      new Session().run().then (session) =>
        @actions = new ActionsManager(session).run()
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
