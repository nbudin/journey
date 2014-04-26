QuestionnaireEdit.PageView = Ember.View.extend
  classNames: ['pageview']
  templateName: 'page'

  didInsertElement: ->
    @$('#toolbox-tabs').tabs()
    @$().scroll (e) => Ember.run.throttle(this, 'scroll', e, 50)
  
  scroll: (e) ->
    @$('#toolbox').css bottom: @$().scrollTop() * -1
    
  actions:
    toggleToolbox: -> @set('toolboxHidden', !@get('toolboxHidden'))