$(document).on('turbolinks:load', ()=> {
  
  $('.datepicker').datepicker({
    todayBtn: "linked",
    multidate: false,
    autoclose: true,
    todayHighlight: true
  });

});