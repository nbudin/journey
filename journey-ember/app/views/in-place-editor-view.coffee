`import Ember from 'ember'`

InPlaceEditorView = Ember.ContainerView.extend

  setupChildViews: Ember.on 'init', ->
    this.clear()
    this.pushObjects [@createChildView(@get('displayView')), @createChildView(@get('editFieldView'))]
    
  editing: false
  displaying: ( -> !@get('editing') ).property('editing')
  classNames: ['in-place-editor']
  focusEditField: ( -> 
    @get('editFieldView').$().show().find('input').focus() if @get('editFieldView.isVisible')
  ).observes('editFieldView.isVisible')
  displayRawHtml: false
    
  displayView: Ember.View.extend
    classNames: ['display']
    isVisibleBinding: 'parentView.displaying'
    templateName: 'in-place-editor/display'
    click: (evt) -> @get('parentView').startEditing()
    
  editFieldView: Ember.View.extend
    classNames: ['edit']
    isVisibleBinding: 'parentView.editing'
    disabled: false
    templateName: 'in-place-editor/edit'
    
    keyPress: (e) ->
      if e.keyCode == 13
        @get('parentView').send('saveNewValue')
    
  startEditing: ->
    @set('newValue', @get('value'))
    @set('editFieldView.disabled', false)
    @set('editing', true)
    
  actions:
    saveNewValue: ->
      @set('editFieldView.disabled', true)
      oldValue = @get('value')
      @set('value', @get('newValue'))
      @get('model').save().then(
        (=> 
          @set('editFieldView.disabled', false)
          @set('editing', false)
        ),
        ((error) => 
          @set('editFieldView.disabled', false)
          @set('value', oldValue)
          alert error
        )
      )
    
    cancelEditing: ->
      @set('newValue', null)
      @set('editing', false)

`export default InPlaceEditorView`