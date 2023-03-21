setupQuestionnaireEditing = function (questionnaireId, pageId, sitePrefix) {
  if (!sitePrefix) {
    sitePrefix = "";
  }
  this.questionnaireId = questionnaireId;
  this.pageId = pageId;
  this.sitePrefix = sitePrefix;
  Resource.model("Page", {
    prefix: sitePrefix + "/questionnaires/" + questionnaireId,
    format: "json",
  });
  Resource.model("Question", {
    prefix:
      sitePrefix + "/questionnaires/" + questionnaireId + "/pages/" + pageId,
    format: "json",
  });
  Resource.model("QuestionOption", {
    prefix:
      sitePrefix +
      "/questionnaires/" +
      questionnaireId +
      "/pages/" +
      pageId +
      "/questions/:question_id/",
    format: "json",
  });
}.bind(this);

var defaultLayout = null;

function zebrifyQuestions() {
  var i = 1;
  $$("li.question").each(function (question) {
    if (!question.hasClassName("ignore-cycle")) {
      if (question.hasClassName("reset-cycle")) {
        i = -1;
      } else {
        if (i % 2 == 0) {
          question.addClassName("even");
          question.removeClassName("odd");
        } else {
          question.addClassName("odd");
          question.removeClassName("even");
        }
        i++;
      }
    }
  });
}

function updateDefault(questionId, newDefault) {
  el = $("question_" + questionId + "_default_answer");
  el.value = "Saving...";
  el.disabled = true;
  el.newDefault = newDefault;
  Question.find(
    questionId,
    {},
    function (q) {
      q.default_answer = el.newDefault;
      q.save(
        function () {
          if (this.type == "checkbox") {
            this.checked = this.newDefault;
          } else {
            this.value = this.newDefault;
          }
          this.disabled = false;
          new Effect.Highlight(this);
        }.bind(this)
      );
    }.bind(el)
  );
}

function updateDefaultForRadioGroup(questionId, newDefault) {
  if (newDefault == null || newDefault == "") {
    buttons = $$(
      'input[type=radio][name="question[' + questionId + '][default_answer]"]'
    );
    for (i = 0; i < buttons.length; i++) {
      if (buttons[i].checked) {
        buttons[i].checked = false;
        button = buttons[i];
        break;
      }
    }
  } else {
    button = $$(
      'input[type=radio][name="question[' +
        questionId +
        '][default_answer]"][value="' +
        newDefault +
        '"]'
    )[0];
    button.checked = true;
  }
  button.newDefault = newDefault;

  Question.find(
    questionId,
    {},
    function (q) {
      q.default_answer = this.newDefault;
      q.save(
        function () {
          new Effect.Highlight(this);
        }.bind(this)
      );
    }.bind(button)
  );
}

function reloadQuestion(questionId) {
  new Ajax.Updater(
    "question_" + questionId,
    sitePrefix +
      "/questionnaires/" +
      questionnaireId +
      "/pages/" +
      pageId +
      "/questions/" +
      questionId +
      "/edit",
    { method: "get", evalScripts: true }
  );
}

function makeReloadFunction(questionId) {
  return function () {
    reloadQuestion(questionId);
  };
}

function questionAdded(q) {
  newli = document.createElement("li");
  newli.setAttribute("id", "question_" + q.id);
  newli.setAttribute("class", "question");
  newli.setAttribute("position", "relative");
  $("questions").appendChild(newli);
  new Ajax.Updater(
    "question_" + q.id,
    sitePrefix +
      "/questionnaires/" +
      questionnaireId +
      "/pages/" +
      pageId +
      "/questions/" +
      q.id +
      "/edit",
    {
      method: "get",
      evalScripts: true,
      insertion: Insertion.Bottom,
      onComplete: zebrifyQuestions,
    }
  );
  Sortable.create("questions", {
    handle: "draghandle",
    onUpdate: function () {
      new Ajax.Request(
        sitePrefix +
          "/questionnaires/" +
          questionnaireId +
          "/pages/" +
          pageId +
          "/questions/sort",
        {
          asynchronous: true,
          evalScripts: true,
          onComplete: zebrifyQuestions,
          parameters: Sortable.serialize("questions"),
        }
      );
    },
  });
}

function addQuestion(typ, purpose) {
  attrs = { type: typ };
  if (purpose) {
    attrs.purpose = purpose;
    attrs.caption = purpose.capitalize();
  }
  if (defaultLayout == "left" || defaultLayout == "top") {
    attrs.layout = defaultLayout;
  }
  q = Question.create(attrs, questionAdded);
}

function setDefaultLayout(layout) {
  if (defaultLayout != layout) {
    defaultLayout = layout;
    if (layout == "left") {
      $("top_layout").removeClassName("selected");
      $("left_layout").addClassName("selected");
    } else if (layout == "top") {
      $("left_layout").removeClassName("selected");
      $("top_layout").addClassName("selected");
    }
  }
}

