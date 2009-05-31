selectedTabName = "";
onTabSelected = [];

function observeTabSelected(f) {
  onTabSelected.push(f);
}

function selectTab(name) {
  $$('.tabpage').each(function(page) { page.hide(); });
  $$('ul.tabstrip li').each(function(tab) { tab.removeClassName('selected')});
  if (selectedTabName != name || $$('ul.tabstrip')[0].hasClassName('alwaysopen')) {
    $(name).show();
    $(name+'_tab').addClassName('selected');
    selectedTabName = name;
  } else {
    selectedTabName = "";
  }
  onTabSelected.each(function (f) {
    f(selectedTabName);
  });
}

function getInnerHeight() {
  var y;
  if (window.innerHeight) // all except Explorer
  {
    y = window.innerHeight;
  }
  else if (document.documentElement && document.documentElement.clientHeight)
    // Explorer 6 Strict Mode
  {
    y = document.documentElement.clientHeight;
  }
  else if (document.body) // other Explorers
  {
    y = document.body.clientHeight;
  }
  
  return y;
}

function toggleEditor(id, editor) {
  if (!tinyMCE.get(id) && editor) {
    tinyMCE.execCommand('mceAddControl', false, id);
    $(id + '_html').removeClassName('selected');
    $(id + '_visual').addClassName('selected');
  } else if (tinyMCE.get(id) && !editor) {
    tinyMCE.execCommand('mceRemoveControl', false, id);
    $(id + '_visual').removeClassName('selected');
    $(id + '_html').addClassName('selected');
  }
}