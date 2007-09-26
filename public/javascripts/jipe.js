var Jipe = {};

Jipe.InPlaceEditor = Class.create();
Jipe.InPlaceEditor.defaultHighlightColor = "#FFFF99";
Jipe.InPlaceEditor.prototype = {
  initialize: function(element, model, recordId, field, options) {
    this.model = model;
    this.recordId = recordId;
    this.field = field;
    this.element = $(element);

    this.options = Object.extend({
      paramName: "value",
      okButton: true,
      okText: "ok",
      cancelLink: true,
      cancelText: "cancel",
      savingText: "Saving...",
      clickToEditText: "Click to edit",
      okText: "ok",
      rows: 1,
      onComplete: function(transport, element) {
        new Effect.Highlight(element, {startcolor: this.options.highlightcolor});
      },
      onFailure: function(transport) {
        alert("Error communicating with the server: " + transport.responseText.stripTags());
      },
      callback: function(form) {
        return Form.serialize(form);
      },
      handleLineBreaks: true,
      loadingText: 'Loading...',
      savingClassName: 'inplaceeditor-saving',
      loadingClassName: 'inplaceeditor-loading',
      formClassName: 'inplaceeditor-form',
      highlightcolor: Jipe.InPlaceEditor.defaultHighlightColor,
      highlightendcolor: "#FFFFFF",
      externalControl: null,
      submitOnBlur: false,
      ajaxOptions: {},
      evalScripts: false
    }, options || {});

    if(!this.options.formId && this.element.id) {
      this.options.formId = this.element.id + "-inplaceeditor";
      if ($(this.options.formId)) {
        // there's already a form with that name, don't specify an id
        this.options.formId = null;
      }
    }

    if (this.options.externalControl) {
      this.options.externalControl = $(this.options.externalControl);
    }

    this.originalBackground = Element.getStyle(this.element, 'background-color');
    if (!this.originalBackground) {
      this.originalBackground = "transparent";
    }

    this.element.title = this.options.clickToEditText;

    this.onclickListener = this.enterEditMode.bindAsEventListener(this);
    this.mouseoverListener = this.enterHover.bindAsEventListener(this);
    this.mouseoutListener = this.leaveHover.bindAsEventListener(this);
    Event.observe(this.element, 'click', this.onclickListener);
    Event.observe(this.element, 'mouseover', this.mouseoverListener);
    Event.observe(this.element, 'mouseout', this.mouseoutListener);
    if (this.options.externalControl) {
      Event.observe(this.options.externalControl, 'click', this.onclickListener);
      Event.observe(this.options.externalControl, 'mouseover', this.mouseoverListener);
      Event.observe(this.options.externalControl, 'mouseout', this.mouseoutListener);
    }
  },
  enterEditMode: function(evt) {
    if (this.saving) return;
    if (this.editing) return;
    this.editing = true;
    this.onEnterEditMode();
    if (this.options.externalControl) {
      Element.hide(this.options.externalControl);
    }
    Element.hide(this.element);
    this.createForm();
    this.element.parentNode.insertBefore(this.form, this.element);
    // stop the event to avoid a page refresh in Safari
    if (evt) {
      Event.stop(evt);
    }
    return false;
  },
  createForm: function() {
    this.form = document.createElement("form");
    this.form.id = this.options.formId;
    Element.addClassName(this.form, this.options.formClassName)
    this.form.onsubmit = this.onSubmit.bind(this);

    this.createEditField();

    if (this.options.textarea) {
      var br = document.createElement("br");
      this.form.appendChild(br);
    }

    if (this.options.okButton) {
      okButton = document.createElement("input");
      okButton.type = "submit";
      okButton.value = this.options.okText;
      okButton.className = 'editor_ok_button';
      this.form.appendChild(okButton);
    }

    if (this.options.cancelLink) {
      cancelLink = document.createElement("a");
      cancelLink.href = "#";
      cancelLink.appendChild(document.createTextNode(this.options.cancelText));
      cancelLink.onclick = this.onclickCancel.bind(this);
      cancelLink.className = 'editor_cancel';
      this.form.appendChild(cancelLink);
    }
  },
  hasHTMLLineBreaks: function(string) {
    if (!this.options.handleLineBreaks) return false;
    return string.match(/<br/i) || string.match(/<p>/i);
  },
  convertHTMLLineBreaks: function(string) {
    return string.replace(/<br>/gi, "\n").replace(/<br\/>/gi, "\n").replace(/<\/p>/gi, "\n").replace(/<p>/gi, "");
  },
  createEditField: function() {
    var text;
    text = this.options.loadingText;

    var obj = this;

    if (this.options.rows == 1 && !this.hasHTMLLineBreaks(text)) {
      this.options.textarea = false;
      var textField = document.createElement("input");
      textField.obj = this;
      textField.type = "text";
      textField.name = this.options.paramName;
      textField.value = text;
      textField.style.backgroundColor = this.options.highlightcolor;
      textField.className = 'editor_field';
      var size = this.options.size || this.options.cols || 0;
      if (size != 0) textField.size = size;
      if (this.options.submitOnBlur)
        textField.onblur = this.onSubmit.bind(this);
      this.editField = textField;
    } else {
      this.options.textarea = true;
      var textArea = document.createElement("textarea");
      textArea.obj = this;
      textArea.name = this.options.paramName;
      textArea.value = this.convertHTMLLineBreaks(text);
      textArea.rows = this.options.rows;
      textArea.cols = this.options.cols || 40;
      textArea.className = 'editor_field';
      if (this.options.submitOnBlur)
        textArea.onblur = this.onSubmit.bind(this);
      this.editField = textArea;
    }

    this.loadExternalText();
    this.form.appendChild(this.editField);
  },
  getText: function() {
    return this.element.innerHTML;
  },
  loadExternalText: function() {
    Element.addClassName(this.form, this.options.loadingClassName);
    this.editField.disabled = true;
    this.model.find(this.recordId,
                    this.options.ajaxOptionsOnLoad || this.options.ajaxOptions,
                    this.onLoadedExternalText.bind(this));
  },
  onLoadedExternalText: function(obj) {
    this.record = obj;
    Element.removeClassName(this.form, this.options.loadingClassName);
    this.editField.disabled = false;
    this.editField.value = obj[this.field];
    Field.scrollFreeActivate(this.editField);
  },
  onclickCancel: function() {
    this.onComplete();
    this.leaveEditMode();
    return false;
  },
  onFailure: function(transport) {
    this.options.onFailure(transport);
    if (this.oldInnerHTML) {
      this.element.innerHTML = this.oldInnerHTML;
      this.oldInnerHTML = null;
    }
    return false;
  },
  onSubmit: function() {
    // onLoading resets these so we need to save them away for the Ajax call
    var form = this.form;
    var value = this.editField.value;

    // do this first, sometimes the ajax call returns before we get a chance to switch on Saving...
    // which means this will actually switch on Saving... *after* we've left edit mode causing Saving...
    // to be displayed indefinitely
    this.onLoading();

    this.record[this.field] = value;

    this.record.save(Object.extend({
          //    parameters: this.options.callback(form, value),
          onComplete: this.onComplete.bind(this),
            onFailure: this.onFailure.bind(this)
            }, this.options.ajaxOptionsOnSubmit || this.options.ajaxOptions));

    // stop the event to avoid a page refresh in Safari
    if (arguments.length > 1) {
      Event.stop(arguments[0]);
    }
    return false;
  },
  onLoading: function() {
    this.saving = true;
    this.removeForm();
    this.leaveHover();
    this.showSaving();
  },
  showSaving: function() {
    this.oldInnerHTML = this.element.innerHTML;
    this.element.innerHTML = this.options.savingText;
    Element.addClassName(this.element, this.options.savingClassName);
    this.element.style.backgroundColor = this.originalBackground;
    Element.show(this.element);
  },
  removeForm: function() {
    if(this.form) {
      if (this.form.parentNode) Element.remove(this.form);
      this.form = null;
    }
  },
  enterHover: function() {
    if (this.saving) return;
    this.element.style.backgroundColor = this.options.highlightcolor;
    if (this.effect) {
      this.effect.cancel();
    }
    Element.addClassName(this.element, this.options.hoverClassName)
  },
  leaveHover: function() {
    if (this.options.backgroundColor) {
      this.element.style.backgroundColor = this.oldBackground;
    }
    Element.removeClassName(this.element, this.options.hoverClassName)
    if (this.saving) return;
    this.effect = new Effect.Highlight(this.element, {
      startcolor: this.options.highlightcolor,
      endcolor: this.options.highlightendcolor,
      restorecolor: this.originalBackground
    });
  },
  leaveEditMode: function() {
    Element.removeClassName(this.element, this.options.savingClassName);
    this.removeForm();
    this.leaveHover();
    this.element.style.backgroundColor = this.originalBackground;
    Element.show(this.element);
    if (this.options.externalControl) {
      Element.show(this.options.externalControl);
    }
    this.editing = false;
    this.saving = false;
    this.element.innerHTML = this.record[this.field];
    this.oldInnerHTML = null;
    this.onLeaveEditMode();
  },
  onComplete: function(transport) {
    this.leaveEditMode();
    this.options.onComplete.bind(this)(transport, this.element);
  },
  onEnterEditMode: function() {},
  onLeaveEditMode: function() {},
  dispose: function() {
    if (this.oldInnerHTML) {
      this.element.innerHTML = this.oldInnerHTML;
    }
    this.leaveEditMode();
    Event.stopObserving(this.element, 'click', this.onclickListener);
    Event.stopObserving(this.element, 'mouseover', this.mouseoverListener);
    Event.stopObserving(this.element, 'mouseout', this.mouseoutListener);
    if (this.options.externalControl) {
      Event.stopObserving(this.options.externalControl, 'click', this.onclickListener);
      Event.stopObserving(this.options.externalControl, 'mouseover', this.mouseoverListener);
      Event.stopObserving(this.options.externalControl, 'mouseout', this.mouseoutListener);
    }
  }
};

