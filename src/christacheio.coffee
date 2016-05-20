_                  = require 'lodash'
debug              = require('debug')('christacheio')
escapeStringRegexp = require 'escape-string-regexp'

stachematch = (stacheExp, string) ->
  regex = new RegExp stacheExp, 'g'
  matches = []
  while match = regex.exec string
    matches.push match[1]
  return matches;

stachest = (stacheString, obj, options={}, depth=1) ->
  return stacheString if ! _.isString stacheString

  {tags,transformation,negationCharacters} = options
  tags ?= ['{{', '}}']
  negationCharacters ?= '}{'
  transformation ?= (data) -> data
  [startTag, endTag] = tags
  stacheExp = "#{startTag}([^#{negationCharacters}]*?)#{endTag}"
  transformedMatches = {}
  newStache = _.clone stacheString

  _.each stachematch(stacheExp, stacheString), (key) ->
    value = _.get obj, key
    transformedMatches[key] = transformation(value) if value?
    transformedMatches[key] ?= null # you need this

  _.each transformedMatches, (value, key) ->
    escapedKey = escapeStringRegexp key
    tag = "#{startTag}#{escapedKey}#{endTag}"
    return newStache = value if tag == stacheString and value?
    stachex = new RegExp(tag, 'g')
    newStache = newStache.replace stachex, value

  stachemore = depth < options.recurseDepth and newStache != stacheString
  return stachest newStache, obj, options, depth+1 if stachemore
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
