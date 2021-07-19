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
      queue = Settings.window[Settings.command_queue_name].q
      return @ unless queue

      for _, cmd of queue.slice()
        [category, type, args...] = cmd

        if @_commands[category]?[type]?
          @_commands[category][type].apply(@, args)
          queue.splice(queue.indexOf(cmd), 1)

      return @

  return Runnable
