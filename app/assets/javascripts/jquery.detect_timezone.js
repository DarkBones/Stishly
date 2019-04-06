/**
 * jQuery Detect Timezone plugin
 *
 * Copyright (c) 2011 Scott Watermasysk (scottwater@gmail.com)
 * Provided under the Do Whatever You Want With This Code License. (same as detect_timezone).
 *
 */

(function( $ ){

  $.fn.set_timezone = function(options) {
    
      this.val(this.get_timezone(options));      
      return this;
  };
  
  $.fn.get_timezone = function(options) {
    return jstz.determine().name();
  };
  
})( jQuery );