function addOption(questionId, newOption) {
  el = $("question_" + questionId + "_add_option");
  el.value = "Saving...";
  el.disabled = true;
  el.newOption = newOption;
  el.questionId = questionId;
  QuestionOption.create(
    { question_id: questionId, option: newOption },
    function () {
      el.value = "";
      el.disabled = false;
      window.location.reload();
    }.bind(el)
  );
}

function removeOption(questionId, optionId) {
  if (confirm("Do you really want to remove this option?")) {
    QuestionOption.destroy(
      { id: optionId, question_id: questionId },
      function () {
        $("option_" + this).remove();
      }.bind(optionId)
    );
  }
}

function deleteQuestion(questionId) {
  Question.destroy({ id: questionId }, function () {
    $("question_" + questionId).remove();
    zebrifyQuestions();
  });
}

function duplicateQuestion(questionId, times) {
  new Ajax.Request(
    sitePrefix +
      "/questionnaires/" +
      questionnaireId +
      "/pages/" +
      pageId +
      "/questions/" +
      questionId +
      "/duplicate",
    {
      onComplete: function (request) {
        window.location.reload();
      },
      parameters: { times: times },
    }
  );
}

function setSpecialPurpose(questionId, purpose) {
  if (purpose == null) {
    new Ajax.Request(
      sitePrefix +
        "/questionnaires/" +
        questionnaireId +
        "/available_special_field_purposes.json",
      {
        method: "get",
        onSuccess: function (transport) {
          var availablePurposes = transport.responseText.evalJSON();
          if (availablePurposes.length == 0) {
            alert(
              "All special-purpose fields are already in use in this survey."
            );
            return;
          }

          body = $("questionbody_" + questionId);

          realChildren = [];
          for (i = 0; i < body.childNodes.length; i++) {
            realChildren.push(body.childNodes[i]);
          }
          for (i = 0; i < realChildren.length; i++) {
            body.removeChild(realChildren[i]);
          }

          iNode = document.createElement("i");
          iNode.appendChild(document.createTextNode("Special purpose: "));
          body.appendChild(iNode);

          purposeSelector = document.createElement("select");
          purposeSelector.setAttribute("style", "margin-right: 3em;");
          purposeSelector.setAttribute("id", "purpose_selector_" + questionId);

          function addPurpose(purpose) {
            option = document.createElement("option");
            option.setAttribute("value", purpose);
            option.appendChild(document.createTextNode(purpose));
            purposeSelector.appendChild(option);
          }
          addPurpose("");
          availablePurposes.each(function (p) {
            addPurpose(p);
          });

          body.appendChild(purposeSelector);

          setPurpose = document.createElement("button");
          setPurpose.appendChild(document.createTextNode("Set"));
          setPurpose.observe(
            "click",
            function () {
              setSpecialPurpose(questionId, this.value);
            }.bind(purposeSelector)
          );
          body.appendChild(setPurpose);

          cancel = document.createElement("button");
          cancel.appendChild(document.createTextNode("Cancel"));
          cancel.observe(
            "click",
            function () {
              el = $("questionbody_" + questionId);
              while (el.childNodes.length > 0) {
                el.removeChild(el.firstChild);
              }

              this.each(function (child) {
                el.appendChild(child);
              });
            }.bind(realChildren)
          );
          body.appendChild(cancel);
        },
      }
    );
  } else {
    Question.find(questionId, function (q) {
      q.purpose = purpose;
      q.save(function () {
        reloadQuestion(questionId);
      });
    });
  }
}

function setLayout(questionId, layout) {
  if (layout == null) {
    alert("Multiple layout selection not yet implemented.");
  } else {
    Question.find(questionId, function (q) {
      q.layout = layout;
      q.save(function () {
        reloadQuestion(questionId);
      });
    });
  }
}

function setRadioLayout(questionId, layout) {
  if (layout == null) {
    alert("Multiple layout selection not yet implemented.");
  } else {
    Question.find(questionId, function (q) {
      q.radio_layout = layout;
      q.save(function () {
        reloadQuestion(questionId);
      });
    });
  }
}

function toggleDropdown(questionId) {
  //dropdownicon = $('dropdown_icon_'+questionId)
  /*$$('.selected_dropdown_icon').each(function(ddi) {
    if (ddi != dropdownicon)
    ddi.removeClassName('selected_dropdown_icon');
    });*/
  //dropdownicon.toggleClassName('selected_dropdown_icon');
  dropdown = $("question_dropdown_" + questionId);
  $$("ul.dropdown").each(function (dd) {
    if (dd != dropdown) dd.hide();
  });
  dropdown.toggle();
}

function editQuestionOptions(questionId, iframeSrc) {
  $("selectorbody_" + questionId).hide();
  $("selectoredit_" + questionId).show();
  $("selectoredit_iframe_" + questionId).hide();
  $("selectoredit_iframe_" + questionId).src = iframeSrc;
}

function closeQuestionOptionsEditor(questionId) {
  $("selectoredit_iframe_" + questionId).hide();
  $("selectorbody_" + questionId).show();
  $("selectoredit_" + questionId).hide();
  reloadQuestion(questionId);
}
