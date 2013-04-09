//= require jquery
//= require modernizr.custom
//= require core/deck.core
//= require extensions/hash/deck.hash
//= require bootstrap
//= require_self

$(document).keyup(function(e) {
    if (e.keyCode == 27) { $('.exit-presentation')[0].click(); }
});