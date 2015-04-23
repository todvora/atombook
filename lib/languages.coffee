path = require 'path'
fs = require 'fs'
gitbookParsers = require 'gitbook-parsers'
Q = require 'q'

module.exports =
class Languages

  constructor: (@filename) ->

  exists: ->
    deferred = Q.defer()
    fs.exists @filename, (exists) =>
      if exists
        deferred.resolve @filename
      else
        deferred.reject new Error('File ' + @filename + ' not found in the local system.')
      return
    deferred.promise

  parse: (filePath)=>
    text = fs.readFileSync(filePath,  {encoding: 'utf8'})
    gitbookParsers.getForFile(filePath).langs(text).then (langs) =>
      @langs = langs
      Q.resolve @langs

  read: ->
    @exists().then (path) =>
      @parse path

  get: ->
    @langs

  save:->
    Q.reject new Error('Not implemented yet')
