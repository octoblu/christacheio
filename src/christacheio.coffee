_                  = require 'lodash'
debug              = require('debug')('christacheio')
escapeStringRegexp = require 'escape-string-regexp'

regexMatches = (regexString, string) ->
  regex = new RegExp regexString, 'g'

  matches = []
  while match = regex.exec string
    matches.push match[1]
  return matches;

christacheio = (stacheString, obj, options={}) ->
  {tags,transformation,negationCharacters} = options
  tags ?= ['{{', '}}']
  negationCharacters ?= '}{'
  transformation ?= (data) -> data
  [startTag, endTag] = tags
  regexStr = "#{startTag}([^#{negationCharacters}]*?)#{endTag}"
  transformedMatches = {}

  newStacheString = _.clone stacheString

  _.each regexMatches(regexStr, stacheString), (key) ->
    value = _.get obj, key
    transformedMatches[key] = transformation(value) if value?
    transformedMatches[key] ?= null # you need this

  _.each transformedMatches, (value, key) ->
    escapedKey = escapeStringRegexp key
    tag = "#{startTag}#{escapedKey}#{endTag}"
    return newStacheString = value if tag == stacheString and value?
    regex = new RegExp(tag, 'g')
    newStacheString = newStacheString.replace regex, value

  return newStacheString

module.exports = christacheio
