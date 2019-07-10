function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
    var expires = "expires=" + d.toGMTString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

function getCookie(cname) {
    var name = cname + "=";
    var decodedCookie = decodeURIComponent(document.cookie);
    var ca = decodedCookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
}

function refreshTheme() {
    var theme = getCookie("theme")
    var themeHighlight = getCookie("themeHighlight")
    if (theme == "")
        theme = "lumen";
    if (themeHighlight == "")
        themeHighlight = "github";
    var isLight = (theme == "lumen");
    if (isLight) {
        document.getElementById('theme-switcher-to-dark').style.display = 'block';
        document.getElementById('theme-switcher-to-light').style.display = 'none';
    } else {
        document.getElementById('theme-switcher-to-dark').style.display = 'none';
        document.getElementById('theme-switcher-to-light').style.display = 'block';
    }

    var styleSheets = document.getElementsByTagName("link");
    for (var i = 0; i < styleSheets.length; i++) {
        var ss = styleSheets[i];
        if (ss.href.indexOf("-bootstrap.min.css") !== -1)
            ss.disabled = (ss.href.indexOf(theme) !== -1) ? false : true;
        if (ss.href.indexOf("-highlight.css") !== -1)
            ss.disabled = (ss.href.indexOf(themeHighlight) !== -1) ? false : true;
    }
}

function setTheme(name, hname) {
    setCookie("theme", name, 30);
    setCookie("themeHighlight", hname, 30);
    refreshTheme();
}

refreshTheme();