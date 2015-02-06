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

function findPos(obj) {
  offset = obj.cumulativeOffset();
  return [offset.left, offset.top];
}

function getViewportSize() {
  // Andy Langton's cross-browser viewport size finder
  
  if (typeof window.innerWidth != 'undefined') {
    return [window.innerWidth, window.innerHeight];
  }
  
  if (typeof document.documentElement != 'undefined' && 
    typeof document.documentElement.clientWidth != 'undefined' && 
  document.documentElement.clientWidth != 0) {
  return [document.documentElement.clientWidth, document.documentElement.clientHeight];
  }
  
  body = document.getElementsByTagName('body')[0];
  return [body.clientWidht, body.clientHeight];
}

var lastViewportSize = [0, 0];
function viewportSizeChanged() {
  vpSize = getViewportSize();
  if (vpSize[0] == lastViewportSize[0] && vpSize[1] == lastViewportSize[1]) {
    return false;
  }
  lastViewportSize = vpSize;
  return true;
}

function toggleEditor(id, showEditor) {
  var editor = tinyMCE.get(id);
  if (showEditor) {
    editor.show();
    $(id + '_html').removeClassName('selected');
    $(id + '_visual').addClassName('selected');
  } else {
    editor.hide();
    $(id + '_visual').removeClassName('selected');
    $(id + '_html').addClassName('selected');
  }
}