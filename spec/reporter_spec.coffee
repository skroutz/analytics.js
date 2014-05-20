describe 'Reporter', ->
  @timeout(0) # Disable the spec's timeout

  before (done) ->
    window.__requirejs__.clearRequireState()
    require ['promise'], (Promise) =>
      @promise = Promise

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
    @payload = {k1: 'v1', k2: 'v2'}
    @url_with_payload = 'foo.bar?k1=%22v1%22&k2=%22v2%22'

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
      @pr = new @promise()
      @subject = new @reporter()

    it 'returns a promise', ->
      res = @subject.report(@url, @payload)
      expect(res).to.be.an.instanceof @promise

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
      expect(@stub).to.be.calledWith(@pr, @url_with_payload)
