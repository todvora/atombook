AtombookView = require './atombook-view'
{CompositeDisposable} = require 'atom'
path = require 'path'
fs = require 'fs'
Articles = require './articles'
Book = require './book'

gitbookParsers = require 'gitbook-parsers'

module.exports = GitbookAtom =
  atombookView: null
  panel: null
  subscriptions: null

  activate: (state) ->
    @atombookView = new AtombookView(state.AtombookState)

    @book = new Book(@projectPath())

    @book.init()
    .then (summary) =>
      @panel = atom.workspace.addLeftPanel(
        visible: false
        item: @atombookView.getElement()
      )

      @subscriptions = new CompositeDisposable
      changeHandler = (e) =>
        if e?.buffer?.file?.path
          relPath = path.relative(@projectPath(), e.buffer.file.path)
          @atombookView.highlight(relPath)

      @subscriptions.add atom.workspace.onDidChangeActivePaneItem(changeHandler);

      @subscriptions.add atom.commands.add('atom-workspace', {
        'atombook:toggle': => @toggle()
        'atombook:add-file': => @addFile()
        'atombook:rename-file': => @renameFile()
        'atombook:delete-file': => @deleteFile()
      })

      summary.read()
      .then (chapters) =>
        @updatePanel chapters
        @panel.show()
    .fail (ex) ->
      console.log ex

  updatePanel: (chapters) ->
    @atombookView.setSummary chapters

  deactivate: ->
    @panel.destroy()
    @subscriptions.dispose()
    @atombookView.destroy()

  serialize: ->
    AtombookState: @atombookView.serialize()

  toggle: ->
    if @panel.isVisible()
      @panel.hide()
    else
      @panel.show()

  projectPath: ->
    atom.project.getPaths()[0]

  addFile: ->
    PromptView = require './prompt-view'
    # @atombookView.getSelectedContextMenuItem()
    prompt = new PromptView('Enter a title for the new section', (val) => @book.addChapter(val, ''))
    prompt.attach()

  renameFile: ->
      PromptView = require './prompt-view'
      # @atombookView.getSelectedContextMenuItem()
      prompt = new PromptView('Change title', (val) => @book.renameChapter(val, ''))
      prompt.attach()

  deleteFile: ->
    name = @atombookView.getSelectedContextMenuItem().getAttribute('data-name')
    atom.confirm
      message: "Are you sure you want to delete the selected chapter"
      detailedMessage: 'You are deleting: ' + name
      buttons:
        "Move to Trash": =>
          @book.deleteChapter(name)
        "Cancel": null
