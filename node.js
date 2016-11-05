var axios = require('axios');
var express = require('express');
var data = require('./docs/data.json');

var app = express();

app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});

app.get('/', (req, res) => res.status(200).json(data));

app.listen(4000, function () {
  console.log('Example app listening on port 3000!');
});
