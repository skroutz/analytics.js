define [
  'session'
  'actions_manager'
], (Session, ActionsManager) ->
  class Analytics
    constructor: ->
      new Session().run().then (session) ->
        new ActionsManager(session).run()
