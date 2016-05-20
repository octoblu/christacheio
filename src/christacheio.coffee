_                  = require 'lodash'
debug              = require('debug')('christacheio')
escapeStringRegexp = require 'escape-string-regexp'

regexMatches = (regexString, string) ->
  regex = new RegExp regexString, 'g'

  matches = []
  while match = regex.exec string
    matches.push match[1]
  return matches;

christacheio = (stache, obj, options={}) ->

  stachest = (stacheString) ->
    return stacheString if ! _.isString stacheString

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

  return stachest stache if _.isString stache
  return stache if ! _.isObject stache

  limbo = []
  stacheception = (stache) ->
    limbo.push stache
    _.forOwn stache, (value, key) ->
      return if _.includes limbo, value
      return stache[key] = stacheception value if _.isObject value
      stache[key] = stachest value

  return stacheception stache

module.exports = christacheio
