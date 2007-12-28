setupQuestionnaireEditing = function(questionnaireId, pageId) {
  this.questionnaireId = questionnaireId;
  this.pageId = pageId;
  Resource.model("Page", {prefix: '/questionnaires/'+questionnaireId, format: 'json'});
  Resource.model("Question", {prefix: '/questionnaires/'+questionnaireId+'/pages/'+pageId, format: 'json'});
  Resource.model("QuestionOption", {prefix: '/questionnaires/'+questionnaireId+'/pages/'+pageId+'/questions/:question_id/', format: 'json'});
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

function updateDefaultForRadioGroup(questionId, newDefault) {
  if (newDefault == null || newDefault == "") {
    buttons = $$("input[type=radio][name=\"question["+questionId+"][default_answer]\"]");
    for (i=0; i<buttons.length; i++) {
      if (buttons[i].checked) {
        buttons[i].checked = false;
        button = buttons[i];
        break;
      }
    }
  } else {
    button = $("question_"+questionId+"_default_answer_"+newDefault.toLowerCase().gsub(/[^a-z]/, ''));
    button.checked = true;
  }
  button.newDefault = newDefault;
  
  Question.find(questionId, {}, function(q) {
    q.default_answer = this.newDefault;
    q.save(function() {
      new Effect.Highlight(this);
    }.bind(this));
  }.bind(button));
}

function reloadQuestion(questionId) {
  new Ajax.Updater("question"+questionId,
                   "/questionnaires/"+questionnaireId+"/pages/"+pageId+"/questions/"+questionId+";edit",
                   { method: "get", evalScripts: true });
}

function makeReloadFunction(questionId) {
  return function() {reloadQuestion(questionId)};
}

function addQuestion(typ) {
  Question.create({ 'type': typ },
                  function (q) {
                    newli = document.createElement('li');
                    newli.setAttribute('id', 'question_'+q.id);
                    newli.setAttribute('class', 'question');
                    newli.setAttribute('position', 'relative');
                    $('questions').appendChild(newli);
                    new Ajax.Updater("question_"+q.id,
                                     "/questionnaires/"+questionnaireId+"/pages/"+pageId+"/questions/"+q.id+";edit",
                                     { method: "get", evalScripts: true, insertion: Insertion.Bottom});
                    Sortable.create("questions",
                                    { handle:'draghandle',
                                      onUpdate:function() {
                                        new Ajax.Request('/questionnaires/'+questionnaireId+"/pages/"+pageId+"/questions;sort",
                                                         { asynchronous:true,
                                                            evalScripts:true,
                                                            onComplete: function(request){
                                                              window.location.reload();
                                                            },
                                                            parameters: Sortable.serialize("questions")
                                                          }
                                                        )
                                        }
                                    });
                  });
}

function addOption(questionId, newOption) {
  el = $("question_"+questionId+"_add_option");
  el.value = "Saving...";
  el.disabled = true;
  el.newOption = newOption;
  el.questionId = questionId;
  QuestionOption.create({question_id: questionId, 'option': newOption}, function() {
    el.value = "";
    el.hide();
    reloadQuestion(this.questionId);
  }.bind(el));
}

function removeOption(questionId, optionId) {
  if (confirm("Do you really want to remove this option?")) {
    QuestionOption.destroy({id: optionId, question_id: questionId}, function() {
      reloadQuestion(this);
    }.bind(questionId));
  }
}

function deleteQuestion(questionId) {
  Question.destroy({id: questionId}, function() {
    window.location.reload();
  });
}