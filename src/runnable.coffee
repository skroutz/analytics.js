define ['settings'], (Settings) ->
  ###
  @mixin
  Intended to be included in any module which accepts commands.
  The recognized commands must be declared as a _commands property.
  ###
  class Runnable
    ###
    Runs any recognized command placed in the command queue,
    then discards it.
    ###
    @run: ->
      for _, cmd of Settings.window[Settings.command_queue_name].q.slice()
        [category, type, args...] = cmd

        if @_commands[category]?[type]?
          @_commands[category][type].apply(@, args)
          Settings.window[Settings.command_queue_name].q.splice(Settings.window[Settings.command_queue_name].q.indexOf(cmd), 1)

      return @

  return Runnable
