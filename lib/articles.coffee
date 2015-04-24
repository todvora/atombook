path = require 'path'
fs = require 'fs'
gitbookParsers = require 'gitbook-parsers'
Q = require 'q'
_ = require 'lodash'
normalizer = require 'normall'

module.exports =
class Articles

  constructor: (@projectPath, @langPath, @fileName) ->

  getSummaryPath: ->
    path.join @projectPath, @langPath, @fileName

  exists: ->
    deferred = Q.defer()
    fs.exists @getSummaryPath(), (exists) =>
      if exists
        deferred.resolve @getSummaryPath()
      else
        deferred.reject new Error('File ' + @getSummaryPath() + ' not found in the local system.')
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

  find: (level) ->
    findInArray = (array, level) ->
      idx = _.findIndex(array, (item) -> item.level == level)
      if idx != -1
        {'array': array, 'index': idx}
      else
        null

    deepFind  = (array, level) ->
      res = findInArray(array, level)
      if res
        return res
      else
        mapped = array.map (val)->
          if val.articles.length
            deepFind(val.articles, level)
          else
            null
        filtered = mapped.filter( (val) -> val != null)
        if filtered.length
          return filtered[0]
        else
          return null

    deepFind(@summary.chapters, level)

  add: (chapterName, parent) ->

    chapterPath = null
    targetArray = null

    console.log parent
    if parent # subchapter
      found = @find(parent.level)
      parentDir = path.dirname(found.array[found.index].path)
      chapterPath = path.join(@projectPath, @langPath, parentDir, normalizer.filename(chapterName) + '.md')
      targetArray = found.array[found.index].articles

    else # new main chapter
      chapterPath = path.join(@projectPath, @langPath, normalizer.filename(chapterName), 'README.md')
      targetArray = @summary.chapters
      fs.mkdirSync(path.join(@projectPath, @langPath, normalizer.filename(chapterName)))

    relativePath = path.relative(path.join(@projectPath, @langPath), chapterPath)
    targetArray.push({'title':chapterName, 'path': relativePath})
    fs.writeFileSync(chapterPath, '# ' + chapterName + '\n\n', {encoding: 'utf8'})
    return chapterPath

  delete: (chapter)->

    found = @find(chapter.level)
    if found
      toDelete = found.array[found.index]
      if toDelete.articles.length
        toDelete.articles.forEach (article) =>
          @delete(article)
      else
        fs.unlinkSync( path.join(@projectPath, @langPath, toDelete.path))

      found.array.splice(found.index, 1)[0]

    else
      throw Error('Chapter not found: ' + JSON.stringify(chapter))


  save: ->
    fs.writeFileSync(@getSummaryPath(), @toMarkdown(), {encoding: 'utf8'})
    @read()

  # do I need to write the content back? Should I read only?
  toMarkdown: ->
    result = '# Summary \n\n'

    serializeArticle = (article, depth) ->
        Array(4*depth).join(' ') + '* ['+article.title+']('+article.path+')'

    serializeList = (articles, depth) ->
      result = ''
      articles.forEach (article) ->
        result += serializeArticle(article, depth) + '\n'
        if article.articles && article.articles.length
          result = result + serializeList(article.articles, depth + 1)
      result

    result = result + serializeList(@summary.chapters, 0)
