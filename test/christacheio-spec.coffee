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
      expect(@result).to.deep.equal null

  describe 'when called with a repetitive string and a delimiter and an object', ->
    beforeEach ->
      @result = christacheio '{{nut}}:{{nut}}', nut: 'pistachio'

    it 'should replace the mustached area', ->
      expect(@result).to.deep.equal 'pistachio:pistachio'

  describe 'when called with a repetitive string and an object', ->
    beforeEach ->
      @result = christacheio '{{nut}}{{nut}}', nut: 'pistachio'

    it 'should replace the mustached area', ->
      expect(@result).to.deep.equal 'pistachiopistachio'

  describe 'when called with an string that references an unknown key', ->
    beforeEach ->
      @result = christacheio '{{nut}}', {}

    it 'should replace the mustached area with a null', ->
      expect(@result).to.deep.equal null

  describe 'when called with custom tags', ->
    beforeEach ->
      @result = christacheio '"<<nut>>"', nut: 'pistachio', {tags: ['"<<', '>>"']}

    it 'should replace the mustached area', ->
      expect(@result).to.deep.equal 'pistachio'

  describe 'when called with two passes, like the engine', ->
    beforeEach ->
      sampleObject =
        blargh: '{{nut}}'

      template = JSON.stringify sampleObject

      firstPass = christacheio template, nut: 'pistachio', {tags: ['"{{', '}}"'], transformation: JSON.stringify}
      @result = christacheio firstPass, nut: 'pistachio'

    it 'should replace the mustached area', ->
      expect(@result).to.deep.equal '{"blargh":"pistachio"}'

  describe 'when called with two passes, with multiple tags like the engine', ->
    beforeEach ->
      sampleObject =
        blargh: '{{nut}}{{nut}}'

      template = JSON.stringify sampleObject

      firstPass = christacheio template, nut: 'pistachio', {tags: ['"{{', '}}"'], transformation: JSON.stringify}
      @result = christacheio firstPass, nut: 'pistachio'

    it 'should replace the mustached area', ->
      expect(@result).to.deep.equal '{"blargh":"pistachiopistachio"}'

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

  describe 'when called with a christacheio as the entire string and an object value', ->
    beforeEach ->
      @result = christacheio '{{nut}}', nut: favorite: 'pecan'

    it 'should return an object instead of a string', ->
      expect(@result).to.deep.equal favorite: 'pecan'

  describe 'when called with a string containing an object value and no transformation', ->
    beforeEach ->
      @result = christacheio '{{nut}}...?', nut: favorite: 'pecan'

    it 'should replace the mustached area with [object Object]', ->
      expect(@result).to.deep.equal '[object Object]...?'

  describe 'when called with a string containing an object key and a transformation', ->
    beforeEach ->
      @result = christacheio '{{nut}}...?', {nut: favorite: 'pecan'}, {transformation: JSON.stringify}

    it 'should replace the mustached area with JSON stringified version of the object', ->
      expect(@result).to.deep.equal '{"favorite":"pecan"}...?'

  describe 'when called with a number instead of a string', ->
    beforeEach ->
      @result = christacheio 1337, nut: 'wall'

    it 'should return the number', ->
      expect(@result).to.deep.equal 1337

  describe 'when called with an object to be christacheiod', ->
    beforeEach ->
      @result = christacheio {hello:'{{nut}}',world:'earth',winner:true}, {nut: 'wall'}

    it 'should replace the mustached area', ->
      expect(@result).to.deep.equal {hello:'wall',world:'earth',winner:true}

  describe 'when called with a deep object to be christacheiod', ->
    beforeEach ->
      @result = christacheio {outer:planet:'{{nut}}'}, {nut: 'macadamia'}

    it 'should replace the deep mustached area', ->
      expect(@result).to.deep.equal {outer:planet:'macadamia'}

  describe 'when called with a circular object to be christacheiod', ->
    beforeEach ->
      circular = {outer:planet:'{{nut}}'}
      circular.circular = circular
      @result = christacheio circular, {nut: 'macadamia'}

    it 'should not stack overflow and replace the deepest mustached area', ->
      expect(@result.outer.planet).to.deep.equal 'macadamia'
      expect(@result.circular.circular.circular.outer.planet).to.deep.equal 'macadamia'

  describe 'when called with a string and an object and recurseDepth not set', ->
    beforeEach ->
      @result = christacheio '{{nut}}', {nut: '{{chocolate}}', chocolate: '{{covered}}', covered: 'peanut'}

    it 'should replace the mustached area with another mustache label', ->
      expect(@result).to.deep.equal '{{chocolate}}'

  describe 'when called with a string and an object and recurseDepth of 2', ->
    beforeEach ->
      @result = christacheio '{{nut}}', {nut: '{{chocolate}}', chocolate: '{{covered}}', covered: 'peanut'}, {recurseDepth:2}

    it 'should recursively replace the mustached area', ->
      expect(@result).to.deep.equal '{{covered}}'

  describe 'when called with a string and an object and recurseDepth of 9000', ->
    beforeEach ->
      @result = christacheio '{{nut}}', {nut: '{{chocolate}}', chocolate: '{{covered}}', covered: 'peanut'}, {recurseDepth:9000}

    it 'should recursively replace the mustached area to completion', ->
      expect(@result).to.deep.equal 'peanut'

  describe 'when called with an array of christacheios', ->
    beforeEach ->
      @result = christacheio ['{{nut}}','{{nutella}}'], {nut: 'cracker', nutella: 'hazel'}

    it 'should replace elements of the mustached array', ->
      expect(@result).to.deep.equal ['cracker','hazel']

  describe 'when called with a complex object with array of recursive christacheios', ->
    beforeEach ->
      @result = christacheio {large:tin:['{{nut}}','{{nutella}}']},
        {nut: '{{cracker}}', nutella: '{{hazel}}', cracker: 'ballet', hazel:'spread'},
        {recurseDepth:2}

    it 'should recurse and replace elements of the mustached array', ->
      expect(@result).to.deep.equal large:tin:['ballet','spread']
