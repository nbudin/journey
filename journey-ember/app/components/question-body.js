import Ember from 'ember';
import _ from 'lodash/lodash';

export default Ember.Component.extend({
  bodyPartialName: function() {
    const demodulizedType = this.get('question.type').replace("Questions::", "");
    const kebabCasedType = _.kebabCase(demodulizedType);

    return this.get('question.type') && ("components/question_body/" + kebabCasedType);
  }.property('question.type'),

  radioLayoutClass: function() {
    return "layout-" + (this.get("question.radioLayout"));
  }.property('question.radioLayout')
});