Jipe.ImageToggle = Class.create();
Jipe.ImageToggle.defaultHighlightColor = "#FFFF99";
Jipe.ImageToggle.prototype = {
  initialize: function(trueElement, falseElement, model, recordId, field, options) {
    this.model = model;
    this.recordId = recordId;
    this.field = field;
    this.trueElement = $(trueElement);
    this.falseElement = $(falseElement);

    this.options = Object.extend({
      onComplete: function(transport, element) {
        new Effect.Highlight(element, {startcolor: this.options.highlightcolor});
      },
      onFailure: function(transport) {
        alert("Error communicating with the server: " + transport.responseText.stripTags());
      },
      savingClassName: 'imagetoggle-saving',
      loadingClassName: 'imagetoggle-loading',
      highlightcolor: Jipe.ImageToggle.defaultHighlightColor,
      highlightendcolor: "#FFFFFF",
      ajaxOptions: {},
      evalScripts: false
    }, options || {});

    this.originalBackground = Element.getStyle(this.trueElement, 'background-color');
    if (!this.originalBackground) {
      this.originalBackground = "transparent";
    }

    this.trueClickListener = this.setFalse.bindAsEventListener(this);
    this.falseClickListener = this.setTrue.bindAsEventListener(this);
    Event.observe(this.trueElement, 'click', this.trueClickListener);
    Event.observe(this.falseElement, 'click', this.falseClickListener);
    
    //this.loadExternalState();
    this.controlEnabled = true;
  },
  loadExternalState: function() {
    this.model.find(this.recordId,
                    this.options.ajaxOptionsOnLoad || this.options.ajaxOptions,
                    this.onLoadedExternalState.bind(this));
  },
  onLoadedExternalState: function(obj) {
    this.record = obj;
    this.updateImage(obj[this.field]); 
  },
  updateImage: function(state) {
    if (state == "1" || state == "true") {
      this.trueElement.show();
      this.falseElement.hide();    
    } else {
      this.falseElement.show();
      this.trueElement.hide();
    }
  },
  onComplete: function(transport) {
    this.controlEnabled = true;
    this.options.onComplete.bind(this)();
  },
  setFalse: function() {
    if (this.controlEnabled) {
      this.setState(false);
    }
  },
  setTrue: function() {
    if (this.controlEnabled) {
      this.setState(true);
    }
  },
  setState: function(state) {
    this.controlEnabled = false;
    this.desiredState = state;
    this.updateImage(this.desiredState);
    this.model.find(this.recordId,
        this.options.ajaxOptionsOnLoad || this.options.ajaxOptions,
        this.setStateInner.bind(this));
  },
  setStateInner: function(record) {
    this.record = record;
    if (this.record[this.field] != this.desiredState) {
      this.record[this.field] = this.desiredState;
      this.record.save(this.onComplete.bind(this));
    } else {
      this.onComplete();
    }
  }
};