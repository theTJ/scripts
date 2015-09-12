// ==UserScript==
// @name        geraspora blockuser
// @namespace   gerasporablock
// @description blocksuser
// @include     https://pod.geraspora.de/stream
// @version     1
// @grant       none
// ==/UserScript==


var componentList = [];

// add the users you want to block in the list below

componentList[0] = "user to block";
componentList[1] = "second user to block";

$(document).ready(function() {
  console.log('GreaseMonkey: Diaspora* block users');
  var ms = $('#main_stream');
  var msHtml = ms.html();
  var msMonitoring = setInterval(function() {
    var newMsHtml = ms.html();
    if(msHtml != newMsHtml) {
      hideDeppen();
      // do not use newMsHtml cause we are inserting html in hideReshares()
      msHtml = ms.html();
    }
  }, 1500);

  function hideDeppen() {
   // console.log('hide the deppen'); //collapsible.collapsed // collapsible.opened //collapsible
    resharePost = $('div.stream_element:has(div.collapsible)').each(function(index, stream_element) {
      //console.log('anzahl  ' + index);
      var se = $(stream_element);
    //  console.log('se: ' + se );
    
        var originalAuthor = se.find('a.author').first().html();
        //console.log('originalAuthor=' + originalAuthor);
        
        for (var counter = 0; counter < componentList.length ; counter++) {


   // console.log('component: ' + componentList[counter] + '  author: ' + originalAuthor);
    
    if (componentList[counter] == originalAuthor) 
    {
    console.log('drin');
        se.hide();
    } 
} 
 
    }); // for each resharePost
  } // hideReshares() end
}); // document ready

