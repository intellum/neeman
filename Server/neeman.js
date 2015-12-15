var credentials = require('./credentials.js');
var express = require('express');
var connect = require('connect');
var compression = require('compression');
var app = express();
//var auth = require('./authentication.js');

app.disable('x-powered-by');
app.use(compression());
app.use(express.static(__dirname + '/public'));
app.use(require('cookie-parser')(credentials.cookieSecret));
app.use(function(req, res, next){
  //console.log('processing request for ' + req.url + '...');
  var authenticated = true;
  var authToken = req.cookies['connect.sid'];
  if(['/login', 'logout', '/'].indexOf(req.url) < 0){
    if('this-is-your-auth-token' != authToken) {
      console.log('Redirect to Login');
      res.writeHead(302, {
        'Location': '/login'
      });
      res.end();
      authenticated = false;
    }
  }
  if(authenticated){
    console.log('Auth Token:' + authToken);
    next();
  }
});

//set up handlevars view engine
var handlebars = require('express-handlebars')
                  .create({defaultLayout:'main'});
app.engine('handlebars', handlebars.engine);
app.set('view engine', 'handlebars');

app.set('port', process.env.PORT || 3000);

// Authentication
app.get('/logout', function(req, res){
  res.clearCookie('connect.sid');
  res.writeHead(302, {
    'Location': '/login'
  });
  res.end();
});

app.get('/login', function(req, res){
 res.render('login', {title:'Login'});
});

app.post('/login', function(req, res){
  res.cookie('connect.sid', 'this-is-your-auth-token');
  console.log('redirect');
  res.writeHead(302, {
    'Location': '/profile'
  });
  res.end();
});





// Page: Home
app.get('/', function(req, res){
  res.render('home', {title:'Home'});
});

// Page: Caching
app.get('/caching', function(req, res){
  var stop = new Date().getTime();
  while(new Date().getTime() < stop + 5000) {
    ;
  }
  var time = new Date();
  res.setHeader('Cache-Control', 'public, max-age=20'); 
  res.setHeader('Last-Modified', time.toUTCString());
  res.render('caching', {title:'Caching', date:time});
});

// Page: Profile
app.get('/profile', function(req, res){
  var authToken = req.cookies['connect.sid'];
  res.render('profile', { title:"Profile", heading:'About Neeman', profile: 'We are a small crew of skilled craftsmen from Latvia who use our heritage of craftsmanship handed down through many generations to design and create woodworking tools and knives. Our process, our method and mission keep these traditions and crafts alive and well. In this high-tech age, our own traditional craftsmanship is flourishing.', authToken: authToken });
});








// custom 404 page
app.use(function(req, res){
  res.status(404);
  res.render('404');
});

// custom 500 page
app.use(function(err, req, res, next){
  console.error(err.stack);
  res.status(500);
  res.render('500');
});

app.listen(app.get('port'), function(){
  console.log( 'Express started on http://localhost:' + app.get('port') + '; press Ctrl-C to terminate.');
});

