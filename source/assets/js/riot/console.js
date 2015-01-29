riot.tag('xanadu-console', '<div class="console"> <form onsubmit="{ parent.console_input }"> <textarea class="console-capture"></textarea> </form> </div>', function(opts) {
    this.console_input = function(ev) {
      alert(ev)
    }.bind(this);
  
});