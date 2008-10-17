var messageBox   = null;
var messageInput = null;
var messsageSend = null;
var chatForm     = null;
var chatStatus   = null;
var gameSwf      = null;

var sendMessageOptions = null;

function setStatus(text) {
  chatStatus.innerHTML = text;
}

function receiveMessage(msg) {
  try {    
    Element.insert(messageBox, {bottom: msg});
    // TODO - only scroll if the box is already at the bottom
    messageBox.scrollTop = messageBox.scrollHeight;
  } catch (e) {
    // do nothing
    console.log("Message receipt failed.")
  }  
}

function sendMessage() {
  try {
    // We need to serialize the form at submit time, not page load
    sendMessageOptions['parameters'] = Form.serialize(chatForm);
    
    new Ajax.Request('/messages', sendMessageOptions);
  } finally {
    return false; // stop form submitting    
  }
}

function js_receiveData(lives, gold, income, monsterRequest)
{
  if(monsterRequest == null)
  {
    // just update player info
  }
  else
  {
    // update player info and send a monster to attackee
  }
}

// flash calls this function
function js_lifeLost()
{
  alert('life lost');
}

function js_lifeGained()
{
  // tell the swf that it has gained a life
  swf().lifeGained();
}

///////////// Observers: ///////////////

// Find all the elements we need and set them
document.observe("dom:loaded", function(event) {
  messageInput = $('message_content');
  messageSend  = $('message_send');
  messageBox   = $('messages');
  chatForm     = $('send_message_form');
  chatStatus   = $('chat_status');
  
  chatForm.onsubmit = sendMessage;
  
  sendMessageOptions = {
    asynchronous: true, 
    evalScripts:  true,
    onComplete:   function(request) { messageInput.value = ''; }
  };
  
  if($('game_swf') != null)
  { // we are in a game, insert the flash
    flashvars = attributes = {};
    params = {
      allowscriptaccess: 'always'
    };
    
    swfobject.embedSWF('/index.swf', 'game_swf', 
      '800', '600', '9.0.0', '/juggernaut/expressinstall.swf', 
      flashvars, params, attributes);
      
    gameSwf = $('game_swf'); // set the global game variable
  }
});

document.observe("juggernaut:connected", function(event) {
  setStatus('Connected!');
  
  messageInput.enable();
  messageInput.focus();
  
  messageSend.enable();
});

document.observe("juggernaut:disconnected", function(event) {
  setStatus('Disconnected.');
  messageInput.disable();
  messageSend.disable();
});

document.observe("juggernaut:errorConnecting", function(event) {
  setStatus('Error connecting!');
  messageInput.disable();
  messageSend.disable();
});

document.observe("juggernaut:initialized", function(event) {
  setStatus('Connecting...');
});