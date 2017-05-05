describe 'Analytics', ->
  before (done) ->
    # mock PluginsManager
    requirejs.undef 'plugins_manager'
    @PluginsManager_spy = sinon.spy()

    define 'plugins_manager', => @PluginsManager_spy

    # mock ActionsManager
    requirejs.undef 'actions_manager'
    @ActionsManager_spy = sinon.spy()

    define 'actions_manager', => @ActionsManager_spy

    require [
      'settings',
      'analytics',
      'session',
      'plugins_manager'
      'actions_manager'], (Settings, Analytics, Session, PluginsManager, ActionsManager) =>
      @Settings = Settings
      @Analytics = Analytics
      @Session = Session
      @PluginsManager = PluginsManager
      @ActionsManager = ActionsManager
      done()

  after ->
    requirejs.undef 'plugins_manager'
    requirejs.undef 'actions_manager'
    window.__requirejs__.clearRequireState()

  describe '.constructor', ->
    beforeEach ->
      session = @session =
        analytics_session: 'analytics_session'
        shop_code: 'SA-XXXX-XXXX'
      @plugins_manager = new @PluginsManager()
      @session_run_stub = sinon.stub(@Session::, 'run').returns(then: (fn) -> fn(session))
      @ActionsManager_spy::run = sinon.stub().returnsThis()
      @_live_spy = sinon.spy(@Analytics::, '_live')
      @subject = new @Analytics()

    afterEach ->
      @session_run_stub.restore()
      @_live_spy.restore()

    it 'creates a PluginsManager using new', ->
      expect(@PluginsManager).to.be.calledWithNew

    it 'tries to acquire a Session', ->
      expect(@session_run_stub).to.be.calledOnce

    context 'when a Session is acquired', ->
      it 'creates an ActionsManager using new', ->
        expect(@ActionsManager).to.be.calledWithNew

      it 'provides the session and PluginsManager instance to the ActionsManager instance', ->
        expect(@ActionsManager).to.be.calledWith(@session, @plugins_manager)

      it 'calls ActionsManager#run', ->
        expect(@ActionsManager_spy::run).to.be.called

      it 'calls #_live', ->
        expect(@_live_spy).to.be.called

  describe '#_live', ->
    beforeEach ->
      @actions_run_spy = sinon.spy()
      @subject = -> @Analytics::_live.call(actions: { run: @actions_run_spy })

    it 'replaces the global queue appending function', ->
      original_entrypoint = @Settings.window.sa
      @subject()
      expect(@Settings.window.sa).to.not.equal(original_entrypoint)

    context 'when a command is lazily declared', ->
      beforeEach ->
        @command = ['ecommerce', 'addOrder', 'order']
        @declareAction = ->
          sa(@command...)

      it 'is pushed to Settings.window.sa.q for consumption', ->
        @subject()
        @declareAction()
        expect(Array.prototype.slice.call(@Settings.window.sa.q[0]))
          .to.deep.equal(@command)

      context 'ActionsManager', ->
        it 'runs', ->
          @subject()
          @declareAction()
          expect(@actions_run_spy).to.be.called

