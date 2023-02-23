describe 'URLHelper', ->
  before (done) ->
    require ['helpers/url_helper', 'settings'], (UrlHelper, Settings) =>
      @settings = Settings
      @subject = UrlHelper
      done()

  describe 'API', ->
    it 'responds to appendData', ->
      expect(@subject).to.respondTo('appendData')

    it 'responds to replaceParam', ->
      expect(@subject).to.respondTo('replaceParam')

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

    context 'when url contains hash', ->
      context 'and url already contains parameters', ->
        it 'appends properly the payload using & preserving hash', ->
          url = 'http://foo.bar?foo=bar#/weird#hash?value'
          payload = 'foo2=bar2'

          expect(@subject.appendData(url, payload))
            .to.equal('http://foo.bar?foo=bar&foo2=bar2#/weird#hash?value')

      context 'and url does not contain parameters', ->
        it 'appends properly the payload using ? preserving hash', ->
          url = 'http://foo.bar#/weird#hash?value'
          payload = 'foo2=bar2'

          expect(@subject.appendData(url, payload))
            .to.equal('http://foo.bar?foo2=bar2#/weird#hash?value')

  describe '.replaceParam', ->
    context 'when replacing first param', ->
      it 'replaces the given param', ->
        url = 'http://foo.bar?foo=xxx&zzz=bar'
        param = 'foo'
        new_value = 'yyyy'

        expect(@subject.replaceParam(url, param, new_value))
          .to.equal('http://foo.bar?foo=yyyy&zzz=bar')

    context 'when replacing non-first param', ->
      it 'replaces the given param', ->
        url = 'http://foo.bar?foo=xxx&zzzz=zbar&zzz=bar'
        param = 'zzz'
        new_value = 'pub'

        expect(@subject.replaceParam(url, param, new_value))
          .to.equal('http://foo.bar?foo=xxx&zzzz=zbar&zzz=pub')

    context 'when param name is escaped', ->
      it 'replaces the given param', ->
        url = "http://foo.bar?#{encodeURIComponent('ελληνικά')}=xxxx"
        param = 'ελληνικά'
        new_value = 'yyyy'

        expect(@subject.replaceParam(url, param, new_value))
          .to.equal("http://foo.bar?#{encodeURIComponent('ελληνικά')}=yyyy")

    context 'when param name is not escaped and contains non-ascii characters', ->
      it 'replaces the given param', ->
        url = "http://foo.bar?ελληνικά=xxxx"
        param = 'ελληνικά'
        new_value = 'yyyy'

        expect(@subject.replaceParam(url, param, new_value))
          .to.equal("http://foo.bar?ελληνικά=yyyy")

  describe '.serialize', ->
    beforeEach ->
      @o = {
        foo: 'bar'
      }
      @serialize = @subject.serialize

    context 'when param is null', ->
      it 'returns false', ->
        expect(@serialize(null)).to.equal(false)

    context 'when param is undefined', ->
      it 'returns false', ->
        expect(@serialize(null)).to.equal(false)

    context 'when param is string', ->
      it 'returns false', ->
        expect(@serialize('foo')).to.equal(false)

    context 'when param is json', ->
      it 'returns proper serialized string', ->
        o = {
          "foo1": '=&foo10=bar10&'
          "foo2": "bar '2'"
          "foo3": "bar 3"
        }
        q = "foo1=%3D%26foo10%3Dbar10%26&foo2=bar%20'2'&foo3=bar%203"
        expect(@serialize(o)).to.equal(q)

    context 'when param contains nested object', ->
      it 'returns proper serialized string', ->
        o = {
          foo1: '=&foo10=bar10&'
          foo2: "bar '2'"
          foo3: {
            k1: 'v1'
            k2: 'v2'
          }
        }
        q = "foo1=%3D%26foo10%3Dbar10%26&foo2=bar%20'2'&foo3=%7B%22k1%22%3A%22v1%22%2C%22k2%22%3A%22v2%22%7D"
        expect(@serialize(o)).to.equal(q)

  describe '.extractGetParam', ->
    beforeEach ->
      @current_url_backup = @settings.url.current
      @settings.url.current = 'http://foo.bar?foo=bar&zzz=xxx'

    afterEach ->
      @settings.url.current = @current_url_backup

    it 'acceps param_name as first argument', ->
      expect(@subject.extractGetParam('zzz')).to.equal('xxx')

    it 'acceps url to search into as second argument', ->
      url = 'http://foo.bar?foo=xxx&zzz=bar'

      expect(@subject.extractGetParam('zzz', url)).to.equal('bar')

    it 'searches on the current.url if no second argument is passed', ->
      expect(@subject.extractGetParam('zzz')).to.equal('xxx')

    it 'returns the proper get param', ->
      expect(@subject.extractGetParam('foo')).to.equal('bar')

  describe '.getParamsFromUrl', ->
    it 'returns the proper JSON object', ->
      url = 'http://foo.bar?foo=bar'
      params = { foo: 'bar' }

      expect(@subject.getParamsFromUrl(url)).to.deep.equal(params)

    context 'when contains a malformed param without a key', ->
      it 'returns the proper JSON object', ->
        url = "http://foo.bar?foo=bar&=xxxx&baz=qux"
        params = { '': 'xxxx', foo: 'bar', baz: 'qux' }

        expect(@subject.getParamsFromUrl(url)).to.deep.equal(params)

      it 'returns the proper JSON object', ->
        url = "http://foo.bar?=bar&=xxxx&foo=bar"
        params = { '': 'xxxx', foo: 'bar' }

        expect(@subject.getParamsFromUrl(url)).to.deep.equal(params)

      it 'returns the proper JSON object', ->
        url = "http://foo.bar?foo=bar&=xxxx&=zzzz"
        params = { '': 'zzzz', foo: 'bar' }

        expect(@subject.getParamsFromUrl(url)).to.deep.equal(params)

    context 'when contains a malformed param without a value', ->
      it 'returns the proper JSON object', ->
        url = "http://foo.bar?foo=bar&xxxx=&baz=qux"
        params = { xxxx: '', foo: 'bar', baz: 'qux' }

        expect(@subject.getParamsFromUrl(url)).to.deep.equal(params)

      it 'returns the proper JSON object', ->
        url = "http://foo.bar?xxxx=&zzzz=&foo=bar"
        params = { xxxx: '', zzzz: '', foo: 'bar' }

        expect(@subject.getParamsFromUrl(url)).to.deep.equal(params)

      it 'returns the proper JSON object', ->
        url = "http://foo.bar?foo=bar&xxxx=&zzzz="
        params = { xxxx: '', zzzz: '', foo: 'bar' }

        expect(@subject.getParamsFromUrl(url)).to.deep.equal(params)

    context 'when contains an escaped param name', ->
      it 'replaces the given param', ->
        url = "http://foo.bar?#{encodeURIComponent('ελλη=νικά')}=xxxx&foo=bar"
        params = { 'ελλη=νικά': 'xxxx', foo: 'bar' }

        expect(@subject.getParamsFromUrl(url)).to.deep.equal(params)

    context 'when contains hash', ->
      it 'returns the proper JSON object', ->
        url = 'http://foo.bar?foo=bar#a_hash'
        params = { foo: 'bar' }

        expect(@subject.getParamsFromUrl(url)).to.deep.equal(params)
