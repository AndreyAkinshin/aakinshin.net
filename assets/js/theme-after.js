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