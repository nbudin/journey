`import Ember from 'ember'`

QuestionView = Ember.View.extend
  tagName: 'li'
  classNames: ['question']
  classNameBindings: ['resetsCycle:reset-cycle', 'ignoresCycle:ignore-cycle', 'content.cardinality', 'layoutClass',  "editMode:edit-mode:"]
  templateName: 'question'
  contentBinding: 'controller'
  editMode: false
  
  layoutClass: ( ->
    "layout-#{@get "content.layout"}"
  ).property('content.layout')
  
  click: (event) ->
    # don't bubble clicks inside a question up to the current page; stops link-to from preventing inputs from working
    event.stopPropagation()
  
  actions:
    toggleEditMode: -> 
      @set('editMode', !@get('editMode'))
      if @get('editMode')
        @get('controller').send('setCurrentPage', @get('content.page'))

`export default QuestionView`