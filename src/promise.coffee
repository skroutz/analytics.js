define ->
  UID = 1

  class Promise
    @_all: (promises, fail_fast) ->
      promise_all = new Promise()
      rejected = false

      results = []
      reject_results = []
      done_count = promises.length
      fail_count = 0

      if done_count is 0
        promise_all.resolve(true)
        return promise_all

      success = (index, result)->
        results[index] = result
        if --done_count is 0
          promise_all.resolve(results)

      fail = (index, result)->
        return if rejected
        reject_results[index] = result

        if fail_fast
          promise_all.reject(result)
          rejected = true
          return

        if ++fail_count is promises.length
          promise_all.reject(reject_results)
        else
          success(index, undefined)

      for promise, index in promises
        bound_success = ((index)->
          return (args...)->
            args.unshift index
            success.apply null, args
        )(index)

        bound_fail = ((index)->
          return (args...)->
            args.unshift index
            fail.apply null, args
        )(index)

        promise.then(bound_success, bound_fail)

      promise_all

    @all: (promises)-> Promise._all(promises, true)

    @any: (promises)-> Promise._all(promises, false)

    constructor: ->
      @_id = UID++
      @state = 'pending'
      @_thens = []

    then: (on_resolve, on_reject) ->
      @_thens.push resolve: on_resolve, reject: on_reject
      @

    resolve: (val) ->
      @_complete 'resolve', val
      @

    reject: (val) ->
      @_complete 'reject', val
      @

    _already: -> throw new Error('Promise already completed.')

    _complete: (which, arg) ->
      resolver = (res, rej) =>
        res and res(arg)
        @

      rejecter = (res, rej) =>
        rej and rej(arg)
        @

      if which is 'resolve'
        @state = 'fulfilled'
        @then = resolver
      else
        @state = 'rejected'
        @then = rejecter

      @resolve = @reject = @_already

      fulfilment[which]?(arg) for fulfilment in @_thens

      delete @_thens

  return Promise
