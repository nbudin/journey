`import Ember from 'ember'`

PageEditorComponent = Ember.Component.extend
  classNames: ['pageview']
  
  scrollIntoView: Ember.on 'didInsertElement', ->
    if @get('isCurrent')
      Ember.run.schedule 'afterRender', @get('controller'), @get('controller').scrollIntoView

`export default PageEditorComponent`
