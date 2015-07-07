function storePanelStatus() {
  var openListStr = $(".panel-body.in").map(function() { return this.id;}).get().join(",");
  if (typeof localStorage !== "undefined") {
    localStorage.setItem("monit-panel", openListStr)
  } else {
    $.cookie("monit-panel", openListStr);
  }
}

function loadPanelStatus() {
  var openListStr, openList;
  if (typeof localStorage !== "undefined") {
    openListStr = localStorage.getItem("monit-panel")
  } else {
    openListStr = $.cookie("monit-panel");
  }
  if (openListStr !== null) {
    openList = openListStr.split(",");
    for (var i=0; i<openList.length; i++) {
      var n = $("#"+openList[i]);
      if (n.length>0) {
        n.addClass("in");
        collapseIcon(n[0]);
      }
    }
  }
}

function collapseIcon(n) {
  var node = $(document.getElementById("glyphicon-"+n.id));
  node.toggleClass("glyphicon-plus").toggleClass('glyphicon-minus');
  var titleNode = node.parent().parent();
  if (node.hasClass('glyphicon-minus')) {
    titleNode.removeClass("collapsed-panel");
  } else {
    titleNode.addClass("collapsed-panel");
  }
  return node;
}

$('.collapse').each(function(pos, n) {
  $(n).on('shown.bs.collapse', function(n) {
    return function(e) {
      collapseIcon(n);
      storePanelStatus();
      return false;
    }
  }(n));
  $(n).on('hidden.bs.collapse', function(n) {
    return function(e) {
      collapseIcon(n);
      storePanelStatus();
      return false;
    }
  }(n));
});

$("dl > *").each(function(pos, n) {
  $(n).attr("title", $(n).text());
});


  loadPanelStatus();
  setTimeout(function () { location.reload(true); }, 20000);

