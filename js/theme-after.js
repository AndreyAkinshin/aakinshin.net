const darkModeToggle = document.querySelector('dark-mode-toggle');
const pictures = document.querySelectorAll('picture');
const stylesheets = document.querySelectorAll('link[rel="stylesheet"]');

const toggleTheme = (e) => {
  const darkModeOn = e.detail.colorScheme === 'dark' ? true : false;
  pictures.forEach((picture) => {
    const dark = picture.querySelector('source[theme="dark"]');
    const light = picture.querySelector('source[theme="light"]');
    dark.media = darkModeOn ? 'all' : 'none';
    light.media = darkModeOn ? 'none' : 'all';
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