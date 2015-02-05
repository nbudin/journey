`import Ember from 'ember'`

PageView = Ember.View.extend
  classNames: ['pageview']
  templateName: 'page'
  
  didInsertElement: ->
    if @get('controller.isCurrent')
      Ember.run.schedule 'afterRender', @get('controller'), @get('controller').scrollIntoView

`export default PageView`