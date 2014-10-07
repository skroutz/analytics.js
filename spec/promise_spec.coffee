describe 'Promise', ->
  before (done) ->
    @param = 'asdasd'

    require ['promise'], (Promise) =>
      @promise = Promise

      @fooSuccess = sinon.spy()
      @fooFailure = sinon.spy()

      done()

  beforeEach (done) ->
    @subject = new @promise()
    @pr = @subject.then @fooSuccess, @fooFailure
    done()

  afterEach ->
    @fooSuccess.reset()
    @fooFailure.reset()

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
    it 'sets the initial promise state to pending', ->
      expect(@pr.state).to.equal 'pending'

    it 'returns the same promise', (done) ->
      expect(@pr).to.equal @subject
      done()

    context 'when promise is not yet fulfilled', ->
      it 'pushes the correct success callback function', ->
        expect(@pr._thens[0].resolve)
          .to.equal @fooSuccess

      it 'pushes the correct failure callback function', ->
        expect(@pr._thens[0].reject)
          .to.equal @fooFailure

      context 'when the promise gets resolved', ->
        beforeEach ->
          @subject.resolve(@param)
          return

        it 'executes resolve callbacks', ->
          expect(@fooSuccess).to.be.calledOnce

        it 'does not execute reject callbacks', ->
          expect(@fooFailure).to.not.be.called

        it 'passed resolve argument to resolve callbacks', ->
          expect(@fooSuccess).to.be.calledWith @param

      context 'when the promise gets rejected', ->
        beforeEach ->
          @subject.reject(@param)
          return

        it 'executes reject callbacks', ->
          expect(@fooFailure).to.be.calledOnce

        it 'does not execute resolve callbacks', ->
          expect(@fooSuccess).to.not.be.called

        it 'passed reject argument to reject callbacks', ->
          expect(@fooFailure).to.be.calledWith @param

    context 'when promise is already resolved', ->
      beforeEach ->
        @subject = new @promise().resolve(@param)
        return

      context 'when a resolve callback is passed', ->
        beforeEach ->
          @pr = @subject.then @fooSuccess, @fooFailure
          return

        it 'executes the resolve callback', ->
          expect(@fooSuccess).to.be.calledOnce

        it 'passed resolve argument to callback', ->
          expect(@fooSuccess).to.be.calledWith @param

      context 'when a resolve callback is not passed', ->
        it 'does not throw error', ->
          expect(=> @subject.then(undefined, @fooFailure)).to.not.throw(/.*/)

      context 'when a reject callback is passed', ->
        beforeEach ->
          @pr = @subject.then @fooSuccess, @fooFailure
          return

        it 'does not execute the reject callback', ->
          expect(@fooFailure).to.not.be.called

      context 'when a reject callback is not passed', ->
        it 'does not throw error', ->
          expect(=> @subject.then(@fooSuccess)).to.not.throw(/.*/)

    context 'when promise is already rejected', ->
      beforeEach ->
        @subject = new @promise().reject(@param)
        return

      context 'when a resolve callback is passed', ->
        beforeEach ->
          @pr = @subject.then @fooSuccess, @fooFailure
          return

        it 'does not execute the resolve callback', ->
          expect(@fooSuccess).to.not.be.called

      context 'when a resolve callback is not passed', ->
        it 'does not throw error', ->
          expect(=> @subject.then(undefined, @fooFailure)).to.not.throw(/.*/)

      context 'when a reject callback is passed', ->
        beforeEach ->
          @pr = @subject.then @fooSuccess, @fooFailure
          return

        it 'does not execute the resolve callback', ->
          expect(@fooSuccess).to.not.be.called

        it 'executes the reject callback', ->
          expect(@fooFailure).to.be.calledOnce

        it 'passed reject argument to callback', ->
          expect(@fooFailure).to.be.calledWith @param

      context 'when a reject callback is not passed', ->
        it 'does not throw error', ->
          expect(=> @subject.then(@fooSuccess)).to.not.throw(/.*/)

  describe '#resolve', ->
    it 'returns its own promise instance', ->
      expect(@subject.resolve('foo'))
        .to.be.equal @subject

    it 'calls the success callback with correct params', ->
      @subject.resolve(@param)

      expect(@fooSuccess).to.be.calledOnce

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
      @subject.reject(@param)

      expect(@fooFailure).to.be.calledOnce

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
        @pr.then @fooSuccess, @fooFailure

        expect(@fooFailure).to.be.calledOnce
