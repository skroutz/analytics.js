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
    window._saq = []

  describe '.contructor', ->
    beforeEach ->
      a = fixture.load 'actions_manager.html'
      @instance = new @subject()

    it 'creates a reporter', ->
      expect(@instance.reporter).to.be.instanceof @reporter

    it 'parses actions', ->
      expect(@instance.actions).to.have.length 2

    it 'empties _saq', ->
      expect(window._saq).to.have.length 0

  describe 'Actions Implemented', ->
    it 'processes pushed generic actions', ->
      window._saq.push ['some_action', 'some_data']
      @instance = new @subject()
      expect(@instance.actions[0]).to.contain
        type: 'some_action'
        data: 'some_data'

    context 'when no action specified', ->
      beforeEach ->
        @instance = new @subject()

      it 'creates an action', ->
        expect(@instance.actions).to.have.length 1

      it 'creates an action with type "visit"', ->
        expect(@instance.actions[0]).to.contain {type:'visit'}

    context "when shop_code action is passed", ->
      beforeEach ->
        window._saq.push [@settings.api.shop_code_key, 'shop_code_1']
        @instance = new @subject()

      it "registers shop_code to @shop_code_val", ->
        expect(@instance.shop_code_val).to.equal 'shop_code_1'

    context "when redirect action is passed", ->
      beforeEach ->
        @url = 'some_url'
        @timeout_seconds = 10

      it "default to 0 seconds for timeout_seconds, if no argument is passed", ->
        window._saq.push [@settings.api.redirect_key, @url]
        @instance = new @subject()

        expect(@instance.redirect_data).to.contain {
          'url': @url
          'time': 0
        }

      it "registers redirection details to @redirect_data", ->
        window._saq.push [@settings.api.redirect_key, @url, @timeout_seconds]
        @instance = new @subject()

        expect(@instance.redirect_data).to.contain {
          'url': @url
          'time': @timeout_seconds
        }

    context "when a function is passed as action", ->
      beforeEach ->
        @spy = sinon.spy()
        window._saq.push @spy
        @instance = new @subject()

      it 'adds the function to the @callbacks array', ->
        expect(@instance.callbacks[0])
          .to.equal(@spy)

      it 'does not execute the function', ->
        expect(@spy).to.not.be.called

  describe 'API', ->
    describe 'sendTo', ->
      beforeEach ->
        window._saq.push [@settings.api.shop_code_key, 'shop_code_1']
        window._saq.push ['some_action', 'some_data']

        @instance = new @subject()

        @report_stub = sinon.stub(@instance.reporter, "report")
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

      it 'passes data from _saq as second argument to @reporter.report', (done)->
        @instance.sendTo('dummy_url').then =>
          expect(@report_stub.args[0][1]).to.contain
            type: 'some_action'
            data: 'some_data'
          done()

      it 'appends url to reported data', (done)->
        @instance.sendTo('dummy_url').then =>
          expect(@report_stub.args[0][1]).to.contain
            url: window.location.href
          done()

      it 'appends shop_code to reported data if passed by action', (done)->
        @instance.sendTo('dummy_url').then =>
          expect(@report_stub.args[0][1]).to.contain
            shop_code_val: 'shop_code_1'
          done()

      it 'does not appends shop_code to reported data if not passed by action', (done)->
        @report_stub?.restore()
        window._saq = []
        window._saq.push ['some_action', 'some_data']
        @instance = new @subject()
        @report_stub = sinon.stub(@instance.reporter, "report")
          .returns (new @promise()).resolve()

        @instance.sendTo('dummy_url').then =>
          expect(@report_stub.args[0][1]).to.not.contain
            shop_code_val: 'shop_code_1'
          done()

      context 'when functions are added as callback actions', ->
        beforeEach ->
          @report_stub?.restore()
          window._saq = []

          @spy = sinon.spy()

          window._saq.push ['some_action', 'some_data']
          window._saq.push @spy

          @instance = new @subject()
          @report_stub = sinon.stub(@instance.reporter, "report")
            .returns (new @promise()).resolve()

        it 'invokes function actions after all other actions are reported', (done)->
          expect(@spy.callCount).to.equal(0)
          @instance.sendTo('asd').then =>
            expect(@spy.callCount).to.equal(1)
            done()

    describe 'redirect', ->
      beforeEach ->
        @analytics_session = 'some_id'
        @url = 'some_url'

        window._saq.push [@settings.api.redirect_key, @url]
        @instance = new @subject()

        @instance.redirect(@analytics_session)
        @clock.tick 1

      it 'calls window.location.replace', (done)->
        expect(@location_replace_stub.callCount).to.equal(1)
        done()

      it 'appends passed argument as get_param to the redirect url', (done)->
        expect(@location_replace_stub.args[0][0]).to.contain(@analytics_session)
        done()
