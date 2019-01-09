$(document).on('turbolinks:load', ()=> {

  $('#create-account-button').on('click', () => {
    $('#overlay').fadeToggle(200);
    $('#accountmenu').slideToggle(100);
    $(".accountmenu__name").focus();
  });

  $('.account-button').on('click', (event) => {
    link_name = event.currentTarget.closest('.account-button').getAttribute('name')
    console.log('/' + link_name.replace('_', '/'));
    window.location.href = '/' + link_name.replace('_', '/');
  });

  $('.accountmenu__name').attr('maxlength',50);

  // don't allow dots in input field
  $('.accountmenu__name').keyup(function(e){
    if (e.which == 190){
      $('.accountmenu__name').val($('.accountmenu__name').val().replace(".", ""));
    }
  });
});

