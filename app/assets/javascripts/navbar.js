$(document).on("turbolinks:load", () => {
  $(".navbar__menu-toggle").on("click", (event) => {
    $(".navbar__menu").slideToggle(50);
    event.stopPropagation();
  });

  $(document).on("click", (event) => {
    $(".navbar__menu").slideUp(50);
  });

  
});