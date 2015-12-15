app.use(function(req, res, next){
  //console.log('processing request for ' + req.url + '...');
  if(!['/login', 'logout', '/'].indexOf(req.url) < 0){
    var authToken = req.cookies['connect.sid'];
    if('this-is-your-auth-token' != authToken) {
      console.log('Redirect to Login');
      res.writeHead(302, {
        'Location': '/login'
      });
      res.end();
    }
    console.log('Auth Token:' + authToken);
  }
  next();
});

 
