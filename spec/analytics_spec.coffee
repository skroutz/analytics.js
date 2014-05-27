describe 'Analytics', ->
  @timeout(0) # Disable the spec's timeout

  before (done) ->
    window.__requirejs__.clearRequireState()
    require ['promise'], (Promise) =>
      @promise = Promise

      # mock Session
      requirejs.undef 'session'

      class SessionMock
        constructor: ->
          @promise = new Promise()
        then: (success, fail) ->
          @promise.then success, fail

      @session = SessionMock

      define 'session', [], ->
        return SessionMock

      # mock ActionsManager
      requirejs.undef 'actions_manager'

      class ActionsManagerMock
        sendTo: -> new Promise().resolve()
        redirect: (session) ->

      @actions = ActionsManagerMock

      define 'actions_manager', [], ->
        return ActionsManagerMock

      require ['analytics'], (Analytics) =>
        @analytics = Analytics
        done()

  after ->
    requirejs.undef 'session'
    requirejs.undef 'actions_manager'
    window.__requirejs__.clearRequireState()

  describe 'instance', ->
    beforeEach ->
      @subject = new @analytics()
      @subject.session.promise.reject()

    it 'has own property session', ->
      expect(@subject).to.have.ownProperty('session')

    it 'has own property actions', ->
      expect(@subject).to.have.ownProperty('actions')

    it 'responds to onNoSession', ->
      expect(@subject).to.respondTo('onNoSession')

    it 'responds to onSession', ->
      expect(@subject).to.respondTo('onSession')

  context 'when there is no analytics session', ->
    it 'calls #onNoSession', ->
      stub = sinon.stub(@analytics.prototype, 'onNoSession')
      @subject = new @analytics()
      @subject.session.promise.reject()

      expect(stub).to.be.calledOnce
      stub.restore()

  context 'when there is analytics session', ->
    beforeEach ->
      @analytics_session = 'foobar'
      @stub = sinon.stub(@analytics.prototype, 'onSession')
      @subject = new @analytics()
      @subject.session.promise.resolve(@analytics_session)

    afterEach ->
      @stub?.restore()

    it 'calls #onSession', ->
      expect(@stub).to.be.calledOnce

    it 'calls #onSession with proper argument', ->
      expect(@stub).to.be.calledWith(@analytics_session)

  describe '#onSession', ->
    beforeEach ->
      @subject = new @analytics()

    afterEach ->
      @spy?.restore()

    it 'reports a beacon', ->
      @spy = sinon.spy(@actions.prototype, 'sendTo')
      @subject.session.promise.resolve(@analytics_session)

      expect(@spy).to.be.calledOnce

    it 'and then redirects with proper argument', ->
      @spy = sinon.spy(@actions.prototype, 'redirect')
      @subject.session.promise.resolve(@analytics_session)

      expect(@spy).to.be.calledOnce.calledWith(@analytics_session)
