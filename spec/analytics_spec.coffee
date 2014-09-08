describe 'Analytics', ->
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

      @session_mock = SessionMock
      @session_spy = sinon.spy this, 'session_mock'

      define 'session', [], =>
        return @session_mock

      # mock ActionsManager
      requirejs.undef 'actions_manager'

      class ActionsManagerMock
        getSettings: -> {koko:'lala'}
        sendTo: -> new Promise().resolve()
        redirect: (session) ->

      @actions_mock = ActionsManagerMock

      define 'actions_manager', [], =>
        return @actions_mock

      require ['analytics'], (Analytics) =>
        @analytics = Analytics
        done()

  after ->
    requirejs.undef 'session'
    requirejs.undef 'actions_manager'
    window.__requirejs__.clearRequireState()

  afterEach ->
    @session_spy.reset()

  describe 'instance', ->
    beforeEach ->
      @subject = new @analytics()
      @subject.session.promise.reject()
      return

    it 'has own property session', ->
      expect(@subject).to.have.ownProperty('session')

    it 'has own property actions', ->
      expect(@subject).to.have.ownProperty('actions')

    it 'responds to onNoSession', ->
      expect(@subject).to.respondTo('onNoSession')

    it 'responds to onSession', ->
      expect(@subject).to.respondTo('onSession')

  describe '.constructor', ->
    it 'creates new Session with parsed_settings_from ActionsManager', ->
      obj = {a_new:'obj'}
      stub = sinon.stub(@actions_mock.prototype, 'getSettings').returns(obj)
      @subject = new @analytics()
      expect(@session_spy).to.be.calledOnce
        .and.to.be.calledWith(obj)
      stub.restore()

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
      @spy = sinon.spy(@actions_mock.prototype, 'sendTo')
      @subject.session.promise.resolve(@analytics_session)

      expect(@spy).to.be.calledOnce

    it 'and then redirects with proper argument', ->
      @spy = sinon.spy(@actions_mock.prototype, 'redirect')
      @subject.session.promise.resolve(@analytics_session)

      expect(@spy).to.be.calledOnce.calledWith(@analytics_session)
