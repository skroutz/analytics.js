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
      @resolve1_value = 'val1'
      @resolve1 = ->
        promise = new @promise()
        promise.resolve @resolve1_value

      @resolve2_value = 'val2'
      @resolve2 = ->
        promise = new @promise()
        promise.resolve @resolve2_value

      @reject1_value = 'val1'
      @reject1 = ->
        promise = new @promise()
        promise.reject @reject1_value

      @reject2_value = 'val2'
      @reject2 = ->
        promise = new @promise()
        promise.reject @reject2_value

    it 'returns a promise', ->
      expect(@promise.all([@resolve1(), @resolve2()]))
        .to.be.an.instanceof @promise

    context 'when all passed promises resolve', ->
      beforeEach ->
        @pr = @promise.all([@resolve1(), @resolve2()])
        @pr.then @fooSuccess, @fooFailure
        return

      it 'resolves the promise returned', ->
        expect(@pr.state).to.equal 'fulfilled'

      it 'passes an array with the promises results to resolve', ->
        param = @fooSuccess.args[0][0]
        expect(param).to.be.an.array

      it 'passes results in the same order as the param promises got called', ->
        param = @fooSuccess.args[0][0]
        expect(param).to.eql [@resolve1_value, @resolve2_value]

    context 'when some of the passed promises resolve', ->
      beforeEach ->
        @pr = @promise.all([@resolve1(), @reject1(), new @promise()], true)
        @pr.then @fooSuccess, @fooFailure
        return

      it 'rejects the returned promise', ->
        expect(@pr.state).to.equal 'rejected'

      it 'passes along data returned by the first rejected promise', ->
        expect(@fooFailure).to.be.calledWith @reject1_value

    context 'when none of the passed promises resolve', ->
      beforeEach ->
        @pr = @promise.all([@reject1(), @reject2()], true)
        @pr.then @fooSuccess, @fooFailure
        return

      it 'rejects the returned promise', ->
        expect(@pr.state).to.equal 'rejected'

      it 'passes along data returned by the first rejected promise', ->
        expect(@fooFailure).to.be.calledWith @reject1_value

  describe '.any', ->
    beforeEach ->
      @resolve1_value = 'val1'
      @resolve1 = ->
        promise = new @promise()
        promise.resolve @resolve1_value

      @resolve2_value = 'val2'
      @resolve2 = ->
        promise = new @promise()
        promise.resolve @resolve2_value

      @reject1_value = 'val1'
      @reject1 = ->
        promise = new @promise()
        promise.reject @reject1_value

      @reject2_value = 'val2'
      @reject2 = ->
        promise = new @promise()
        promise.reject @reject2_value

    it 'returns a promise', ->
      expect(@promise.any([@resolve1(), @resolve2()]))
        .to.be.an.instanceof @promise

    context 'when all passed promises resolve', ->
      beforeEach ->
        @pr = @promise.any([@resolve1(), @resolve2()])
        @pr.then @fooSuccess, @fooFailure
        return

      it 'resolves the promise returned', ->
        expect(@pr.state).to.equal 'fulfilled'

      it 'passes an array with the promises results to resolve', ->
        param = @fooSuccess.args[0][0]
        expect(param).to.be.an.array

      it 'passes results in the same order as the param promises got called', ->
        param = @fooSuccess.args[0][0]
        expect(param).to.eql [@resolve1_value, @resolve2_value]

    context 'when some of the passed promises resolve', ->
      beforeEach ->
        @pr = @promise.any([@resolve1(), @reject1(), @resolve2()], false)
        @pr.then @fooSuccess, @fooFailure
        return

      it 'resolves the promise returned', ->
        expect(@pr.state).to.equal 'fulfilled'

      it 'passes an array with the promises results to resolve', ->
        param = @fooSuccess.args[0][0]
        expect(param).to.be.an.array

      it 'passes results in the same order as the param promises got called', ->
        param = @fooSuccess.args[0][0]
        expect(param).to.eql [@resolve1_value, undefined, @resolve2_value]

      it 'passed undefined as value to the rejected param promises', ->
        param = @fooSuccess.args[0][0]
        expect(param[1]).to.equal undefined

    context 'when none of the passed promises resolve', ->
      beforeEach ->
        @pr = @promise.any([@reject1(), @reject2()], false)
        @pr.then @fooSuccess, @fooFailure
        return

      it 'rejects the promise returned', ->
        expect(@pr.state).to.equal 'rejected'

      it 'passes an array with the promises results to reject', ->
        param = @fooFailure.args[0][0]
        expect(param).to.be.an.array

      it 'passes results in the same order as the param promises got called', ->
        param = @fooFailure.args[0][0]
        expect(param).to.eql [@reject1_value, @reject2_value]

      it 'passes reject values to the results array', ->
        param = @fooFailure.args[0][0]
        expect(param).to.eql [@reject1_value, @reject2_value]
