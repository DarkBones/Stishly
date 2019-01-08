$(document).on('turbolinks:load', ()=> {

  $('.timezone-on-focus').on('focusin', () => {
    $('#timezone_input').set_timezone();
  });
  
});