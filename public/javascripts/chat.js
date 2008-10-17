
////////////// Global Vars ////////////////
var messageBox   = null;
var messageInput = null;
var messsageSend = null;
var chatForm     = null;
var chatStatus   = null;
var gameSwf      = null;

var sendMessageOptions = null;


//////////// Juggernaut status //////////////
function setStatus(text) {
  chatStatus.innerHTML = text;
}

///////////// Chat Functions ///////////////

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

//////////// Game Functions //////////////

function js_statusUpdate(lives, gold, income)
{
  if(lives <= 0) alert('You are dead!');
  // update player info
  console.log("Lives: "+ lives + "\nGold: " + gold + "\nIncome: " + income);
}

// Current user is attacking the next player
function js_attack(monster)
{
  console.log("Monster: "+ monster);
}

function js_isAttacked(monster)
{
  gameSwf().fl_receiveMonster(monster.toString());
}

// flash calls this function
function js_lifeLost()
{
  // Server request will be sent here. the server should then
  // decrease
  console.log('Life lost... TODO: send this to server');
}

function js_lifeGained()
{
  // tell the swf that it has gained a life
  gameSwf().fl_lifeGained();
}

function embedGame()
{
  // if body#game exists
  if($('game') != null)
  { 
    swfobject.embedSWF('/index.swf', 'game_swf', 
      '800', '600', '9.0.0', '/juggernaut/expressinstall.swf', 
      false, {allowscriptaccess: 'always'});
      
    gameSwf = function() {
      return $('game_swf');
    };
    
    return true;
  }
  
  gameSwf = function() { return null; }
  return false;
}

///////////// Observers: ///////////////

// Find all the elements we need and set them
// as well as insert the game SWF if we are on
// a game page
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
  
  if(embedGame())
  {
    window.onload = function(){
      // This will tell the game that we are in multiplayer mode
      gameSwf().fl_checkLocal();
    };
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