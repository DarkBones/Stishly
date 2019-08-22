$(document).on('turbolinks:load', ()=> {

  $(function() {
    window.UpdateLeftMenu = function() {
      $.ajax({
        type: "GET",
        dataType: "html",
        url: "/api/v1/render/left_menu",
        success(data) {

          $("#page-left-menu").html(data);
        }
      });
    }
  });
  
});