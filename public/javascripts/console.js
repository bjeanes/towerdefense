// firebug console faker, for non-firefox browsers

window.console = {
  firebug: '1.0',
  log:     function() { 
             $('console_text').innerHTML = arguments[0] + "\n" + $('console_text').innerHTML;
           },
  clear:   function() {
             $('console_text').innerHTML = '';
           }
}

function alert() {
  console.log(arguments[0])
}