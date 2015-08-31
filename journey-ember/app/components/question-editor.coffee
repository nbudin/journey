`import Ember from 'ember'`

QuestionEditorComponent = Ember.Component.extend
  tagName: 'li'
  classNames: ['question']
  classNameBindings: [
    'resetsCycle:reset-cycle', 
    'ignoresCycle:ignore-cycle', 
    'content.cardinality', 
    'layoutClass',  
    'editMode:edit-mode:'
  ]
  editMode: false
  
  layoutClass: ( ->
    "layout-#{@get "question.layout"}"
  ).property('question.layout')
  
  click: (event) ->
    # don't bubble clicks inside a question up to the current page; stops link-to from preventing inputs from working
    event.stopPropagation()
  
  actions:
    save: ->
      @get('question').save().then(
        ( => @set('editMode', false)),
        ( (error) => alert("Saving failed with error: #{error}") )
      )
    
    toggleEditMode: -> 
      if @get('editMode') && @get('question.isDirty')
        return unless confirm("There are unsaved changes.  Are you sure you want to lose them?")
        @get('question').rollback()
        
      @set('editMode', !@get('editMode'))
      if @get('editMode')
        @sendAction('enteredEditMode', @get('question'))

`export default QuestionEditorComponent`
