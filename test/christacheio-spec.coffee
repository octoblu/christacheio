christacheio = require '../src/christacheio'

describe 'christacheio', ->
  describe 'when called', ->
    it 'should not crash, I guess?', ->
      christacheio()

  describe 'when called with a string and an object', ->
    beforeEach ->
      @result = christacheio '{{nut}}', nut: 'pistachio'

    it 'should replace the mustached area', ->
      expect(@result).to.deep.equal 'pistachio'

  describe 'when called with a string without a key', ->
    beforeEach ->
      @result = christacheio '{{}}', nut: 'pistachio'

    it 'should replace the mustached area', ->
      expect(@result).to.deep.equal 'null'

  describe 'when called with a repetitive string and an object', ->
    beforeEach ->
      @result = christacheio '{{nut}}:{{nut}}', nut: 'pistachio'

    it 'should replace the mustached area', ->
      expect(@result).to.deep.equal 'pistachio:pistachio'

  describe 'when called with an string that references an unknown key', ->
    beforeEach ->
      @result = christacheio '{{nut}}', {}

    it 'should replace the mustached area with a null', ->
      expect(@result).to.deep.equal 'null'

  describe 'when called with custom tags', ->
    beforeEach ->
      @result = christacheio '"<<nut>>"', nut: 'pistachio', {tags: ['"<<', '>>"']}

    it 'should replace the mustached area', ->
      expect(@result).to.deep.equal 'pistachio'

  describe 'when called with two passes, like the engine', ->
    beforeEach ->
      firstPass = christacheio '{{nut}}:{{nut}}', {}, {tags: ['"{{', '}}"'], transformation: JSON.stringify}
      @result = christacheio firstPass, nut: 'pistachio'

    it 'should replace the mustached area', ->
      expect(@result).to.deep.equal 'pistachio:pistachio'

  describe 'when called with a embedded repetitive string and an object', ->
    beforeEach ->
      @result = christacheio 'f{{nut}}:{{nut}}z', nut: 'pistachio'

    it 'should replace the mustached area', ->
      expect(@result).to.deep.equal 'fpistachio:pistachioz'

  describe 'when called with string and a nested object', ->
    beforeEach ->
      @result = christacheio '{{legume.nut}}', legume: {nut: 'almond'}

    it 'should replace the mustached area', ->
      expect(@result).to.deep.equal 'almond'

  describe 'when called with custom tags', ->
    beforeEach ->
      tags = ['<','>']
      @result = christacheio '<nut>', {nut: 'walnut'}, tags: tags

    it 'should replace the mustached area', ->
      expect(@result).to.deep.equal 'walnut'
