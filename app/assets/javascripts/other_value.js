var toggleOtherValueVisibility = function(element) {
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
  $$('select[data-question-id]').each(function(selector) {
    selector.on('change', function (event) { toggleOtherValueVisibility(event.target); });
    toggleOtherValueVisibility(selector);
  });
});