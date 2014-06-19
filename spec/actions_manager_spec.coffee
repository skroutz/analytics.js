# Helper to clear API queue whithout messing with the references
clear_q = ->
  while a = window.sa.q.pop()
    ;

describe 'ActionsManager', ->
  @timeout(0) # Disable the spec's timeout

  before (done) ->
    require [
      'promise'
      'settings'
      'reporter'
    ], (Promise, Settings, Reporter) =>
      @settings = Settings
      @promise  = Promise
      @reporter = Reporter

      require ['actions_manager'], (ActionsManager) =>
        @subject = ActionsManager
        done()

  beforeEach ->
    @old_redirect = @settings.redirectTo
    @redirect_stub = sinon.stub()
    @settings.redirectTo = @redirect_stub
    @clock = sinon.useFakeTimers()
    @report_stub = sinon.stub(@reporter::, 'report')
      .returns (new @promise()).resolve()

  afterEach ->
    @report_stub.restore()
    @settings.redirectTo = @old_redirect
    @clock.restore()
    fixture.cleanup()
    clear_q()


  describe '.constructor', ->
    beforeEach ->
      sa('ecommerce', 'addTransaction', 'data1', 'sig1');
      sa('ecommerce', 'addItem', 'data2', 'sig2');
      sa('ecommerce', 'addItem', 'data3', 'sig3');
      @instance = new @subject()

    it 'creates a reporter', ->
      expect(@instance.reporter).to.be.instanceof @reporter

    it 'parses actions', ->
      expect(@instance.actions).to.have.length 3

    it 'empties sa.q', ->
      expect(window.sa.q).to.have.length 0

  describe 'Actions Parsing', ->
    it 'processes pushed generic actions', ->
      sa('action_category', 'action_type', 'action_data')
      @instance = new @subject()
      expect(@instance.actions[0]).to.contain
        category: 'action_category'
        type: 'action_type'
        data: 'action_data'

    context 'when no action specified', ->
      beforeEach ->
        @instance = new @subject()

      it 'creates an action', ->
        expect(@instance.actions).to.have.length 1

      it 'creates an action with category "site"', ->
        expect(@instance.actions[0]).to.contain {category:@settings.api.site.key}

      it 'creates an action with type "sendPageview"', ->
        expect(@instance.actions[0]).to.contain {type: @settings.api.site.send_pageview}

    context "when a settings:setYogurtSession action is passed", ->
      beforeEach ->
        @yogurt_session = 'session_id'
        sa(@settings.api.settings.key, @settings.api.settings.yogurt_session, @yogurt_session)
        @instance = new @subject()

      it "registers yogurt_session to @parsed_settings", ->
        expect(@instance.parsed_settings).to.contain
          yogurt_session: @yogurt_session

    context "when a settings:setAccount action is passed", ->
      beforeEach ->
        @shop_code = 'shop_code_1'
        sa(@settings.api.settings.key, @settings.api.settings.set_account, @shop_code)
        @instance = new @subject()

      it "registers shop_code to @shop_code_val", ->
        expect(@instance.shop_code).to.equal @shop_code

    context "when a settings:redirectTo action is passed", ->
      beforeEach ->
        @url = 'some_url'
        @timeout_seconds = 10

      it "registers redirection details to @redirect_data", ->
        sa(@settings.api.settings.key, @settings.api.settings.redirect_to, @url, @timeout_seconds)
        @instance = new @subject()

        expect(@instance.redirect_data).to.contain {
          'url': @url
          'time': @timeout_seconds
        }

      it "defaults to 0 seconds for timeout_seconds, if no timeout argument is passed", ->
        sa(@settings.api.settings.key, @settings.api.settings.redirect_to, @url)
        @instance = new @subject()

        expect(@instance.redirect_data).to.contain {
          'url': @url
          'time': 0
        }

    context "when a settings:setCallback action is passed", ->
      beforeEach ->
        @spy = sinon.spy()
        sa(@settings.api.settings.key, @settings.api.settings.set_callback, @spy)
        @instance = new @subject()

      it 'adds the function to the @callbacks array', ->
        expect(@instance.callbacks[0])
          .to.equal(@spy)

      it 'does not execute the function', ->
        expect(@spy).to.not.be.called

    context "when an ecommerce:* action is passed", ->
      beforeEach ->
        @data = 'shop_code_1'
        @signature = 'signature'

      context "when a fourth, signature, parameter is given", ->
        beforeEach ->
          sa(@settings.api.ecommerce.key, @settings.api.ecommerce.add_item, @data, @signature)
          @instance = new @subject()

        it "appends signature data", ->
          expect(@instance.actions[0]).to.contain
            category : @settings.api.ecommerce.key
            type     : @settings.api.ecommerce.add_item
            data     : @data
            sig      : @signature

      context "when no fourth parameter is given", ->
        beforeEach ->
          sa(@settings.api.ecommerce.key, @settings.api.ecommerce.add_item, @data)
          @instance = new @subject()

        it "does not append any signature data", ->
          expect(@instance.actions[0]).to.contain
            category : @settings.api.ecommerce.key
            type     : @settings.api.ecommerce.add_item
            data     : @data

  describe 'Actions Reporting', ->
    beforeEach ->
      @old_beacon_setting = @settings.single_beacon
      clear_q()

      @data1 = 'shop_code_1'
      @data2 = 'shop_code_2'
      @data3 = 'shop_code_3'
      @shop_code = 'shop_code_1'
      sa(@settings.api.settings.key, @settings.api.settings.set_account, @shop_code)
      sa(@settings.api.ecommerce.key, @settings.api.ecommerce.add_item, @data1)
      sa(@settings.api.ecommerce.key, @settings.api.ecommerce.add_item, @data2)
      sa(@settings.api.ecommerce.key, @settings.api.ecommerce.add_item, @data3)

    afterEach ->
      @settings.single_beacon = @old_beacon_setting
      clear_q()

    it 'calls report with an array of items', (done)->
      @instance = new @subject()
      @result = @instance.sendTo('dummy_url').then =>
        expect(@report_stub.args[0][1]).to.be.an('array')
        done()

    it 'adds a url attribute to each reported item', (done)->
      @instance = new @subject()
      @result = @instance.sendTo('dummy_url').then =>
        reported_item = @report_stub.args[0][1][0]
        expect(reported_item).to.contain
          'url': @settings.url.current
        done()

    it 'adds a shop_code attribute to each reported item', (done)->
      @instance = new @subject()
      @result = @instance.sendTo('dummy_url').then =>
        reported_item = @report_stub.args[0][1][0]
        expect(reported_item).to.contain
          'shop_code': @shop_code
        done()

    it 'adds an actions array to reported item', (done)->
      @instance = new @subject()
      @result = @instance.sendTo('dummy_url').then =>
        reported_item = @report_stub.args[0][1][0]
        expect(reported_item)
          .to.have.property('actions')
          .that.is.an('array')
        done()

    it 'adds a category string attribute to action array item', (done)->
      @instance = new @subject()
      @result = @instance.sendTo('dummy_url').then =>
        reported_item = @report_stub.args[0][1][0]
        expect(reported_item.actions[0])
          .to.have.property('category')
          .that.equals(@settings.api.ecommerce.key)
        done()

    it 'adds a type aattribute to action array item', (done)->
      @instance = new @subject()
      @result = @instance.sendTo('dummy_url').then =>
        reported_item = @report_stub.args[0][1][0]
        expect(reported_item.actions[0])
          .to.have.property('type')
          .that.equals(@settings.api.ecommerce.add_item)
        done()

    it 'adds a data aattribute to action array item', (done)->
      @instance = new @subject()
      @result = @instance.sendTo('dummy_url').then =>
        reported_item = @report_stub.args[0][1][0]
        expect(reported_item.actions[0])
          .to.have.property('data')
          .that.equals(@data3)
        done()


    context 'when actions are to be reported with a single beacon', ->
      beforeEach (done)->
        @settings.single_beacon = true

        @instance = new @subject()
        @result = @instance.sendTo('dummy_url').then ->
          done()

      it 'creates one item to be reported', ->
        expect(@report_stub.args[0][1]).to.have.length 1

      it 'adds three items in the actions array of the reported item', ->
        reported_item = @report_stub.args[0][1][0]
        expect(reported_item.actions).to.have.length 3

    context 'when actions are to be reported with multiple beacons', ->
      beforeEach (done)->
        @settings.single_beacon = false

        @instance = new @subject()
        @result = @instance.sendTo('dummy_url').then ->
          done()

      it 'creates three item to be reported', ->
        expect(@report_stub.args[0][1]).to.have.length 3

      it 'adds one item in the actions array of each reported item', ->
        reported_item = @report_stub.args[0][1][2]
        expect(reported_item.actions).to.have.length 1

  describe 'API', ->
    describe '#getSettings', ->
      beforeEach ->
        @yogurt_session = 'session_id'
        sa(@settings.api.settings.key, @settings.api.settings.yogurt_session, @yogurt_session)
        @instance = new @subject()

      it "returns a parsed_data object", ->
        expect(@instance.getSettings())
          .to.be.an('object')
          .and.to.contain
            yogurt_session: @yogurt_session

    describe '#sendTo', ->
      beforeEach ->
        sa(@settings.api.settings.key, @settings.api.settings.set_account, 'shop_code_1')
        sa('some_category', 'some_type', 'some_data')

        @prepared_data = [{
          'koko': 'lala'
        }]
        @prepare_data_stub = sinon.stub(@subject::, '_prepareData').returns @prepared_data

        @instance = new @subject()

      afterEach ->
        @prepare_data_stub.restore()

      it 'returns a promise', ->
        result = @instance.sendTo('dummy_url')
        expect(result).to.be.instanceof @promise

      it 'prepares data before reporting', ->
        result = @instance.sendTo('dummy_url')
        expect(@prepare_data_stub).to.be.calledOnce

      it 'passes url argument to @reporter.report', (done)->
        @instance.sendTo('dummy_url').then =>
          expect(@report_stub.args[0][0]).to.equal('dummy_url')
          done()

      it 'passes prepared_data to @reporter.report', (done)->
        @instance.sendTo('dummy_url').then =>
          expect(@report_stub.args[0][1]).to.equal(@prepared_data)
          done()

      context 'when callback functions are registered', ->
        beforeEach ->
          clear_q()

          @spy = sinon.spy()

          sa('some_category', 'some_action', 'some_data')
          sa(@settings.api.settings.key, @settings.api.settings.set_callback, @spy)

          @instance = new @subject()

        it 'invokes function actions after all other actions are reported', (done)->
          expect(@spy.callCount).to.equal(0)
          @instance.sendTo('asd').then =>
            expect(@spy.callCount).to.equal(1)
            done()

    describe '#redirect', ->
      beforeEach ->
        @some_data = 'analytics_session'
        @url = 'some_url'

        sa(@settings.api.settings.key, @settings.api.settings.redirect_to, @url)
        @instance = new @subject()

        @instance.redirect(@some_data)
        @clock.tick 10

      it 'calls Settings.redirectTo function', (done)->
        expect(@redirect_stub.callCount).to.equal(1)
        done()

      it 'appends passed argument as get_param to the redirect url', (done)->
        expect(@redirect_stub.args[0][0]).to.contain(@some_data)
        done()
