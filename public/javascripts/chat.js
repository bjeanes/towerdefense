var messageBox   = null;
var messageInput = null;
var messsageSend = null;
var chatForm     = null;
var chatStatus   = null;

var sendMessageOptions = null;

function setStatus(text) {
  chatStatus.innerHTML = text;
}

function receiveMessage(msg) {
  try {    
    Element.insert(messageBox, {bottom: msg});
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