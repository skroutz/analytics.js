describe 'Reporter', ->
  @timeout(0) # Disable the spec's timeout

  before (done) ->
    window.__requirejs__.clearRequireState()
    require ['promise', 'settings'], (Promise, Settings) =>
      @promise = Promise
      @settings = Settings

      # mock BrowserHelper
      requirejs.undef 'helpers/browser_helper'

      class BrowserHelperMock
        @checkImages: ->
          new Promise().resolve(true)

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
    @img_len_before = document.getElementsByTagName('img').length
    @scr_len_before = document.getElementsByTagName('script').length

    @url = 'foo.bar'
    @payload = {
      url: 'http://www.yogurt.foo/products/show/15400722'
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
      ]
    }
    @serialized_data = 'foo.bar?url=http%3A%2F%2Fwww.yogurt.foo%2Fproducts%2Fshow%2F15400722&shop_code=SA-XXXX-Y&actions=%5B%7B%22category%22%3A%22site%22%2C%22type%22%3A%22sendPageView%22%7D%2C%7B%22category%22%3A%22yogurt%22%2C%22type%22%3A%22productClick%22%2C%22data%22%3A%7B%22product_id%22%3A%2215400722%22%2C%22shop_product_id%22%3A%22752%22%2C%22shop_id%22%3A%222032%22%7D%7D%5D'

  describe 'instance', ->
    beforeEach (done) ->
      @subject = new @reporter()
      done()

    it 'has own property base', ->
      expect(@subject).to.have.ownProperty('base')

    it 'has own property queue', ->
      expect(@subject).to.have.ownProperty('queue')

    it 'has own property transport', ->
      expect(@subject).to.have.ownProperty('transport')

    it 'has own property transport_ready', ->
      expect(@subject).to.have.ownProperty('transport_ready')

    it 'responds to report', ->
      expect(@subject).to.respondTo('report')

    it 'responds to then', ->
      expect(@subject).to.respondTo('then')

  describe '#report', ->
    beforeEach ->
      @subject = new @reporter()
      @pr = new @promise()
      @spy = sinon.spy(@subject, 'report')
      @subject.report(@url, @payload)

    afterEach ->
      @spy.restore()

    it 'accepts as 1st argument the url to report to', ->
      expect(@spy.args[0][0]).to.equal @url

    it 'accepts as 2nd argument the payload to report', ->
      expect(@spy.args[0][1]).to.deep.equal @payload

    describe 'payload argument', ->
      it 'has property String url', ->
        payload = @spy.args[0][1]
        expect(payload)
          .to.have.property('url')
          .that.is.a('string')

      it 'has property String shop_code', ->
        payload = @spy.args[0][1]
        expect(payload)
          .to.have.property('shop_code')
          .that.is.a('string')

      it 'has property Array actions', ->
        payload = @spy.args[0][1]
        expect(payload)
          .to.have.property('actions')
          .that.is.an('array')

    it 'returns a promise', ->
      expect(@subject.report(@url, @payload))
        .to.be.an.instanceof @promise

    context 'when transport uses image', ->
      beforeEach ->
        @subject.transport = 'img'
        @res   = @subject._createTransport(@pr, @url)
        ## Get element's src
        images = document.getElementsByTagName('img')
        @src   = images[images.length - 1].src

      it 'inserts an image element into the DOM', ->
        expect(document.getElementsByTagName('img').length)
          .to.be.above @img_len_before

      describe 'image element', ->
        it 'has the proper url', ->
          expect(@src).to.contain(@url)

        it 'has the buster parameter', ->
          expect(@src).to.contain('buster=')

    context 'when transport uses script', ->
      beforeEach ->
        @subject.transport = 'script'
        @res = @subject._createTransport(@pr, @url)
        ## Get element's src
        @src = document.getElementsByTagName('script')[0].src

      it 'inserts a script element into the DOM', ->
        expect(document.getElementsByTagName('script').length)
          .to.be.above @scr_len_before

      describe 'script element', ->
        it 'has the proper url', ->
          expect(@src).to.contain(@url)

        it 'has the buster parameter', ->
          expect(@src).to.contain('buster=')

  describe '#then', ->
    beforeEach ->
      @pr = new @promise()
      @stub = sinon.stub(@browser_helper, 'checkImages').returns(@pr)

    afterEach ->
      @stub.restore()

    it 'returns a promise', ->
      @subject = new @reporter()
      res = @subject.then(@success, @failure)
      expect(res).to.be.an.instanceof @promise

    context 'when fulfilled', ->
      it 'calls the success callback', (done)->
        @success = ->
          expect(true).to.equal(true)
          done()
        @failure = ->
          expect(true).to.equal(false)
          done()

        @subject = new @reporter()
        res = @subject.then(@success, @failure)
        @pr.resolve()

    context 'when rejected', ->
      it 'calls the failure callback', (done)->
        @success = ->
          expect(true).to.equal(false)
          done()
        @failure = ->
          expect(true).to.equal(true)
          done()

        @subject = new @reporter()
        res = @subject.then(@success, @failure)
        @pr.reject()

  describe '#_determineTransport', ->
    context 'when images are enabled', ->
      it 'sets transport to image', (done) ->
        stub = sinon
          .stub(@browser_helper, 'checkImages')
          .returns(new @promise().resolve(true))

        @subject = new @reporter()
        @subject.then =>
          expect(@subject.transport).to.equal('img')
          stub.restore()
          done()

    context 'when images are not enabled', ->
      it 'sets transport to script', (done) ->
        stub = sinon
          .stub(@browser_helper, 'checkImages')
          .returns((new @promise()).resolve(false))

        @subject = new @reporter()
        @subject.then =>
          expect(@subject.transport).to.equal('script')
          stub.restore()
          done()

  describe '#_handleJob', ->
    beforeEach ->
      @pr = new @promise()
      @subject = new @reporter()
      @stub = sinon.stub(@subject, '_createTransport')

      @subject._handleJob(@url, @payload, @pr)

    afterEach ->
      @stub.restore()

    it 'calls #_createTransport', ->
      expect(@stub).to.be.calledOnce

    it 'calls #_createTransport with proper args', ->
      expect(@stub).to.be.calledWith(@pr, @serialized_data)
