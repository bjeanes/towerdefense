// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var console;

try {
  console = {
    firebug: true,
    logged: false, // whether log has been called
    log: function(str) {
      if(!this.debugDiv) this.debugDiv = $('general_debug_info');
      
      if(!this.logged) {
        this.debugDiv.style.display = 'block'
        this.debugDiv.innerHTML = '';
        this.logged = true;
      }
      
      Element.insert(this.debugDiv, {bottom: '<div class="debug">'+str+'</div>'});
    }
  };
  window.console = console
} catch(e) {
  // Firebug installed?
}



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
  // new Ajax.Request('/game/status_update', {
  //   method: 'post',
  //   parameters: {lives: lives, gold: gold, income: income}
  // });
}

// Current user is attacking the next player
function js_attack(monster)
{
  // js_isAttacked(monster);
  new Ajax.Request('/game/attack', {
    method: 'post',
    parameters: {monster: monster}
  });
}

function js_isAttacked(monster)
{
  gameSwf().fl_receiveMonster(monster.toString());
}

// flash calls this function
function js_lifeLost()
{
  new Ajax.Request('/game/life_lost', {method: 'post'});
}

function embedGame()
{
  // if body#game exists
  if($('game') != null)
  { 
    swfobject.embedSWF('/game/index.swf', 'game_swf', 
      '800', '600', '9.0.0', '/juggernaut/expressinstall.swf', 
      {xmlMonsters: '/game/monsters.xml', xmlTowers: '/game/towers.xml', onServer: 'true'}, 
      {allowscriptaccess: 'always'});
      
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
  
  embedGame();

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