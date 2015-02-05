`import Ember from 'ember'`

IndexRoute = Ember.Route.extend
  redirect: -> this.transitionTo('pages')

`export default IndexRoute`
