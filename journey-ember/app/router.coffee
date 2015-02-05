`import Ember from 'ember';`
`import config from './config/environment';`

Router = Ember.Router.extend
  location: config.locationType

Router.map ()->
  @resource 'questionnaire', path: 'questionnaires/:questionnaire_id/edit', ->
    @resource 'pages', ->
      @resource 'page', path: ':page_id'

`export default Router;`
