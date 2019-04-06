/**
 * jQuery Detect Timezone plugin
 *
 * Copyright (c) 2011 Scott Watermasysk (scottwater@gmail.com)
 * Provided under the Do Whatever You Want With This Code License. (same as detect_timezone).
 *
 */

(function( $ ){

  $.fn.setTimezone = function(options) {
    
      this.val(this.getTimezone(options));      
      return this;
  };
  
  $.fn.getTimezone = function(options) {
    return jstz.determine().name();
  };
  
})( jQuery );
