document.documentElement.style.webkitTouchCallout='none';

var root = document.getElementsByTagName( 'html' )[0]
root.setAttribute( 'class', 'hybrid' );

var styleElement = document.createElement('style');
root.appendChild(styleElement);
styleElement.textContent = '${CSS}';

