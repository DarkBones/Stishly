$(document).on('turbolinks:load', ()=> {
  $('.navbar-menu-toggle').on('click', (event) => {
    $('.navbar-menu').toggle();
  });
});