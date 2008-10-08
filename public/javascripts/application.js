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
