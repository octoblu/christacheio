_                  = require 'lodash'
debug              = require('debug')('christacheio')
escapeStringRegexp = require 'escape-string-regexp'

regexMatches = (regexString, string) ->
  regex = new RegExp regexString, 'g'

  matches = []
  while match = regex.exec string
    matches.push match[1]
  return matches;

christacheio = (jsonString, obj, options={}) ->
  {tags,transformation} = options
  tags ?= ['{{', '}}']
  transformation ?= (data) -> data
  [startTag, endTag] = tags
  regexStr = "#{startTag}(.+?)#{endTag}"
  transformedMatches = {}

  newJsonString = _.clone jsonString

  _.each regexMatches(regexStr, jsonString), (key) ->
    value = _.get obj, key
    transformedMatches[key] = transformation(value) if value?

  _.each transformedMatches, (value, key) ->
    escapedKey = escapeStringRegexp key
    regex = new RegExp "#{startTag}#{escapedKey}#{endTag}", 'g'
    newJsonString = newJsonString.replace regex, transformedMatches[key]

  return newJsonString

module.exports = christacheio
