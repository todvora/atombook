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
      @articles = new Articles(@projectPath, lang.path , 'SUMMARY.md')
      Q.resolve @articles

  getLangs: ->
    @languages.read()

  getChapters: ->
    @articles.read()

  addChapter: (name, parent) ->
    newFilePath = @articles.add(name, parent)
    console.log 'Chapter ' + name + ' added to the book'
    @save()
    Q.resolve newFilePath

  deleteChapter: (chapter) ->
    @articles.delete(chapter);
    @save()
    # close the opened editor windows?

  renameChapter: (newName, chapter) ->

    console.log 'chapter new name: ' + newName
    @save()

  moveChapter: ->
    #todo

  save: ->
    @articles.save()
