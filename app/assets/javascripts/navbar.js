$(document).on('turbolinks:load', ()=> {
  $('.navbar__menu-toggle').on('click', (event) => {
    $('.navbar__menu').toggle();
  });
});