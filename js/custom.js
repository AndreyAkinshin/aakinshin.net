/// *** Initial setup: tables, quotes, navigation
$(function() {
   // standard classes
   $("table").addClass("table");
   $("table").addClass("table-bordered");
   $("table").addClass("table-hover");
   $("table").addClass("table-condensed");
   $("blockquote").addClass("blockquote");

   // nav
   var url = $(location).attr('href');
   if (url.indexOf("/blog/content") != -1) {
       $("#nav-link-blog-content").addClass("active");
   } else if (url.indexOf("/blog/featured") != -1) {
       $("#nav-link-blog-featured").addClass("active");
   } else if (url.indexOf("/blog") != -1) {
       $("#nav-link-blog").addClass("active");
   } else if (url.indexOf("/about") != -1) {
       $("#nav-link-about").addClass("active");
   }
});

// *** Highlight.js ***
hljs.initHighlightingOnLoad();

// *** Anchors ***
anchors.options = {
  placement: 'left',
  icon: '§'
};
anchors.add('h1');
anchors.add('h2');
anchors.add('h3');