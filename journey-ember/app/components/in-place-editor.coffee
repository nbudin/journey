`import Ember from 'ember'`

InPlaceEditorComponent = Ember.Component.extend
  editing: false
  classNames: ['in-place-editor']
  displayRawHtml: false
  
  keyPress: (e) ->
    if e.keyCode == 13 && @get('editing')
      @send('saveNewValue')
    
  actions:
    startEditing: ->
      @set('newValue', @get('value'))
      @set('disabled', false)
      @set('editing', true)
      $().find('input').focus()
      
    saveNewValue: ->
      @set('disabled', true)
      oldValue = @get('value')
      @set('value', @get('newValue'))
      @get('model').save().then(
        (=> 
          @set('disabled', false)
          @set('editing', false)
        ),
        ((error) => 
          @set('disabled', false)
          @set('value', oldValue)
          alert error
        )
      )
    
    cancelEditing: ->
      @set('newValue', null)
      @set('editing', false)

`export default InPlaceEditorComponent`
