import Ember from 'ember';
import Resolver from 'ember/resolver';
import loadInitializers from 'ember/load-initializers';
import config from './config/environment';

Ember.MODEL_FACTORY_INJECTIONS = true;

var QuestionnaireEdit = Ember.Application.extend({
  modulePrefix: config.modulePrefix,
  podModulePrefix: config.podModulePrefix,
  Resolver: Resolver,
  rootElement: "#questionnaire_edit"
});

loadInitializers(QuestionnaireEdit, config.modulePrefix);

export default QuestionnaireEdit;
