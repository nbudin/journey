import Ember from 'ember';
import _ from 'lodash/lodash';

export default Ember.Component.extend({
  templateName: function() {
    const demodulizedType = this.get('question.type').replace("Questions::", "");
    const snakeCasedType = _.snakeCase(demodulizedType);

    return this.get('question.type') && ("question_body/" + snakeCasedType);
  }.property('question.type'),

  radioLayoutClass: function() {
    return "layout-" + (this.get("question.radioLayout"));
  }.property('question.radioLayout')
});
