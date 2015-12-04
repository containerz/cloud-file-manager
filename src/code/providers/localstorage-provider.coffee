tr = require '../utils/translate'

ProviderInterface = (require './provider-interface').ProviderInterface
CloudContent = (require './provider-interface').CloudContent
CloudRelatedContent = (require './provider-interface').CloudRelatedContent
CloudMetadata = (require './provider-interface').CloudMetadata

class LocalStorageProvider extends ProviderInterface

  constructor: (@options = {}) ->
    super
      name: LocalStorageProvider.Name
      displayName: @options.displayName or (tr '~PROVIDER.LOCAL_STORAGE')
      capabilities:
        save: true
        load: true
        list: true
        remove: true
        rename: true

  @Name: 'localStorage'
  @Available: ->
    result = try
      test = 'LocalStorageProvider::auth'
      window.localStorage.setItem(test, test)
      window.localStorage.removeItem(test)
      true
    catch
      false

  save: (content, metadata, callback) ->
    try
      window.localStorage.setItem @_getKey(metadata.name), content.getText()
      callback? null
    catch
      callback? 'Unable to save'

  load: (metadata, callback) ->
    try
      content = window.localStorage.getItem @_getKey metadata.name
      callback null, new CloudContent content
    catch
      callback 'Unable to load'

  list: (metadata, callback) ->
    list = []
    prefix = @_getKey (metadata?.path() or []).join '/'
    for own key of window.localStorage
      if key.substr(0, prefix.length) is prefix
        [name, remainder...] = key.substr(prefix.length).split('/')
        list.push new CloudMetadata
          name: key.substr(prefix.length)
          type: if remainder.length > 0 then CloudMetadata.Folder else CloudMetadata.File
          parent: metadata
          provider: @
    callback null, list

  remove: (metadata, callback) ->
    try
      window.localStorage.removeItem @_getKey(metadata.name)
      callback? null
    catch
      callback? 'Unable to delete'

  rename: (metadata, newName, callback) ->
    try
      content = window.localStorage.getItem @_getKey metadata.name
      window.localStorage.setItem @_getKey(newName), content
      window.localStorage.removeItem @_getKey(metadata.name)
      metadata.name = newName
      callback null, metadata
    catch
      callback? 'Unable to rename'

  _getKey: (name = '') ->
    "cfm::#{name}"

module.exports = LocalStorageProvider
