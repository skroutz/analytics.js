api_session_promise_tests = ->
  context 'when session retrieval fulfils', ->
    beforeEach ->
      @analytics_session = 'asd'
      @session_promise.resolve(@analytics_session)
      return

    it 'fulfils @promise', ->
      expect(@instance.promise.state).to.equal('fulfilled')

    it 'fulfils @promise and passes the analytics_session as param', (done)->
      @instance.promise.then (sess)=>
        expect(sess).to.equal @analytics_session
        done()

  context 'when session retrieval rejects', ->
    beforeEach ->
      @session_promise.reject()
      return

    it 'rejects @promise', ->
      expect(@instance.promise.state).to.equal('rejected')

action_reporting_tests = ->
  it 'reports an action', ->
    @init2()
    expect(@sendbeacon_spy).to.be.called

  it 'reports an action to proper url', ->
    @init2()
    url = @settings.url.beacon(@analytics_session)
    expect(@sendbeacon_spy).to.be.calledWith url

  describe 'format of data reported', ->
    beforeEach ->
      @init2()
      @payload = @sendbeacon_spy.args[0][1]

    it 'has url, shop_code and actions keys', ->
      p = @settings.params
      expect(@payload).to.have.keys p.url, p.shop_code, p.actions

    it 'proper data in url key', ->
      expect(@payload.url).to.equal @settings.url.current

    it 'proper data in shop_code key', ->
      expect(@payload.shop_code).to.equal @shop_code

    it 'has an array as value to the actions key', ->
      expect(@payload.actions).to.be.an('array')

    it 'places a single item to the actions array', ->
      expect(@payload.actions).to.have.length 1

    it 'places a single object to the actions array', ->
      expect(@payload.actions[0]).to.be.an('object')

    it 'has proper data in the action\'s object', ->
      expect(@payload.actions[0]).to.eql
        category: @category
        type: @type
        data: @data

