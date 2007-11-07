setupQuestionnaireEditing = function(questionnaireId, pageId) {
  this.questionnaireId = questionnaireId;
  this.pageId = pageId;
  Base.model("Page", {prefix: '/questionnaires/'+questionnaireId, format: 'json'});
  Base.model("Question", {prefix: '/questionnaires/'+questionnaireId+'/pages/'+pageId, format: 'json'});
}.bind(this);
                    
function updateDefault(questionId, newDefault) {
  el = $("question_" + questionId + "_default_answer");
  el.value = "Saving...";
  el.disabled = true;
  el.newDefault = newDefault;
  Question.find(questionId, {}, function(q) {
    q.default_answer = el.newDefault;
    q.save(function() {
      if (this.type == 'checkbox') {
        this.checked = this.newDefault;
      } else {
        this.value = this.newDefault;
      }
      this.disabled = false;
      new Effect.Highlight(this);
    }.bind(this));
  }.bind(el));
}

function reloadQuestion(questionId) {
  new Ajax.Updater("question"+questionId,
                   "/questionnaires/"+questionnaireId+"/pages/"+pageId+"/questions/"+questionId+";edit",
                   { method: "get", evalScripts: true });
}

function makeReloadFunction(questionId) {
  return function() {reloadQuestion(questionId)};
}