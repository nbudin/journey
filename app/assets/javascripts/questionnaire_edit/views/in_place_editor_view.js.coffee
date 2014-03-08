QuestionnaireEdit.InPlaceEditorView = Ember.ContainerView.extend
  childViews: ['displayView', 'editFieldView']
  editing: false
  displaying: ( -> !@get('editing') ).property('editing')
  classNames: ['in-place-editor']
  focusEditField: ( -> 
    @get('editFieldView').$().show().find('input').focus() if @get('editFieldView.isVisible')
  ).observes('editFieldView.isVisible')
    
  displayView: Ember.View.create
    classNames: ['display']
    isVisibleBinding: 'parentView.displaying'
    template: Ember.Handlebars.compile("{{view.parentView.value}}")
    click: (evt) -> @get('parentView').startEditing()
    
  editFieldView: Ember.View.create
    classNames: ['edit']
    isVisibleBinding: 'parentView.editing'
    
    template: Ember.Handlebars.compile """
    {{input value=view.parentView.newValue}} 
    <button {{action "saveNewValue" target="view.parentView"}}>Save</button>
    <a href="#" {{action "cancelEditing" target="view.parentView"}}>Cancel</a>
    """
    
    keyPress: (e) ->
      if e.keyCode == 13
        @get('parentView').send('saveNewValue')
    
  startEditing: ->
    @set('newValue', @get('value'))
    @set('editing', true)
    
  actions:
    saveNewValue: ->
      @set('value', @get('newValue'))
      @get('model').save()
      @set('editing', false)
    
    cancelEditing: ->
      @set('newValue', null)
      @set('editing', false)
    