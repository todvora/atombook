path = require 'path'
fs = require 'fs'
gitbookParsers = require 'gitbook-parsers'
Q = require 'q'
_ = require 'lodash'

module.exports =
class Articles

  constructor: (@filename) ->

  exists: ->
    deferred = Q.defer()
    fs.exists @filename, (exists) =>
      if exists
        deferred.resolve @filename
      else
        deferred.reject new Error('File ' + filename + ' not found in the local system.')
      return
    deferred.promise

  parse: (filePath)=>
    text = fs.readFileSync(filePath,  {encoding: 'utf8'})
    gitbookParsers.getForFile(filePath).summary(text).then (summary) =>
      @summary = summary
      Q.resolve @summary

  read: ->
    @exists().then (path) =>
      @parse path

  get: ->
    @summary

  save: ->
    Q.reject new Error('Not implemented yet')

  # do I need to write the content back? Should I read only?
  toMarkdown: ->
    result = '# Summary \n\n'

    serializeArticle = (article, depth) ->
        Array(4*depth).join(' ') + '* ['+article.title+']('+article.path+')'

    serializeList = (articles, depth) ->
      result = ''
      articles.forEach (article) ->
        result += serializeArticle(article, depth) + '\n'
        if article.articles.length
          result = result + serializeList(article.articles, depth + 1)
      result

    result = result + serializeList(@summary.chapters, 0)
