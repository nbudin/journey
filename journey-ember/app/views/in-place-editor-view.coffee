`import Ember from 'ember'`

InPlaceEditorView = Ember.ContainerView.extend
  childViews: ['displayView', 'editFieldView']
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
    template: Ember.Handlebars.compile """
    {{#if view.parentView.displayRawHtml}}
      {{{view.parentView.value}}}
    {{else}}
      {{view.parentView.value}}
    {{/if}}
    """
    click: (evt) -> @get('parentView').startEditing()
    
  editFieldView: Ember.View.extend
    classNames: ['edit']
    isVisibleBinding: 'parentView.editing'
    disabled: false
    
    template: Ember.Handlebars.compile """
    {{input value=view.parentView.newValue}} 
    <button {{action "saveNewValue" target="view.parentView"}} {{bind-attr disabled="view.disabled"}}>Save</button>
    {{#unless view.disabled}}
      <a href="#" {{action "cancelEditing" target="view.parentView"}}>Cancel</a>
    {{/unless}}
    """
    
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