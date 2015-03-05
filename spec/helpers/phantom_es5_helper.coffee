unless Function::bind
  Function::bind = (oThis) ->
    # closest thing possible to the ECMAScript 5
    # internal IsCallable function
    err = 'Function.prototype.bind - what is trying to be bound is not callable'
    if typeof this isnt 'function'
      throw new TypeError(err)

    aArgs = Array::slice.call(arguments, 1)
    fToBind = this
    fNOP = -> undefined
    fBound = ->
      fThis = (if this instanceof fNOP and oThis then this else oThis)
      fArgs = aArgs.concat(Array::slice.call(arguments))
      fToBind.apply fThis, fArgs

    fNOP:: = @::
    fBound:: = new fNOP()
    fBound
