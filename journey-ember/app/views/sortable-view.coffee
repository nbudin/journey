`import Ember from 'ember'`

SortableView = Ember.CollectionView.extend
  tagName: "ul"
  
  moveItem: (fromIndex, toIndex) ->
    items = Ember.A @get('content').toArray()
    itemToMove = items.objectAt(fromIndex)
    items.removeAt(fromIndex)
    items.insertAt(toIndex, itemToMove)
    
    items.forEach (item, index) ->
      item.set('position', index + 1)
      item.save()

  didInsertElement: ->
    @$().sortable
      cursor: "move"
      handle: @get('handle')
      start: (event, ui) -> ui.item.previousIndex = ui.item.index()
      stop: (event, ui) => @moveItem(ui.item.previousIndex, ui.item.index())

  willDestroyElement: -> @$().sortable('destroy')

`export default SortableView`