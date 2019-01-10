$(document).on('turbolinks:load', ()=> {

  // Disable the submit button
  $("#accountmenu").find("input[type=submit]").attr("disabled", "disabled");

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
    name_value = $('.accountmenu__name').val()
    $('.accountmenu__name').val(name_value.replace(/\./g, ""));

    // Activate submit button if name is provided
    if (name_value.length > 0){
      $("#accountmenu").find("input[type=submit]").removeAttr("disabled");
    } else{
      $("#accountmenu").find("input[type=submit]").attr("disabled", "disabled");
    }
  });
});

