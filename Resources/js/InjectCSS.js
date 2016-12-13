document.documentElement.style.webkitTouchCallout='none';

var root = document.getElementsByTagName( 'html' )[0]
var existingClass = root.getAttribute( 'class' )
root.setAttribute( 'class', 'neeman-hybrid-app neeman-hybrid-app-version-${VERSION} ' + existingClass );

var styleElement = document.createElement('style');
root.appendChild(styleElement);
styleElement.textContent = '${CSS}';
