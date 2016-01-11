describe 'Analytics', ->
  before (done) ->
    # mock ActionsManager
    requirejs.undef 'actions_manager'
    @ActionsManager_spy = sinon.spy()

    define 'actions_manager', => @ActionsManager_spy

    require [
      'analytics',
      'session',
      'actions_manager'], (Analytics, Session, ActionsManager) =>
      @Analytics = Analytics
      @Session = Session
      @ActionsManager = ActionsManager
      done()

  after ->
    requirejs.undef 'actions_manager'
    window.__requirejs__.clearRequireState()

  describe '.constructor', ->
    beforeEach ->
      @session =
        analytics_session: 'analytics_session'
        shop_code: 'SA-XXXX-XXXX'
      @session_run_stub = sinon.stub(@Session::, 'run').returns(then: (fn) => fn.call(@, @session))
      @ActionsManager_spy::run = sinon.spy()
      @subject = new @Analytics()

    afterEach -> @session_run_stub.restore()

    it 'tries to acquire a Session', ->
      expect(@session_run_stub).to.be.calledOnce

    context 'when a Session is acquired', ->
      it 'creates an ActionsManager using new', ->
        expect(@ActionsManager).to.be.calledWithNew

      it 'provides the session to the ActionsManager instance', ->
        expect(@ActionsManager).to.be.calledWith(@session)

      it 'calls ActionsManager#run', ->
        expect(@ActionsManager_spy::run).to.be.called
