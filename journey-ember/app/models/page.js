import DS from 'ember-data';
import Ember from 'ember';
var Page;

Page = DS.Model.extend({
  questionnaire: DS.belongsTo('questionnaire'),
  questions: DS.hasMany('question', {
    async: true
  }),
  title: DS.attr('string'),
  position: DS.attr('number'),
  questionsSorting: ['position'],
  questionsSorted: Ember.computed.sort('questions', 'questionsSorting'),
  number: (function() {
    var pages;
    pages = this.get('questionnaire.pagesSorted');
    return pages && (pages.indexOf(this) + 1);
  }).property('questionnaire.pagesSorted'),
  isFirstPage: Ember.computed.equal('number', 1),
  isLastPage: (function() {
    return this.get('number') === this.get('questionnaire.pages.length');
  }).property('questionnaire.pages.length', 'number')
});

export default Page;
