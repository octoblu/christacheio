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
    return

  _.each transformedMatches, (value, key) ->
    key = "#{startTag}#{key}#{endTag}"
    if key == stacheString
      newStache = value
      return
    escapedKey = escape key
    value = JSON.stringify(value) unless _.isString value
    regex = new RegExp(escapedKey, 'g')
    newStache = newStache.replace regex, value
    return

  stachemore = depth < options.recurseDepth and newStache != stacheString
  return stachest newStache, obj, options, depth+1 if stachemore
  return newStache

stacheception = (stache, obj, options, limbo=[]) ->
  limbo.push stache
  _.forOwn stache, (value, key) ->
    return if _.includes limbo, value
    if _.isObject value
      stache[key] = stacheception value, obj, options, limbo
      return
    stache[key] = stachest value, obj, options
    return

christacheio = (stache, obj, options) ->
  return stachest stache, obj, options if ! _.isObject stache
  stache = _.cloneDeep stache
  return stacheception stache, obj, options

module.exports = christacheio
