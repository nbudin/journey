import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function () {
  this.route('admin', function() {
    this.route('questionnaire', { path: 'questionnaires/:questionnaire_id/edit' }, function () {
      this.route('pages', function () {
        this.route('page', { path: ':page_id' });
      });
    });
  });
});

export default Router;
