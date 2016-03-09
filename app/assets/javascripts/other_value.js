var toggleOtherValueVisibilityForRadio = function(element) {
  var otherOptions = element.up('ul').select('input[type=radio]').filter(function (childElement) {
    return childElement.readAttribute("data-is-other");
  });

  if (otherOptions.length > 0) {
    var otherValues = otherOptions.map(function (otherOption) { return otherOption.readAttribute("value") });
    var selectedRadios = $$('input:checked[type=radio][name='+element.readAttribute('name')+']');
    var selectValue;
    if (selectedRadios.length > 0) {
      selectValue = selectedRadios[0].value;
    }
    var otherSelected = (otherValues.indexOf(selectValue) != -1);

    var questionId = element.readAttribute('data-question-id');
    var textField = $$('input[data-other-response-for-question-id=' + questionId + ']')[0];

    if (otherSelected) {
      textField.show();
    } else {
      textField.hide();
    }
  }
};


var toggleOtherValueVisibilityForSelect = function(element) {
  var otherOptions = element.childElements().filter(function (childElement) {
    return childElement.readAttribute("data-is-other");
  });

  if (otherOptions.length > 0) {
    var otherValues = otherOptions.map(function (otherOption) { return otherOption.readAttribute("value") });
    var selectValue = $F(element);
    var otherSelected = (otherValues.indexOf(selectValue) != -1);

    var questionId = element.readAttribute('data-question-id');
    var textField = $$('input[data-other-response-for-question-id=' + questionId + ']')[0];

    if (otherSelected) {
      textField.show();
    } else {
      textField.hide();
    }
  }
};

document.observe('dom:loaded', function() {
  $$('select[data-question-id]').each(function(select) {
    select.on('change', function (event) { toggleOtherValueVisibilityForSelect(event.target); });
    toggleOtherValueVisibilityForSelect(select);
  });

  $$('input[type=radio][data-question-id]').each(function(radio) {
    radio.on('change', function (event) { toggleOtherValueVisibilityForRadio(event.target); });
    toggleOtherValueVisibilityForRadio(radio);
  });
});