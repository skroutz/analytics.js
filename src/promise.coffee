define ->
  # A unique incremental number assigned to each promise
  UID = 1

  ###
    A tiny yet effective cross-browser implementation of Promises/A+ spec.
  ###
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

    ###
      Wraps an Array of Promises as a compound Promise.

      The main promise will be fulfilled if all of the given promises get
      fulfilled. If at least one of the given promises gets rejected then the
      compound promise will get rejected too.

      @example Wrap two promise objects as one.
        new Promise().all([new Promise(), new Promise()])

      @param [Array] promises The array of promises to wrap
      @return [Promise] The compound promise
    ###
    @all: (promises)-> Promise._all(promises, true)

    @any: (promises)-> Promise._all(promises, false)

    ###
      Constructs a new Promise object
    ###
    constructor: ->
      @_id = UID++
      @state = 'pending'
      @_thens = []

    ###
      Appends fulfillment and rejection handlers to the promise

      @param [Function] on_resolve The fulfillment handler of the promise
      @param [Function] on_reject The rejection handler of the promise
      @return [Promise] This instance
    ###
    then: (on_resolve, on_reject) ->
      @_thens.push resolve: on_resolve, reject: on_reject
      @

    ###
      Fulfillment handler of a promise

      @param [Object] val Arguments to pass to the fulfillment handler
      @return [Promise] This instance
    ###
    resolve: (val) =>
      @_complete 'resolve', val
      @

    ###
      Rejection handler of a promise

      @param [Object] val Arguments to pass to the rejection handler
      @return [Promise] This instance
    ###
    reject: (val) =>
      @_complete 'reject', val
      @

    ###
      Do not allow a promise to change state. If a promise that is already
      completed (resolved or rejected) tries to change its value, an error
      is thrown.
    ###
    _already: -> throw new Error('Promise already completed.')

    ###
      Marks a promise as fulfilled or rejected and invokes the proper handler
      with any arguments.

      @param [String] ('resolve'|'reject') which Whether to fulfilll or reject
        the promise.
      @param [Object] arg Arguments to pass to the invoked callback
    ###
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
