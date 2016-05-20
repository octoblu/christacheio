_                  = require 'lodash'
debug              = require('debug')('christacheio')
escapeStringRegexp = require 'escape-string-regexp'

stacheMatch = (stacheExp, stacheString) ->
  regex = new RegExp stacheExp, 'g'
  matches = []
  while match = regex.exec stacheString
    matches.push match[1]
  return matches

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

  _.each stacheMatch(stacheExp, stacheString), (key) ->
    value = _.get obj, key
    transformedMatches[key] = transformation(value) if value?
    transformedMatches[key] ?= null # you need this

  _.each transformedMatches, (value, key) ->
    key = "#{startTag}#{key}#{endTag}"
    return newStache = value if key == stacheString
    escapedKey = escapeStringRegexp key
    debug "key: #{key}, stacheString: #{stacheString}"
    regex = new RegExp(escapedKey, 'g')
    newStache = newStache.replace regex, value

  stachemore = depth < options.recurseDepth and newStache != stacheString
  return stachest newStache, obj, options, depth+1 if stachemore
  return newStache

stacheception = (stache, obj, options, limbo=[]) ->
  limbo.push stache
  _.forOwn stache, (value, key) ->
    return if _.includes limbo, value
    return stache[key] = stacheception value, obj, options, limbo if _.isObject value
    stache[key] = stachest value, obj, options
    debug "#{JSON.stringify obj} : #{JSON.stringify value} -> #{JSON.stringify stache[key]}" if value != stache[key]

christacheio = (stache, obj, options) ->
  return stachest stache, obj, options if ! _.isObject stache
  return stacheception stache, obj, options

module.exports = christacheio
