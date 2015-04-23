module.exports =
class AtombookView

  selectedContextMenuItem = null

  constructor: (serializedState) ->
    @element = document.createElement('div')
    @element.classList.add('atombook')

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getSelectedContextMenuItem: ->
    @selectedContextMenuItem

  getElement: ->
    @element

  setSummary: (summary) ->

    @element.removeChild(@element.firstChild) while @element.firstChild

    rootElement = document.createElement('ul')
    @element.appendChild(rootElement)

    renderItem = (chapter) ->
      label = chapter.level + '. ' + chapter.title
      link = document.createElement('a')
      link.setAttribute('data-path', chapter.path)
      link.setAttribute('data-level', chapter.level)
      link.setAttribute('data-name', chapter.title)
      link.setAttribute('title', chapter.path)

      link.appendChild(document.createTextNode(label))
      return link

    render = (chapter, parent) ->
      elem = document.createElement('li')
      parent.appendChild(elem)
      elem.appendChild(renderItem(chapter))
      if chapter.articles.length > 0
        children = document.createElement('ul')
        chapter.articles.forEach (chapter) ->
          render chapter, children
        parent.appendChild(children)

    summary.chapters.forEach (chapter) ->
      render chapter, rootElement

    links = @element.getElementsByTagName('a')

    addClickHandler = (elem) ->
      path = elem.getAttribute 'data-path'
      if(path)
        elem.addEventListener 'click', =>
          atom.workspace.open(path)

    addContextMenuHandler = (elem) =>
      path = elem.getAttribute 'data-path'
      if(path)
        elem.addEventListener 'contextmenu', =>
          @selectedContextMenuItem = elem
          console.log(path)

    addClickHandler link for link in links
    addContextMenuHandler link for link in links

  highlight: (path) ->
    setCssClass = (link, path) =>
      attr = link.getAttribute 'data-path'
      if attr == path
        link.classList.add('selected')
      else
        link.classList.remove('selected')

    links = @element.getElementsByTagName('a')
    setCssClass(link, path) for link in links
