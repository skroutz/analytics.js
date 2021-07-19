describe 'Analytics', ->
  before (done) ->
    @sandbox = sinon.sandbox.create()

    # mock PluginsManager
    requirejs.undef 'plugins_manager'
    @PluginsManager_spy = @sandbox.spy()

    define 'plugins_manager', => @PluginsManager_spy

    # mock ActionsManager
    requirejs.undef 'actions_manager'
    @ActionsManager_spy = @sandbox.spy()

    define 'actions_manager', => @ActionsManager_spy

    # mock Session
    requirejs.undef 'session'
    @Session_spy = @sandbox.spy()

    define 'session', => @Session_spy

    require [
      'settings',
      'analytics',
      'session',
      'plugins_manager',
      'actions_manager'], (Settings, Analytics, Session, PluginsManager, ActionsManager) =>
      @Settings = Settings
      @Analytics = Analytics
      @Session = Session
      @PluginsManager = PluginsManager
      @ActionsManager = ActionsManager
      done()

  afterEach ->
    @sandbox.restore()

  after ->
    requirejs.undef 'plugins_manager'
    requirejs.undef 'actions_manager'
    requirejs.undef 'session'
    window.__requirejs__.clearRequireState()

  describe '.constructor', ->
    beforeEach ->
      @_handle_session_spy = @sandbox.stub(@Analytics::, '_handle_session')
      @subject = new @Analytics()

    it 'creates a PluginsManager using new', ->
      expect(@PluginsManager).to.be.calledWithNew

    it 'creates a Session using new', ->
      expect(@Session).to.be.calledWithNew

    it 'provides the PluginsManager instance to the session instance', ->
      expect(@Session).to.be.calledWith(@subject.plugins_manager)

    context 'when there are no commands in the q', ->
      it 'does not call #_handle_session', ->
        expect(@_handle_session_spy).to.not.be.called

      context 'when a command is lazily declared in q', ->
        before ->
          @command = ['ecommerce', 'addOrder', 'order']
          @declareAction = ->
            sa(@command...)

        it 'is pushed to Settings.window.sa.q for consumption', ->
          @declareAction()
          expect(Array.prototype.slice.call(@Settings.window.sa.q[0])).to.deep.equal(@command)

        it 'calls #_handle_session', ->
          @declareAction()
          expect(@_handle_session_spy).to.be.called

    context 'when there are commands in the q', ->
      beforeEach ->
        @Settings.window.sa.q = [['category', 'command', 'param1', 'param2']]

      it 'calls #_handle_session', ->
        expect(@_handle_session_spy).to.be.called

  describe '#_handle_session', ->
    beforeEach ->
      @_live_spy = @sandbox.spy()
      @session_run_stub = @sandbox.stub().returns(then: ->)

      @subject = ->
        @Analytics::_handle_session.call({
          session: { run: @session_run_stub },
          plugins_manager: @PluginsManager_spy,
          _live: @_live_spy
        })

    it 'tries to acquire a Session', ->
      @subject()
      expect(@session_run_stub).to.be.calledOnce

    context 'when a Session does not exist', ->
      context 'when the promise is not resolved', ->
        beforeEach ->
          @subject()

        it 'does not create an ActionsManager', ->
          expect(@ActionsManager_spy).to.not.be.calledWithNew

        it 'does not call #_live', ->
          expect(@_live_spy).to.not.be.called

      context 'when the promise is resolved with null Session', ->
        beforeEach ->
          @session = null
          @session_run_stub = @sandbox.stub().returns(then: (fn) => fn(@session))
          @subject()

        it 'does not create an ActionsManager', ->
          expect(@ActionsManager_spy).to.not.be.calledWithNew

        it 'does not call #_live', ->
          expect(@_live_spy).to.not.be.called

    context 'when a Session exists', ->
      beforeEach ->
        @session =
          analytics_session: 'analytics_session'
          shop_code: 'SA-XXXX-XXXX'

        @session_run_stub = @sandbox.stub().returns(then: (fn) => fn(@session))

        @subject()

      it 'creates an ActionsManager instance', ->
        expect(@ActionsManager_spy).to.be.calledWithNew

      it 'provides the session and PluginsManager instance to the ActionsManager instance', ->
        expect(@ActionsManager_spy).to.be.calledWith(@session, @PluginsManager_spy)

      it 'calls #_live', ->
        expect(@_live_spy).to.be.called

  describe '#_live', ->
    beforeEach ->
      @actions_run_spy = @sandbox.spy()
      @subject = -> @Analytics::_live.call(actions: { run: @actions_run_spy })

    it 'calls ActionsManager#run for existing actions', ->
      @subject()
      expect(@actions_run_spy).to.be.calledOnce

    it 'replaces the global queue appending function', ->
      original_entrypoint = @Settings.window.sa
      @subject()
      expect(@Settings.window.sa).to.not.equal(original_entrypoint)

    context 'when a command is lazily declared in q', ->
      before ->
        @command = ['ecommerce', 'addOrder', 'order']
        @declareAction = ->
          sa(@command...)

      beforeEach ->
        @subject()

      it 'is pushed to Settings.window.sa.q for consumption', ->
        @declareAction()
        expect(Array.prototype.slice.call(@Settings.window.sa.q[0])).to.deep.equal(@command)

      it 'is consumed by ActionsManager', ->
        @actions_run_spy.reset()

        @declareAction()
        @declareAction()
        expect(@actions_run_spy).to.be.calledTwice
