/// *** theme-after
const darkModeToggle = document.querySelector('dark-mode-toggle');
const pictures = document.querySelectorAll('picture');
const stylesheets = document.querySelectorAll('link[rel="stylesheet"]');
const imgldLinks = document.querySelectorAll('a.imgldlink');

const toggleTheme = (e) => {
  darkModeToggle.appearance = 'toggle';
  const darkModeOn = e.detail.colorScheme === 'dark' ? true : false;
  pictures.forEach((picture) => {
    const dark = picture.querySelector('source[theme="dark"]');
    const light = picture.querySelector('source[theme="light"]');
    dark.media = darkModeOn ? 'all' : 'none';
    light.media = darkModeOn ? 'none' : 'all';
  });
  imgldLinks.forEach((link) => {
    if (darkModeOn)
      link.href = link.href.replace("-light.", "-dark.");
    else
      link.href = link.href.replace("-dark.", "-light.");
  });
  if (!window.matchMedia('(prefers-color-scheme)').matches) {
    stylesheets.forEach((stylesheet) => {
      if (stylesheet.getAttribute("theme") == "dark")
        stylesheet.media = darkModeOn ? 'all' : 'none';
      if (stylesheet.getAttribute("theme") == "light")
        stylesheet.media = darkModeOn ? 'none' : 'all';
    });
  }
};
document.addEventListener('colorschemechange', toggleTheme);
toggleTheme({detail: {colorScheme: darkModeToggle.mode}});

/// *** Initial setup: tables, quotes, navigation
document.addEventListener("DOMContentLoaded", () => {
  // standard classes
  document.querySelector("table")?.classList?.add("table");
  document.querySelector("table")?.classList?.add("table-bordered");
  document.querySelector("table")?.classList?.add("table-hover");
  document.querySelector("table")?.classList?.add("table-condensed");
  document.querySelector("blockquote")?.classList?.add("blockquote");
});

// *** Anchors ***
anchors.options = {
 placement: 'left',
 icon: '§'
};
anchors.add('h1');
anchors.add('h2');
anchors.add('h3');