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
    @location_replace_stub = sinon.stub()
    @settings.redirectTo = @location_replace_stub

    @clock = sinon.useFakeTimers()

  afterEach ->
    @settings.redirectTo = @old_redirect
    @clock.restore()
    fixture.cleanup()
    clear_q()


  describe '.constructor', ->
    beforeEach ->
      a = fixture.load 'actions_manager.html'
      @instance = new @subject()

    it 'creates a reporter', ->
      expect(@instance.reporter).to.be.instanceof @reporter

    it 'parses actions', ->
      expect(@instance.actions).to.have.length 3

    it 'empties sa.q', ->
      expect(window.sa.q).to.have.length 0

  describe 'Actions Implemented', ->
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
        expect(@instance.actions[0]).to.contain {category:'site'}

      it 'creates an action with type "sendPageview"', ->
        expect(@instance.actions[0]).to.contain {type:'sendPageview'}

    context "when settings:setAccount action is passed", ->
      beforeEach ->
        sa(@settings.api.settings.key, @settings.api.settings.set_account, 'shop_code_1')
        @instance = new @subject()

      it "registers shop_code to @shop_code_val", ->
        expect(@instance.shop_code_val).to.equal 'shop_code_1'

    context "when settings:redirectTo action is passed", ->
      beforeEach ->
        @url = 'some_url'
        @timeout_seconds = 10

      it "defaults to 0 seconds for timeout_seconds, if no argument is passed", ->
        sa(@settings.api.settings.key, @settings.api.settings.redirect_to, @url)
        @instance = new @subject()

        expect(@instance.redirect_data).to.contain {
          'url': @url
          'time': 0
        }

      it "registers redirection details to @redirect_data", ->
        sa(@settings.api.settings.key, @settings.api.settings.redirect_to, @url, @timeout_seconds)
        @instance = new @subject()

        expect(@instance.redirect_data).to.contain {
          'url': @url
          'time': @timeout_seconds
        }

    context "when a function is passed as action", ->
      beforeEach ->
        @spy = sinon.spy()
        sa(@settings.api.settings.key, @settings.api.settings.set_callback, @spy)
        @instance = new @subject()

      it 'adds the function to the @callbacks array', ->
        expect(@instance.callbacks[0])
          .to.equal(@spy)

      it 'does not execute the function', ->
        expect(@spy).to.not.be.called

  describe 'API', ->
    describe '#sendTo', ->
      beforeEach ->
        sa(@settings.api.settings.key, @settings.api.settings.set_account, 'shop_code_1')
        sa('some_category', 'some_type', 'some_data')

        @instance = new @subject()

        @report_stub = sinon.stub(@instance.reporter, 'report')
          .returns (new @promise()).resolve()

      afterEach ->
        @report_stub?.restore()

      it 'returns a promise', ->
        result = @instance.sendTo('asd')
        expect(result).to.be.instanceof @promise

      it 'invokes @reporter.report for every action processed', (done)->
        @instance.sendTo('dummy_url').then =>
          expect(@report_stub.callCount).to.equal(1)
          done()

      it 'passes url argument to @reporter.report', (done)->
        @instance.sendTo('dummy_url').then =>
          expect(@report_stub.args[0][0]).to.equal('dummy_url')
          done()

      it 'passes actions as second argument to @reporter.report', (done)->
        @instance.sendTo('dummy_url').then =>
          expect(@report_stub.args[0][1]).to.deep.eql @instance.actions
          done()

      it 'does not appends shop_code to reported data if not passed by action', (done)->
        @report_stub?.restore()
        clear_q()

        sa('some_action', 'some_data')
        @instance = new @subject()
        @report_stub = sinon.stub(@instance.reporter, 'report')
          .returns (new @promise()).resolve()

        @instance.sendTo('dummy_url').then =>
          expect(@report_stub.args[0][1]).to.not.contain
            shop_code_val: 'shop_code_1'
          done()

      context 'when functions are added as callback actions', ->
        beforeEach ->
          @report_stub?.restore()
          clear_q()

          @spy = sinon.spy()

          sa('some_category', 'some_action', 'some_data')
          sa(@settings.api.settings.key, @settings.api.settings.set_callback, @spy)

          @instance = new @subject()
          @report_stub = sinon.stub(@instance.reporter, 'report')
            .returns (new @promise()).resolve()

        it 'invokes function actions after all other actions are reported', (done)->
          expect(@spy.callCount).to.equal(0)
          @instance.sendTo('asd').then =>
            expect(@spy.callCount).to.equal(1)
            done()

    describe '#redirect', ->
      beforeEach ->
        @analytics_session = 'some_id'
        @url = 'some_url'

        sa(@settings.api.settings.key, @settings.api.settings.redirect_to, @url)
        @instance = new @subject()

        @instance.redirect(@analytics_session)
        @clock.tick 1

      it 'calls window.location.replace', (done)->
        expect(@location_replace_stub.callCount).to.equal(1)
        done()

      it 'appends passed argument as get_param to the redirect url', (done)->
        expect(@location_replace_stub.args[0][0]).to.contain(@analytics_session)
        done()

  describe '#_parseActions', ->
    beforeEach ->
      sa(@settings.api.settings.key, @settings.api.settings.set_account, 'shop_code_1')
      sa('foo1', 'bar1', 'data1')
      sa('foo2', 'bar2', 'data2')

      @instance = new @subject()

    it 'appends url to each action', ->
      expect(@instance.actions[0])
        .to.have.property('url')
        .that.equals(window.location.href)

    it 'appends shop_code to each action', ->
      expect(@instance.actions[0])
        .to.have.property('shop_code_val')
        .that.equals('shop_code_1')
