_      = require 'lodash'
debug  = require('debug')('christacheio')
escape = require 'escape-string-regexp'

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

  negationCharacters ?= _.uniq(tags.join '').join ''
  transformation ?= (data) -> data
  [startTag, endTag] = tags
  stacheExp = "#{escape startTag}([^#{escape negationCharacters}]*?)#{escape endTag}"
  transformedMatches = {}
  newStache = _.clone stacheString

  _.each stacheMatch(stacheExp, stacheString), (key) ->
    value = _.get obj, key
    transformedMatches[key] = transformation(value) if value?
    transformedMatches[key] ?= null # you need this

  _.each transformedMatches, (value, key) ->
    key = "#{startTag}#{key}#{endTag}"
    return newStache = value if key == stacheString
    escapedKey = escape key
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

christacheio = (stache, obj, options) ->
  return stachest stache, obj, options if ! _.isObject stache
  return stacheception stache, obj, options

module.exports = christacheio
