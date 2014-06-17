describe 'Reporter', ->
  @timeout(0) # Disable the spec's timeout

  before (done) ->
    @url = 'foo.bar'

    @single_beacon_data_array = [{
      url: 'some_url'
      shop_code: 'SA-XXXX-Y'
      actions: [
        {
          category: 'site'
          type: 'sendPageView'
        },
        {
          category: 'yogurt'
          type: 'productClick'
          data: {
            product_id: '15400722'
            shop_product_id: '752'
            shop_id: '2032'
          }
        },
        {
          category: 'yogurt'
          type: 'productClick'
          data: {
            product_id: '15400722'
            shop_product_id: '752'
            shop_id: '2032'
          }
        }
      ]
    }]

    @multiple_beacon_data_array = [
      {
        url: 'some_url'
        shop_code: 'SA-XXXX-Y'
        actions: [{
          category: 'site'
          type: 'sendPageView'
        }]
      },
      {
        url: 'some_url'
        shop_code: 'SA-XXXX-Y'
        actions: [{
          category: 'yogurt'
          type: 'productClick'
          data: {
            product_id: '15400722'
            shop_product_id: '752'
            shop_id: '2032'
          }
        }]
      },
      {
        url: 'some_url'
        shop_code: 'SA-XXXX-Y'
        actions: [{
          category: 'yogurt'
          type: 'productClick'
          data: {
            product_id: '15400722'
            shop_product_id: '752'
            shop_id: '2032'
          }
        }]
      }
    ]

    @mockup_dom_methods = =>
      @createElement_stub = sinon.stub()
      document.createElement = @createElement_stub.returns({})
      Node::insertBefore = (who, where)-> who.onload()

    @start = =>
      @subject = new @reporter()
      @handleJob_spy = sinon.spy(@subject, '_handleJob')
      @report_spy = sinon.spy(@subject, 'report')
      @clock.tick 10

    @serialized_data = '?url=some_url&shop_code=SA-XXXX-Y&actions=%5B%7B%22category%22%3A%22site%22%2C%22type%22%3A%22sendPageView%22%7D%2C%7B%22category%22%3A%22yogurt%22%2C%22type%22%3A%22productClick%22%2C%22data%22%3A%7B%22product_id%22%3A%2215400722%22%2C%22shop_product_id%22%3A%22752%22%2C%22shop_id%22%3A%222032%22%7D%7D%2C%7B%22category%22%3A%22yogurt%22%2C%22type%22%3A%22productClick%22%2C%22data%22%3A%7B%22product_id%22%3A%2215400722%22%2C%22shop_product_id%22%3A%22752%22%2C%22shop_id%22%3A%222032%22%7D%7D%5D'
    window.__requirejs__.clearRequireState()
    require ['promise', 'settings'], (Promise, Settings) =>
      @promise = Promise
      @settings = Settings

      # mock BrowserHelper
      requirejs.undef 'helpers/browser_helper'

      class BrowserHelperMock
        @checkImages: ->
          promise = new Promise()

          ## TODO EXPLAIN THE REGRESSION TEST
          setTimeout ->
            # console.log 'RESOLVING CHECK IMAGE WITH TRUE'
            promise.resolve(true)
          , 0

          promise

      @browser_helper = BrowserHelperMock

      define 'helpers/browser_helper', [], ->
        return BrowserHelperMock

      # require modules
      require ['reporter'], (Reporter) =>
        @reporter = Reporter
        done()

  after ->
    requirejs.undef 'helpers/browser_helper'
    window.__requirejs__.clearRequireState()

  beforeEach ->
    @clock = sinon.useFakeTimers()
    @_createElement = document.createElement
    @_insertBefore  = Node::insertBefore

  afterEach ->
    @clock.restore()
    @createElement_stub?.reset()

    @report_spy?.restore()
    @handleJob_spy?.restore()

    document.createElement = @_createElement
    Node::insertBefore = @_insertBefore

  describe 'instance', ->
    beforeEach ->
      @subject = new @reporter()
      @clock.tick 10

    it 'has own property transport', ->
      expect(@subject).to.have.ownProperty('transport')

    it 'has own property transport_ready', ->
      expect(@subject).to.have.ownProperty('transport_ready')

    it 'responds to report', ->
      expect(@subject).to.respondTo('report')

    it 'responds to then', ->
      expect(@subject).to.respondTo('then')

  describe 'API', ->
    describe '#then', ->
      beforeEach ->
        @checkImage_promise = new @promise()
        @checkImage_stub = sinon.stub(@browser_helper, 'checkImages').returns(@checkImage_promise)

      afterEach ->
        @checkImage_stub.restore()

      it 'returns a promise', ->
        @subject = new @reporter()
        res = @subject.then()
        expect(res).to.be.an.instanceof @promise

      it 'calls success argument when transport_ready succeeds', (done)->
        @subject = new @reporter()
        @success = ->
          expect(true).to.equal(true)
          done()
        @failure = ->
          expect(true).to.equal(false)
          done()
        res = @subject.then(@success, @failure)
        @checkImage_promise.resolve()

      it 'calls error argument when transport_ready fails', (done)->
        @subject = new @reporter()
        @success = ->
          expect(true).to.equal(false)
          done()
        @failure = ->
          expect(true).to.equal(true)
          done()
        res = @subject.then(@success, @failure)
        @checkImage_promise.reject()

    describe '#report', ->
      beforeEach ->
        @mockup_dom_methods()

      it 'returns a promise', (done)->
        @start()
        result = @subject.report(@url, @single_beacon_data_array)
        result.then =>
          expect(result).to.be.an.instanceof @promise
          done()

      it 'accepts as 1st argument the url to report to', (done)->
        @start()
        @subject.report(@url, @single_beacon_data_array).then =>
          expect(@report_spy.args[0][0]).to.equal @url
          done()

      it 'accepts as 2nd argument to be the data_array', (done)->
        @start()
        @subject.report(@url, @single_beacon_data_array).then =>
          expect(@report_spy.args[0][1]).to.deep.equal @single_beacon_data_array
          done()

      context 'when we have multiple data items to report', ->
        it 'creates multiple transport elements', (done)->
          @start()

          callback = =>
            expect(@createElement_stub.callCount).to.equal 3
            done()

          @subject.report(@url, @multiple_beacon_data_array).then callback, callback

        it 'gives every transport element its own promise', (done)->
          @clock.restore()
          @start()

          callback = =>
            ids = []
            length = 0
            for call in @handleJob_spy.getCalls()
              id = call.args[2]._id
              if !ids[id]
                ids[id] = true
                length += 1

            expect(length).to.equal @multiple_beacon_data_array.length
            done()

          @subject.report(@url, @multiple_beacon_data_array).then callback, callback

        it 'waits for every transport element to finish before fulfilling the promise returned', (done)->
          @start()
          callback = =>
            states = []
            for call in @handleJob_spy.getCalls()
              states.push call.args[2].state

            expect(states).to.not.contain 'pending'
            done()

          @subject.report(@url, @multiple_beacon_data_array).then callback, callback

      context 'when we have one data to report', ->
        it 'creates one transport element', (done)->
          @start()

          callback = =>
            expect(@createElement_stub.callCount).to.equal 1
            done()

          @subject.report(@url, @single_beacon_data_array).then callback, callback

        it 'gives transport element its own promise', (done)->
          @clock.restore()
          @start()

          callback = =>
            ids = []
            length = 0
            for call in @handleJob_spy.getCalls()
              id = call.args[2]._id
              if !ids[id]
                ids[id] = true
                length += 1

            expect(length).to.equal @single_beacon_data_array.length
            done()

          @subject.report(@url, @single_beacon_data_array).then callback, callback

        it 'waits for every transport element to finish before fulfilling the promise returned', (done)->
          @start()
          callback = =>
            states = []
            for call in @handleJob_spy.getCalls()
              states.push call.args[2].state

            expect(states).to.not.contain 'pending'
            done()

          @subject.report(@url, @single_beacon_data_array).then callback, callback

  describe 'Reporting', ->
    beforeEach ->
      @mockup_dom_methods()

    it 'serializes data', (done)->
      @start()
      callback = =>
        transport = @createElement_stub.returnValues[0]
        expect(transport.src).to.contain("#{@url}#{@serialized_data}")
        done()
      @subject.report(@url, @single_beacon_data_array).then callback, callback
      done()

    it 'appends a cache busting param in the transport url', (done)->
      @start()
      callback = =>
        transport = @createElement_stub.returnValues[0]
        expect(transport.src).to.contain('buster=')
        done()
      @subject.report(@url, @single_beacon_data_array).then callback, callback

    context 'when images are disabled', ->
      beforeEach ->
        @checkImage_stub = sinon.stub(@browser_helper, 'checkImages').returns( new @promise().resolve(false) )

      afterEach ->
        @checkImage_stub.restore()

      it 'creates script element transports', (done)->
        @start()
        callback = =>
          expect(@createElement_stub.args[0][0]).to.equal('script')
          done()
        @subject.report(@url, @single_beacon_data_array).then callback, callback


    context 'when images are enabled', ->
      beforeEach ->
        @checkImage_stub = sinon.stub(@browser_helper, 'checkImages').returns( new @promise().resolve(true) )

      afterEach ->
        @checkImage_stub.restore()

      it 'creates image element transports', (done)->
        @start()
        callback = =>
          expect(@createElement_stub.args[0][0]).to.equal('img')
          done()
        @subject.report(@url, @single_beacon_data_array).then callback, callback
