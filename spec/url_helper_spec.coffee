describe 'URLHelper', ->
  @timeout(0) # Disable the spec's timeout

  before (done) ->
    require ['helpers/url_helper'], (UrlHelper) =>
      @subject = UrlHelper
      done()

  describe 'API', ->
    it 'responds to appendData', ->
      expect(@subject).to.respondTo('appendData')

    it 'responds to serialize', ->
      expect(@subject).to.respondTo('serialize')

    it 'responds to extractGetParam', ->
      expect(@subject).to.respondTo('extractGetParam')

    it 'responds to getParamsFromUrl', ->
      expect(@subject).to.respondTo('getParamsFromUrl')

  describe '.appendData', ->
    context 'when url already contains parameters', ->
      it 'appends properly the payload using &', ->
        url = 'http://foo.bar?foo=bar'
        payload = 'foo2=bar2'

        expect(@subject.appendData(url, payload))
          .to.equal('http://foo.bar?foo=bar&foo2=bar2')

    context 'when url does not contain parameters', ->
      it 'appends properly the payload using ?', ->
        url = 'http://foo.bar'
        payload = 'foo2=bar2'

        expect(@subject.appendData(url, payload))
          .to.equal('http://foo.bar?foo2=bar2')

  describe '.serialize', ->
    beforeEach ->
      @o = {
        foo: 'bar'
      }
      @serialize = @subject.serialize

    it 'accepts optional parameter should_stringify', ->
      expect(@serialize(@o)).to.equal('foo=bar')

    it 'accepts optional parameter should_stringify that defaults to false', ->
      expect(@serialize(@o))
        .to.equal(@serialize(@o, false))

    context 'when stringify is false', ->
      it 'does not stringify the passed object', ->
        expect(@serialize(@o))
          .to.equal(@serialize(@o, false))
          .and
          .not.equal(@serialize(@o, true))

    context 'when stringify is true', ->
      context 'and object is empty', ->
        it 'returns empty string for empty object', ->
          expect(@serialize('', true)).to.equal('')

      context 'and object is null', ->
        it 'returns empty string for null object', ->
          expect(@serialize(null, true)).to.equal('')

      context 'and object is string', ->
        it 'returns proper serialized string', ->
          q = '0=%22f%22&1=%22o%22&2=%22o%22'
          expect(@serialize('foo', true)).to.equal(q)

      context 'and object is json', ->
        it 'returns proper serialized string', ->
          o = {
            foo1: '=&foo10=bar10&'
            foo2: "bar '2'"
            foo3: "bar 3"
          }
          q = "foo1=%22%3D%26foo10%3Dbar10%26%22&foo2=%22bar%20'2'%22&foo3=%22"
          q += "bar%203%22"
          expect(@serialize(o, true)).to.equal(q)

      context 'and object contains nested object', ->
        it 'returns proper serialized string', ->
          o = {
            foo1: '=&foo10=bar10&'
            foo2: "bar '2'"
            foo3: {
              k1: 'v1'
              k2: 'v2'
            }
          }
          q = "foo1=%22%3D%26foo10%3Dbar10%26%22&foo2=%22bar%20'2'%22&foo3=%7B"
          q += "%22k1%22%3A%22v1%22%2C%22k2%22%3A%22v2%22%7D"
          expect(@serialize(o, true)).to.equal(q)

  describe '.extractGetParam', ->
    it 'returns the proper get param', ->
      url = 'http://foo.bar?foo=bar'
      o = {
        foo: 'bar'
      }
      stub = sinon.stub(@subject, 'getParamsFromUrl').returns(o)

      expect(@subject.extractGetParam('foo')).to.equal('bar')
      stub.restore()

  describe '.getParamsFromUrl', ->
    it 'returns the proper JSON object', ->
      url = 'http://foo.bar?foo=bar'
      o = {
        foo: 'bar'
      }

      expect(@subject.getParamsFromUrl(url)).to.deep.equal(o)
