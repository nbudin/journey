`import Ember from 'ember'`

PageRoute = Ember.Route.extend
  model: (params) -> @store.find('page', params.page_id)

  setupController: (controller, page) ->
    @_super(controller, page)
    @controllerFor('pages').set('currentPage', page)
    
  renderTemplate: (controller, model) ->
    @_super(controller, model)
    this.render 'page_controls',
      into: 'questionnaire',
      outlet: 'page_controls'
      
`export default PageRoute`