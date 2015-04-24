Dialog = require './dialog'

module.exports =
class Prompt extends Dialog
  constructor: (label, callback) ->
    @callback = callback
    super
      prompt: label

  onConfirm: (value) ->
    try
      @callback value
      @close()
    catch error
      console.log(error)
      @showError("#{error.message}.")
