_                  = require 'lodash'
debug              = require('debug')('christacheio')
escapeStringRegexp = require 'escape-string-regexp'

regexMatches = (regexString, string) ->
  regex = new RegExp regexString, 'g'

  matches = []
  while match = regex.exec string
    matches.push match[1]
  return matches;

stachest = (stacheString, obj, options={}) ->
  return stacheString if ! _.isString stacheString

  {tags,transformation,negationCharacters} = options
  tags ?= ['{{', '}}']
  negationCharacters ?= '}{'
  transformation ?= (data) -> data
  [startTag, endTag] = tags
  regexStr = "#{startTag}([^#{negationCharacters}]*?)#{endTag}"
  transformedMatches = {}

  newStache = _.clone stacheString

  _.each regexMatches(regexStr, stacheString), (key) ->
    value = _.get obj, key
    transformedMatches[key] = transformation(value) if value?
    transformedMatches[key] ?= null # you need this

  _.each transformedMatches, (value, key) ->
    escapedKey = escapeStringRegexp key
    tag = "#{startTag}#{escapedKey}#{endTag}"
    return newStache = value if tag == stacheString and value?
    regex = new RegExp(tag, 'g')
    newStache = newStache.replace regex, value

  return newStache

stacheception = (stache, obj, options, limbo=[]) ->
  limbo.push stache
  _.forOwn stache, (value, key) ->
    return if _.includes limbo, value
    return stache[key] = stacheception value, obj, options, limbo if _.isObject value
    stache[key] = stachest value, obj, options

christacheio = (stache, obj, options) ->
  return stachest stache, obj, options if ! _.isObject stache
  return stacheception stache, obj, options

module.exports = christacheio
