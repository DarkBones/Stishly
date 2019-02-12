$(document).on('turbolinks:load', ()=> {

  // Disable the submit button
  $("#accountmenu").find("input[type=submit]").attr("disabled", "disabled");

  $('#create-account-button').on('click', () => {
    ToggleCardForm('#accountmenu');
    $(".accountmenu__name").focus();
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

  display_summary_account();

});

$(document).on('click', '.account-button', (event) => {
  link_name = event.currentTarget.closest('.account-button').getAttribute('name')
  window.location.href = '/' + link_name.replace('_', '/');
});

$(document).ajaxComplete(function() {
  display_summary_account();
});

function display_summary_account() {
  if ($("#accounts_list li").length < 3) {
    $("#accounts_list li").first().hide();
  } else{
    $("#accounts_list li").first().show();
  }

  if ($("#accounts_list li").length > 1) {
    $("#accounts_list p").hide();
  } else{
    $("#accounts_list p").show();
  }
}