describe 'ActionsManager', ->
  before (done) ->
    @analytics_session = 'analytics_session'
    @shop_code = 'shop_code'
    @yogurt_session = 'yogurt_session'
    @yogurt_user_id = 'yogurt_user_id'

    @reset_saq = ->
      @settings.window.sa = =>
        @settings.window.sa.q.push(arguments)
      @settings.window.sa.q = []

    @init_session = (resolve = true)->
      @instance.session =
        shop_code: 'asd'

      if resolve
        @instance.promise.resolve('asd')
      else
        @instance.promise.reject('asd')
      return

    require ['promise'], (Promise) =>
      # Mock Session
      window.__requirejs__.clearRequireState()
      requirejs.undef 'session'
      @session_promise = new Promise()
      @session_mock = (type, data = {})->
        @shop_code = data.shop_code or null
        return
      @session_mock::then = (success, error)=>
        @session_promise.then(success, error)

      @session_spy = sinon.spy @, 'session_mock'
      define 'session', [], => @session_mock

      # Mock Reporter
      window.__requirejs__.clearRequireState()
      requirejs.undef 'reporter'
      @reporter_promise = new Promise()
      @reporter_mock = -> @reporter_promise
      @sendbeacon_promise = new Promise()
      @reporter_mock::sendBeacon = => return @sendbeacon_promise
      @sendbeacon_spy = sinon.spy @reporter_mock::, 'sendBeacon'

      @reporter_spy = sinon.spy @, 'reporter_mock'
      define 'reporter', [], => @reporter_mock

      require [
        'actions_manager'
        'settings'
        'reporter'
        'promise'
      ], (ActionsManager, Settings, Reporter, Promise) =>
        @promise = Promise
        @settings = Settings
        @reporter = Reporter
        @subject = ActionsManager
        @run_spy = sinon.spy(@subject::, 'run')
        done()

  after ->
    requirejs.undef 'session'
    window.__requirejs__.clearRequireState()

  beforeEach ->
    @old_redirect = @settings.redirectTo
    @redirect_stub = sinon.stub()
    @settings.redirectTo = @redirect_stub
    @clock = sinon.useFakeTimers()

    @init = => @instance = new @subject()

  afterEach ->
    @run_spy.reset()
    @clock.restore()
    @settings.redirectTo = @old_redirect
    @reset_saq()

    # Reset mocks
    @sendbeacon_promise = new @promise()
    @sendbeacon_spy.reset()
    @session_promise = new @promise()
    @session_spy.reset()

  describe '.constructor', ->
    beforeEach ->
      @init = =>
        sa('ecommerce', 'addOrder', 'data1')
        sa('ecommerce', 'addItem', 'data2')
        sa('ecommerce', 'addItem', 'data3')
        @instance = new @subject()

    it 'creates a reporter', ->
      @init()
      expect(@instance.reporter).to.be.instanceof @reporter

    it 'creates a promise to handle session retrieval', ->
      @init()
      expect(@instance.promise).to.be.instanceof @promise

    it 'consumes all commands already passed to window.sa.q', ->
      q_ref = @settings.window.sa.q
      @init()
      expect(q_ref).to.have.length 0
      q_ref = null

    it 'replaces window.sa.q with internal method', ->
      @init()
      expect(@settings.window.sa).to.equal @instance.run

  describe 'Automatic PageViews', ->
    beforeEach ->
      @timeout_spy = sinon.spy @settings.window, 'setTimeout'
      @cleartimeout_spy = sinon.spy @settings.window, 'clearTimeout'
      @old_setting = @settings.send_auto_pageview
      @init = =>
        @instance = new @subject()
        @init_session()

    afterEach ->
      @settings.send_auto_pageview = @old_setting
      @timeout_spy.restore()
      @cleartimeout_spy.restore()

    context 'when Settings.send_auto_pageview is false', ->
      beforeEach ->
        @settings.send_auto_pageview = false

      it 'does not set a timeout', ->
        @init()
        expect(@timeout_spy).to.not.be.called

      it 'does not send a pageview', ->
        @init()
        @clock.tick @settings.auto_pageview_timeout + 100

        expect(@sendbeacon_spy).to.not.be.called

    context 'when Settings.send_auto_pageview is true', ->
      beforeEach ->
        @settings.send_auto_pageview = true

      it 'sets a timeout', ->
        @init()
        expect(@timeout_spy).to.be.calledOnce

      context 'when no other actions are declared', ->
        context 'before timeout expires', ->
          beforeEach ->
            @init()

          it 'does not send a pageview', ->
            expect(@sendbeacon_spy).to.not.be.called

        context 'after timeout expires', ->
          beforeEach ->
            @init()
            @clock.tick @settings.auto_pageview_timeout + 100

          it 'sends an action', ->
            expect(@sendbeacon_spy).to.be.calledOnce

          it 'sends a PageView action', ->
            beacon_data = @sendbeacon_spy.args[0][1].actions[0]

            expect(beacon_data).to.contain
              category: "site"
              type: "sendPageView"

          it 'sends a PageView action with empty data', ->
            beacon_data = @sendbeacon_spy.args[0][1].actions[0]

            expect(beacon_data).to.contain
              data: '{}'

      context 'when another action is created', ->
        context 'before timeout expires', ->
          beforeEach ->
            @init()
            sa('ecommerce', 'addOrder', 'data1')

          it 'clears the AutoPageView timeout', ->
            expect(@cleartimeout_spy).to.be.calledWith @instance.pageview_timeout

          it 'only sends one action', ->
            expect(@sendbeacon_spy).to.be.calledOnce

          it 'sends the newly created action', ->
            action_data = @sendbeacon_spy.args[0][1].actions[0]
            expect(action_data).to.contain
              category: 'ecommerce'
              type: 'addOrder'
              data: 'data1'

          it 'does not send a PageView action', ->
            action_data = @sendbeacon_spy.args[0][1].actions[0]
            expect(action_data).to.not.contain
              category: "site"
              type: "sendPageView"

        context 'after timeout expires', ->
          beforeEach ->
            @init()
            @clock.tick @settings.auto_pageview_timeout + 100
            sa('ecommerce', 'addOrder', 'data1')

          it 'clears the AutoPageView timeout', ->
            expect(@cleartimeout_spy).to.be.calledWith @instance.pageview_timeout

          it 'sends both actions', ->
            expect(@sendbeacon_spy).to.be.calledTwice

  describe 'Replacement of public endpoint on library load', ->
    beforeEach ->
      @init = => @instance = new @subject()

    context 'when API calls are made before library load', ->
      beforeEach ->
        sa('ecommerce', 'addOrder', 'data1')
        sa('ecommerce', 'addItem', 'data2')
        sa('ecommerce', 'addItem', 'data3')
        @init()
        return

      it 'executes every API call', ->
        expect(@run_spy).to.be.calledThrice

    context 'when API calls are made after library load', ->
      beforeEach ->
        @init()
        sa('ecommerce', 'addOrder', 'data1')
        sa('ecommerce', 'addItem', 'data2')
        sa('ecommerce', 'addItem', 'data3')
        return

      it 'executes every API call', ->
        expect(@run_spy).to.be.calledThrice

  describe 'Synchronization with session retrieval', ->
    beforeEach ->
      sa('ecommerce', 'addOrder', 'data1')
      @init()

    context 'when session retrieval is in progress', ->
      it 'does not report any actions', ->
        expect(@sendbeacon_spy).to.not.be.called

    context 'when session retrieval succeeds', ->
      beforeEach ->
        @init_session()

      it 'reports actions', ->
        expect(@sendbeacon_spy).to.be.called

    context 'when session retrieval rejects', ->
      beforeEach ->
        @init_session(false)

      it 'does not report any actions', ->
        expect(@sendbeacon_spy).to.not.be.called

  describe 'API actions', ->
    describe 'session', ->
      beforeEach ->
        @category = 'session'
        @init2 = ->
          sa(@category, @type, @shop_code, @yogurt_session, @yogurt_user_id)
          @init()

      describe 'create', ->
        beforeEach ->
          @type = 'create'
          @init2()

        it 'creates a new session', ->
          expect(@session_mock).to.be.calledWithNew

        it 'creates a session with type and passes shop_code, yogurt_session and yogurt_user_id', ->
          expect(@session_mock).to.be.calledWith @type,
            shop_code: @shop_code
            yogurt_session: @yogurt_session
            yogurt_user_id: @yogurt_user_id

        api_session_promise_tests()

      describe 'connect', ->
        beforeEach ->
          @type = 'connect'
          @init2()

        it 'creates a new session', ->
          expect(@session_mock).to.be.calledWithNew

        it 'creates a session with type and passes shop_code', ->
          expect(@session_mock).to.be.calledWith @type,
            shop_code: @shop_code

        api_session_promise_tests()

    describe 'yogurt', ->
      beforeEach ->
        @category = 'yogurt'
        @data = '{}'

        @redirect_url = 'http://redirect_url'

        @init2 = ->
          sa('session', 'create', @shop_code, @yogurt_session, @yogurt_user_id)
          sa(@category, @type, @data, @redirect_url)
          @init()
          @session_promise.resolve(@analytics_session)
          return

      describe 'productClick', ->
        beforeEach ->
          @type = 'productClick'

        action_reporting_tests()

        context 'when action is reported successfully', ->
          beforeEach ->
            @init2()
            @sendbeacon_promise.resolve()
            return

          it 'redirects ', ->
            expect(@settings.redirectTo).to.be.called

          it 'redirects to redirect_url', ->
            expect(@settings.redirectTo.args[0][0]).to.contain @redirect_url

        context 'when action fails to report', ->
          beforeEach ->
            @init2()
            @sendbeacon_promise.reject()
            return

          it 'does not redirect', ->
            expect(@settings.redirectTo).to.not.be.called

        context 'when an extra param with value false is passed on action', ->
          it 'does not redirect', ->
            sa('session', 'create', @shop_code, @yogurt_session, @yogurt_user_id)
            sa(@category, @type, @data, @redirect_url, false)
            @init()
            @session_promise.resolve(@analytics_session)
            @sendbeacon_promise.resolve()

            expect(@settings.redirectTo).to.not.be.called

    describe 'ecommerce', ->
      beforeEach ->
        @category = 'ecommerce'
        @data = '{}'

        @init2 = ->
          sa('session', 'create', @shop_code, @yogurt_session, @yogurt_user_id)
          sa(@category, @type, @data, @redirect_url)
          @init()
          @session_promise.resolve(@analytics_session)
          return

      describe 'addOrder', ->
        beforeEach ->
          @type = 'addOrder'

        action_reporting_tests()

        context 'when callback is supplied', ->
          beforeEach ->
            @spy = sinon.spy()

            @init2 = ->
              sa('session', 'create', @shop_code, @yogurt_session, @yogurt_user_id)
              sa(@category, @type, @data, @spy)
              @init()
              @session_promise.resolve(@analytics_session)
              return

          context 'when action is reported successfully', ->
            beforeEach ->
              @init2()
              @sendbeacon_promise.resolve()
              return
            it 'executes callback', ->
              expect(@spy).to.be.called


          context 'when action fails to report', ->
            beforeEach ->
              @init2()
              @sendbeacon_promise.reject()
              return

            it 'does not execute callback', ->
              expect(@spy).to.not.be.called

      describe 'addItem', ->
        beforeEach ->
          @type = 'addItem'

        action_reporting_tests()

        context 'when callback is supplied', ->
          beforeEach ->
            @spy = sinon.spy()

            @init2 = ->
              sa('session', 'create', @shop_code, @yogurt_session, @yogurt_user_id)
              sa(@category, @type, @data, @spy)
              @init()
              @session_promise.resolve(@analytics_session)
              return

          context 'when action is reported successfully', ->
            beforeEach ->
              @init2()
              @sendbeacon_promise.resolve()
              return
            it 'executes callback', ->
              expect(@spy).to.be.called


          context 'when action fails to report', ->
            beforeEach ->
              @init2()
              @sendbeacon_promise.reject()
              return

            it 'does not execute callback', ->
              expect(@spy).to.not.be.called

    describe 'site', ->
      beforeEach ->
        @category = 'site'
        @data = '{}'

        @init2 = ->
          sa('session', 'create', @shop_code, @yogurt_session, @yogurt_user_id)
          sa(@category, @type)
          @init()
          @session_promise.resolve(@analytics_session)
          return

      describe 'sendPageView', ->
        beforeEach ->
          @type = 'sendPageView'

        action_reporting_tests()

