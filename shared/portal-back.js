function voltarAoPortal() {
  var themeHash = '';

  if (window.opener && !window.opener.closed) {
    try {
      var active = window.opener.document.querySelector('.theme-content.active');
      if (active && active.id) themeHash = '#' + active.id;
    } catch (e) {}
  }

  if (!themeHash) {
    var t = new URLSearchParams(window.location.search).get('t');
    if (t) themeHash = '#theme-' + t;
  }

  window.close();
  setTimeout(function () {
    window.location.href = '../../index.html' + themeHash;
  }, 100);
}
