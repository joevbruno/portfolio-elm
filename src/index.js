/*
	INDEX.js
	This file kicks off the app.
*/
// - require sass styling
require('./styles/main.scss');
// - require the main elm file
var Elm = require('./elm/Main');
// - mount into the document using native JS
Elm.Main.embed(document.getElementById('app'));

document.addEventListener('DOMContentLoaded', function() {
   setTimeout(function() {
   document.onscroll = function(e) {
      const navClass = "nav--pinned";
      const top = document.body.scrollTop;
      const nav = document.getElementById('nav')
      if (top > 300 && !nav.classList.contains(navClass)) {
         nav.classList.add(navClass);
      } else if (top < 300 && nav.classList.contains(navClass)) {
         nav.classList.remove(navClass);
      }
   }

   var job = document.getElementById('job');
   job.onclick = function(e){
       window.open('https://www.itdashboard.gov/drupal/summary/019/1608');
   }

   var recentProject = document.getElementById('project');
   recentProject.onclick = function(e){
       window.open('https://www.infusionnow.tv');
   }

   var contactBtn = document.getElementById('contact-btn');
   contactBtn.onclick = function(e){
       window.open('https://twitter.com/joevbruno');
   }
}, 3000);
});
