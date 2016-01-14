describe 'JSONP', ->
  before (done) ->
    require ['jsonp', 'promise', 'helpers/url_helper'], (JSONP, Promise, URLHelper) =>
      @jsonp = JSONP
      @promise = Promise
      @url_helper = URLHelper

      done()

  describe '#fetch', ->
    beforeEach ->
      @documentCreateElement_stub = sinon.stub(document, 'createElement').returns({})
      @NodeAppendChild_stub = sinon.stub(Node::, 'appendChild')

      @callbackName_stub = sinon.stub(@jsonp, '_callbackName').returns('callback_name')
      @load_spy = sinon.spy(@jsonp, 'load')
      @query_spy = sinon.spy(@jsonp, '_query')

      @url = 'http://example.jsonp'
      @data = { param1: 'param1', param2: 'param2' }
      @subject = @jsonp.fetch(@url, @data)

      @response = root: {}
      window.callback_name(@response)

    afterEach ->
      @documentCreateElement_stub.restore()
      @NodeAppendChild_stub.restore()

      @callbackName_stub.restore()
      @load_spy.restore()
      @query_spy.restore()

    it 'loads the script', ->
      expect(@load_spy.withArgs(@url, @data).calledOnce).to.be.true

    it 'appends the url params to script src', ->
      expect(@query_spy.withArgs(@url, @data).calledOnce).to.be.true

    it 'serializes the params', ->
      expect(@query_spy.returned(@url_helper.appendData(@url, @url_helper.serialize(@data)))).to.be.true

    it 'returns a Promise', ->
      expect(@subject).to.be.instanceof(@promise)

    describe 'Promise', ->
      it 'should be be resolved with the response', (done)->
        @subject.then (res) =>
          expect(res).to.equal(@response)
          done()
