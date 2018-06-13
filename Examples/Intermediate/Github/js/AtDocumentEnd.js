(function(){
 var buttons = document.getElementsByClassName("header-context-button");
 if(buttons.length > 0) {
    var button = buttons[0];
    webkit.messageHandlers.didGetBarButton.postMessage(button.href);
 }
 
 var metaTags=document.getElementsByTagName("meta");

 var username = "";
 for (var i = 0; i < metaTags.length; i++) {
    if (metaTags[i].getAttribute("name") == "octolytics-actor-login") {
        username = metaTags[i].getAttribute("content");
        break;
    }
 }
 webkit.messageHandlers.didGetUserName.postMessage(username);
})();
