VALID_ORDER_DATA = {
  order_id: '123456',
  revenue:  '1315.25',
  shipping: '5.45',
  tax:      '301.25'
}
VALID_ORDER_DATA_STRINGIFIED = JSON.stringify(VALID_ORDER_DATA)

VALID_LINE_ITEM_DATA_1 = {
  order_id:   '123456',
  product_id: '47299441',
  name:       'Product 1 Lalastore'
  price:      '654.90',
  quantity:   '1'
}
VALID_LINE_ITEM_DATA_1_STRINGIFIED = JSON.stringify(VALID_LINE_ITEM_DATA_1)

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
    @run()
    expect(@sendbeacon_spy).to.be.called

  it 'reports an action to proper url', ->
    @run()
    url = @settings.url.beacon(@analytics_session)
    expect(@sendbeacon_spy).to.be.calledWith url

  describe 'format of data reported', ->
    beforeEach ->
      @run()
      @payload = @sendbeacon_spy.args[0][1]

    it 'has url, shop_code, referrer and actions keys', ->
      p = @settings.params
      expect(@payload).to.have.keys p.url, p.referrer,
                                    p.shop_code, p.actions

    it 'proper data in url key', ->
      expect(@payload.url).to.equal @settings.url.current

    it 'proper data in referrer key', ->
      expect(@payload.referer).to.equal @settings.url.referrer

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

    @reset_saq = ->
      @settings.window.sa = =>
        @settings.window.sa.q.push(arguments)
      @settings.window.sa.q = []

    require ['promise'], (Promise) =>
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
        'session'
        'plugins_manager'
        'actions_manager'
        'settings'
        'reporter'
        'promise'
      ], (Session, PluginsManager, ActionsManager, Settings, Reporter, Promise) =>
        @PluginsManager = PluginsManager
        @plugins_manager = new @PluginsManager

        @session = new Session(@plugins_manager)
        @session.analytics_session = @analytics_session
        @session.shop_code = @shop_code
        @plugins_manager.session = @session

        @actions_manager = ActionsManager
        @settings = Settings
        @reporter = Reporter
        @promise = Promise
        @run_spy = sinon.spy(@actions_manager::, 'run')

        done()

  after -> window.__requirejs__.clearRequireState()

  beforeEach ->
    @old_redirect = @settings.redirectTo
    @redirect_stub = sinon.stub()
    @settings.redirectTo = @redirect_stub
    @clock = sinon.useFakeTimers()

    @initializeSubject = => @subject = new @actions_manager(@session, @plugins_manager)

  afterEach ->
    @run_spy.reset()
    @clock.restore()
    @settings.redirectTo = @old_redirect
    @reset_saq()

    # Reset mocks
    @sendbeacon_promise = new @promise()
    @sendbeacon_spy.reset()

  describe '.constructor', ->
    beforeEach ->
      @subject = new @actions_manager(@session, @plugins_manager)

    it 'creates a reporter', ->
      expect(@subject.reporter).to.be.instanceof @reporter

    it 'caches plugins_manager instance', ->
      expect(@subject.plugins_manager).to.be.instanceof @PluginsManager

    context 'when commands exist', ->
      beforeEach ->
        sa('ecommerce', 'addOrder', 'order_data')
        sa('ecommerce', 'addItem', 'item_data_1')
        sa('ecommerce', 'addItem', 'item_data_2')

      it 'consumes all commands already declared', ->
        @subject.run()
        expect(@settings.window.sa.q).to.have.length 0

  describe 'Automatic PageViews', ->
    beforeEach ->
      @timeout_spy = sinon.spy @settings.window, 'setTimeout'
      @cleartimeout_spy = sinon.spy @settings.window, 'clearTimeout'
      @old_setting = @settings.send_auto_pageview
      @initializeSubject = => @subject = new @actions_manager(@session, @plugins_manager)

    afterEach ->
      @settings.send_auto_pageview = @old_setting
      @timeout_spy.restore()
      @cleartimeout_spy.restore()

    context 'when Settings.send_auto_pageview is false', ->
      beforeEach ->
        @settings.send_auto_pageview = false

      it 'does not set a timeout', ->
        @initializeSubject()
        expect(@timeout_spy).to.not.be.called

      it 'does not send a pageview', ->
        @initializeSubject()
        @clock.tick @settings.auto_pageview_timeout + 100

        expect(@sendbeacon_spy).to.not.be.called

    context 'when Settings.send_auto_pageview is true', ->
      beforeEach ->
        @settings.send_auto_pageview = true

      it 'sets a timeout', ->
        @initializeSubject()
        expect(@timeout_spy).to.be.calledOnce

      context 'when no other actions are declared', ->
        context 'before timeout expires', ->
          beforeEach -> @initializeSubject()

          it 'does not send a pageview', ->
            expect(@sendbeacon_spy).to.not.be.called

        context 'after timeout expires', ->
          beforeEach ->
            @initializeSubject()
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
            sa('ecommerce', 'addOrder', 'order_data')
            @initializeSubject()
            @subject.run()

          it 'clears the AutoPageView timeout', ->
            expect(@cleartimeout_spy).to.be.calledWith @subject.pageview_timeout

          it 'only sends one action', ->
            expect(@sendbeacon_spy).to.be.calledOnce

          it 'sends the newly created action', ->
            expect(@sendbeacon_spy.args[0][1].actions[0]).to.contain
              category: 'ecommerce'
              type: 'addOrder'
              data: 'order_data'

          it 'does not send a PageView action', ->
            action_data = @sendbeacon_spy.args[0][1].actions[0]
            expect(action_data).to.not.contain
              category: "site"
              type: "sendPageView"

        context 'after timeout expires', ->
          beforeEach ->
            @initializeSubject()
            @clock.tick @settings.auto_pageview_timeout + 100
            sa('ecommerce', 'addOrder', 'order_data')
            @subject.run()

          it 'clears the AutoPageView timeout', ->
            expect(@cleartimeout_spy).to.be.calledWith @subject.pageview_timeout

          it 'sends both actions', ->
            expect(@sendbeacon_spy).to.be.calledTwice

  describe '#run', ->
    beforeEach -> @initializeSubject()

    context 'when API calls are made before library load', ->
      beforeEach ->
        sa('unknown-category', 'unknown-command', 'data')
        sa('ecommerce', 'addOrder', 'order_data')
        sa('ecommerce', 'addItem', 'item_data_1')
        sa('ecommerce', 'addItem', 'item_data_2')
        @subject.run()

      it 'executes every recognized command', ->
        expect(@sendbeacon_spy).to.be.calledThrice

  describe 'Commands', ->
    describe 'yogurt', ->
      beforeEach ->
        @category = 'yogurt'
        @data = '{}'

        @run = ->
          sa(@category, @type, @data)
          @initializeSubject()
          @subject.run()

      describe 'productClick', ->
        beforeEach -> @type = 'productClick'

        action_reporting_tests()

        context 'when redirect callback is supplied', ->
          beforeEach ->
            @redirect_url = 'http://redirect_url'
            @redirect_callback_spy = sinon.spy()

            @run = ->
              sa(@category, @type, @data, @redirect_callback_spy, @redirect_url)
              @initializeSubject()
              @subject.run()

          context 'when action is reported successfully', ->
            it 'executes redirect callback', ->
              @run()
              @sendbeacon_promise.resolve()

              expect(@redirect_callback_spy).to.be.calledWith(@redirect_url)

            context 'when redirect callback throws an error', ->
              beforeEach ->
                @redirect_callback_stub = sinon.stub().throws()

                @run = ->
                  sa(@category, @type, @data, @redirect_callback_stub, @redirect_url)
                  @initializeSubject()
                  @subject.run()

                @run()
                @sendbeacon_promise.resolve()
                return

              it 'redirects to redirect_url', ->
                expect(@settings.redirectTo).to.be.calledWith(@redirect_url)

          context 'but redirect_url is not supplied', ->
            beforeEach ->
              @run = ->
                sa(@category, @type, @data, @redirect_callback_spy)
                @initializeSubject()
                @subject.run()

              @run()
              @sendbeacon_promise.resolve()
              return

            it 'does not execute redirect callback', ->
              expect(@redirect_callback_spy).to.not.be.called

          context 'when action fails to report', ->
            beforeEach ->
              @run()
              @sendbeacon_promise.reject()
              return

            it 'does not execute redirect callback', ->
              expect(@redirect_callback_spy).to.not.be.called

    describe 'ecommerce', ->
      beforeEach ->
        @category = 'ecommerce'
        @data = '{}'

        @run = ->
          sa(@category, @type, @data)
          @initializeSubject()
          @subject.run()
          return

      describe 'addOrder', ->
        beforeEach ->
          @type = 'addOrder'

        action_reporting_tests()

        context 'when callback is supplied', ->
          beforeEach ->
            @callback_spy = sinon.spy()

            @run = ->
              sa(@category, @type, @data, @callback_spy)
              @initializeSubject()
              @subject.run()
              return

          context 'when action is reported successfully', ->
            beforeEach ->
              @run()
              @sendbeacon_promise.resolve()
              return

            it 'executes callback', ->
              expect(@callback_spy).to.be.called

          context 'when action fails to report', ->
            beforeEach ->
              @run()
              @sendbeacon_promise.reject()
              return

            it 'does not execute callback', ->
              expect(@callback_spy).to.not.be.called

        context 'when data are given as unstringified object', ->
          beforeEach ->
            @data = VALID_ORDER_DATA

          it 'stringifies the data before reporting', ->
            @run()
            payload = @sendbeacon_spy.args[0][1]
            expect(@sendbeacon_spy).to.be.called
            expect(payload.actions[0].data).to.eql VALID_ORDER_DATA_STRINGIFIED

      describe 'addItem', ->
        beforeEach ->
          @type = 'addItem'

        action_reporting_tests()

        context 'when callback is supplied', ->
          beforeEach ->
            @callback_spy = sinon.spy()

            @run = ->
              sa(@category, @type, @data, @callback_spy)
              @initializeSubject()
              @subject.run()

          context 'when action is reported successfully', ->
            beforeEach ->
              @run()
              @sendbeacon_promise.resolve()
              return

            it 'executes callback', ->
              expect(@callback_spy).to.be.called

          context 'when action fails to report', ->
            beforeEach ->
              @run()
              @sendbeacon_promise.reject()
              return

            it 'does not execute callback', ->
              expect(@callback_spy).to.not.be.called

        context 'when data are given as unstringified object', ->
          beforeEach ->
            @data = VALID_LINE_ITEM_DATA_1

          it 'stringifies the data before reporting', ->
            @run()
            payload = @sendbeacon_spy.args[0][1]
            expect(@sendbeacon_spy).to.be.called
            expect(payload.actions[0].data).to.eql VALID_LINE_ITEM_DATA_1_STRINGIFIED

    describe 'site', ->
      beforeEach ->
        @category = 'site'
        @data = '{}'

        @run = ->
          sa(@category, @type)
          @initializeSubject()
          @subject.run()

      describe 'sendPageView', ->
        beforeEach -> @type = 'sendPageView'

        action_reporting_tests()
