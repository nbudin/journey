// http://www.alistapart.com/articles/makingcompactformsmoreaccessible

function initOverLabels () {
  if (!document.getElementById) return;      

  var labels, id, field;

  // Set focus and blur handlers to hide and show 
  // labels with 'overlabel' class names.
  labels = document.getElementsByTagName('label');
  for (var i = 0; i < labels.length; i++) {

    if (labels[i].className == 'overlabel') {

      // Skip labels that do not have a named association
      // with another field.
      id = labels[i].htmlFor || labels[i].getAttribute('for');
      if (!id || !(field = document.getElementById(id))) {
        continue;
      } 

      // Change the applied class to hover the label 
      // over the form field.
      labels[i].className = 'overlabel-apply';

      // Hide any fields having an initial value.
      if (field.value !== '') {
        hideLabel(field.getAttribute('id'), true);
      }

      // Set handlers to show and hide labels.
      Event.observe(field, "focus", function () {
        hideLabel(this.getAttribute('id'), true);
      });
      Event.observe(field, "blur", function () {
        if (this.value === '') {
          hideLabel(this.getAttribute('id'), false);
        }
      });

      // Handle clicks to label elements (for Safari).
      Event.observe(labels[i], "click", function () {
        var id, field;
        id = this.getAttribute('for');
        if (id && (field = document.getElementById(id))) {
          field.focus();
        }
      });

    }
  }
};

function hideLabel (field_id, hide) {
  var field_for;
  var labels = document.getElementsByTagName('label');
  for (var i = 0; i < labels.length; i++) {
    field_for = labels[i].htmlFor || labels[i].getAttribute('for');
    if (field_for == field_id) {
      labels[i].style.textIndent = (hide) ? '-1000px' : '0px';
      return true;
    }
  }
}

Event.observe(window, "load", function () {
  setTimeout(initOverLabels, 50);
});
