path = require 'path'
fs = require 'fs'
gitbookParsers = require 'gitbook-parsers'
Q = require 'q'

Articles = require './articles'
Languages = require './languages'

module.exports =
class Book

  constructor: (@projectPath)  ->

  init: ->
    @languages = new Languages(path.join(@projectPath, 'LANGS.md'))
    @languages.read()
    .then (langs) =>
        Q.resolve langs[0]
    .fail (ex) =>
        Q.resolve {'title': 'Default', 'path': './', 'lang': 'default'}
    .then (lang) =>
      console.log('articles then')
      @articles = new Articles(path.join(@projectPath, lang.path , 'SUMMARY.md'))
      Q.resolve @articles

  getLangs: ->
    @languages.read()

  getChapters: ->
    @articles.read()

  addChapter: (name, parent) ->
    console.log 'Chapter ' + name + ' added to the book'
    @save()

  deleteChapter: (chapter) ->
    console.log 'chapter ' + chapter + ' deleted'
    @save()

  renameChapter: (newName, chapter) ->
    console.log 'chapter new name: ' + newName
    @save()

  moveChapter: ->
    #todo

  save: ->
    console.log(@articles.toMarkdown())
