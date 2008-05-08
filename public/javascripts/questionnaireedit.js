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
  new Ajax.Updater("question_"+questionId,
                   "/questionnaires/"+questionnaireId+"/pages/"+pageId+"/questions/"+questionId+"/edit",
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
                                     "/questionnaires/"+questionnaireId+"/pages/"+pageId+"/questions/"+q.id+"/edit",
                                     { method: "get", evalScripts: true, insertion: Insertion.Bottom});
                    Sortable.create("questions",
                                    { handle:'draghandle',
                                      onUpdate:function() {
                                        new Ajax.Request('/questionnaires/'+questionnaireId+"/pages/"+pageId+"/questions/sort",
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
      el.disabled = false;
      window.location.reload();
  }.bind(el));
}

function removeOption(questionId, optionId) {
  if (confirm("Do you really want to remove this option?")) {
    QuestionOption.destroy({id: optionId, question_id: questionId}, function() {
        $('option_'+this).remove();
    }.bind(optionId));
  }
}

function deleteQuestion(questionId) {
  Question.destroy({id: questionId}, function() {
    window.location.reload();
  });
}

function duplicateQuestion(questionId, times) {
  new Ajax.Request('/questionnaires/'+questionnaireId+"/pages/"+pageId+"/questions/"+questionId+"/duplicate",
                   { onComplete: function(request) {
                      window.location.reload();
                    },
                    parameters: { 'times': times }
                   });
}

function setSpecialPurpose(questionId, purpose) {
  if (purpose == null) {
    new Ajax.Request('/questionnaires/'+questionnaireId+'/available_special_field_purposes.xml',
                     { 'method': 'get',
                       'onSuccess': function(transport) {
                          body = $('questionbody_'+questionId);
                          
                          realChildren = [];
                          for (i=0; i<body.childNodes.length; i++) {
                            realChildren.push(body.childNodes[i]);
                          }
                          for (i=0; i<realChildren.length; i++) {
                            body.removeChild(realChildren[i]);
                          }
                          
                          iNode = document.createElement('i');
                          iNode.appendChild(document.createTextNode("Special purpose: "));
                          body.appendChild(iNode);
                          
                          purposeSelector = document.createElement('select');
                          purposeSelector.setAttribute('style', 'margin-right: 3em;');
                          purposeSelector.setAttribute('id', 'purpose_selector_'+questionId);
                          
                          availablePurposes = Jester.Tree.parseXML(transport.responseText).available_purposes.purpose;
                          function addPurpose(purpose) {
                            option = document.createElement('option');
                            option.setAttribute('value', purpose);
                            option.appendChild(document.createTextNode(purpose));
                            purposeSelector.appendChild(option);
                          }
                          addPurpose('');
                          if (typeof availablePurposes == "string") {
                            addPurpose(availablePurposes);
                          } else {
                            availablePurposes.each(function(p) {addPurpose(p);});
                          }
                          
                          body.appendChild(purposeSelector);
                             
                          setPurpose = document.createElement('button');
                          setPurpose.appendChild(document.createTextNode("Set"));
                          setPurpose.observe('click', function() {
                            setSpecialPurpose(questionId, this.value);
                          }.bind(purposeSelector));
                          body.appendChild(setPurpose);
                          
                          cancel = document.createElement('button');
                          cancel.appendChild(document.createTextNode("Cancel"));
                          cancel.observe('click', function() {
                            el = $('questionbody_'+questionId);
                            while (el.childNodes.length > 0) {
                              el.removeChild(el.firstChild);
                            }
                            
                            this.each(function(child) {
                              el.appendChild(child);
                            });
                          }.bind(realChildren));
                          body.appendChild(cancel);
                       }
                     });
    
  } else {
    Question.find(questionId, function(q) {
      q.purpose = purpose;
      q.save(function() {
        reloadQuestion(questionId);
      });
    });
  }
}

function toggleDropdown(questionId) {
  dropdownicon = $('dropdown_icon_'+questionId)
  $$('.selected_dropdown_icon').each(function(ddi) {
    if (ddi != dropdownicon)
    ddi.removeClassName('selected_dropdown_icon');
    });
  dropdownicon.toggleClassName('selected_dropdown_icon');
  dropdown = $('question_dropdown_'+questionId);
  $$('ul.dropdown').each(function(dd) {
    if (dd != dropdown)
    dd.hide();
    });
  dropdown.toggle();
}