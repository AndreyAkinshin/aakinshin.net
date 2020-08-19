/// *** Initial setup: tables, quotes, navigation
$(function() {
   // standard classes
   $("table").addClass("table");
   $("table").addClass("table-bordered");
   $("table").addClass("table-hover");
   $("table").addClass("table-condensed");
   $("blockquote").addClass("blockquote");
});

// *** Anchors ***
anchors.options = {
  placement: 'left',
  icon: '§'
};
anchors.add('h1');
anchors.add('h2');
anchors.add('h3');