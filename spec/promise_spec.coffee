describe 'Promise', ->
  @timeout(0) # Disable the spec's timeout

  before (done) ->
    require ['promise'], (Promise) =>
      @promise = Promise

      @fooSuccess = (val) -> val
      @fooFailure = (val) -> val

      done()

  beforeEach (done) ->
    @subject = new @promise()
    @pr = @subject.then @fooSuccess, @fooFailure
    done()

  describe 'API', ->
    it 'has own property #state', ->
      expect(@subject).to.have.ownProperty('state')

    it 'responds to #then', ->
      expect(@subject).to.respondTo('then')

    it 'responds to #resolve', ->
      expect(@subject).to.respondTo('resolve')

    it 'responds to #reject', ->
      expect(@subject).to.respondTo('reject')

    it 'responds to .all', ->
      expect(@promise).itself.to.respondTo('all')

  describe '#state', ->
    context 'when instantiated', ->
      it 'has pending state', ->
        expect(@pr.state).to.equal 'pending'

    context 'when resolved', ->
      it 'has fulfilled state', ->
        @pr.resolve()
        expect(@pr.state).to.equal 'fulfilled'

    context 'when rejected', ->
      it 'has rejected state', ->
        @pr.reject()
        expect(@pr.state).to.equal 'rejected'

  describe '#then', (done) ->
    it 'pushes the correct success callback function', ->
      expect(@pr._thens[0].resolve)
        .to.equal @fooSuccess

    it 'pushes the correct failure callback function', ->
      expect(@pr._thens[0].reject)
        .to.equal @fooFailure

    it 'sets the initial promise state to pending', ->
      expect(@pr.state).to.equal 'pending'

    it 'returns a promise', (done) ->
      expect(@pr)
        .to.be.an.instanceof @promise
      done()

  describe '#resolve', ->
    it 'returns its own promise instance', ->
      expect(@subject.resolve('foo'))
        .to.be.equal @subject

    it 'calls the success callback with correct params', ->
      spy = sinon.spy(@, 'fooSuccess')

      @subject.then @fooSuccess, @fooFailure
      @subject.resolve('foo')

      expect(spy.withArgs('foo').calledOnce)
        .to.be.true

      spy.restore()

    it 'changes the promise state to fulfilled', (done) ->
      @subject.resolve true
      expect(@pr.state)
        .to.equal 'fulfilled'
      done()

  describe '#reject', ->
    it 'returns its own promise instance', ->
      expect(@subject.reject('foo'))
        .to.be.equal @subject

    it 'calls the failure callback with correct params', ->
      spy = sinon.spy(@, 'fooFailure')

      @subject.then @fooSuccess, @fooFailure
      @subject.reject('foo')

      expect(spy.withArgs('foo').calledOnce)
        .to.be.true

      spy.restore()

    it 'changes the promise state to rejected', ->
      @subject.reject false
      expect(@pr.state).to.equal 'rejected'

  describe '.all', ->
    beforeEach ->
      @fn1 = ->
        promise = new @promise()
        promise.resolve 'val1'

      @fn2 = ->
        promise = new @promise()
        promise.resolve 'val2'

      @fn3 = ->
        promise = new @promise()
        promise.reject 'val3'

    it 'returns a promise', ->
      expect(@promise.all([@fn1(), @fn2()]))
        .to.be.an.instanceof @promise

    context 'when is fulfilled', ->
      beforeEach (done) ->
        @pr = @promise.all([@fn1(), @fn2()])
        done()

      it 'sets the promise state to fulfilled', ->
        expect(@pr.state).to.equal 'fulfilled'

      it 'returns an array with proper length', ->
        @pr.then (results) ->
          expect(results)
            .to.be.an('array')
            .and
            .to.have.length(2)

      it 'returns proper arguments', ->
        @pr.then (results) ->
          expect(results).to.eql ['val1', 'val2']

    context 'when is rejected', ->
      beforeEach (done) ->
        @pr = @promise.all([@fn1(), @fn2(), @fn3()])
        done()

      it 'sets the state to rejected', ->
        expect(@pr.state).to.equal 'rejected'

      it 'calls fail', ->
        spy = sinon.spy(@, 'fooFailure')

        @pr.then @fooSuccess, @fooFailure

        expect(spy.calledOnce)
          .to.be.true

        spy.restore()
