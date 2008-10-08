document.observe("juggernaut:connected", function(event) {
  setStatus('Connected!');
  
  var content = $('message_content');
  
  content.enable();
  content.focus();
  
  $('message_send').enable();
});

document.observe("juggernaut:disconnected", function(event) {
  setStatus('Disconnected.');
  $('message_content').disable();
  $('message_send').disable();
});

document.observe("juggernaut:initialized", function(event) {
  setStatus('Connecting...');
});

function setStatus(text) {
  $('chat_status').innerHTML = text;
}