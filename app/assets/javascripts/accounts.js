$(document).on('turbolinks:load', ()=> {

  // Disable the submit button
  $("#accountmenu").find("input[type=submit]").attr("disabled", "disabled");

  // if the create account button is clicked, show the account creation menu
  $('#create-account-button').on('click', () => {
    ToggleCardForm('#accountmenu');
    $(".accountmenu__name").focus();
  });

  // set a maximum length of 50 for the account creation menu
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

  // decide whether to show the summary account
  display_summary_account();

});

// if one of the accounts in the left menu is clicked, navigate to that account's page
$(document).on('click', '.account-button', (event) => {
  link_name = event.currentTarget.closest('.account-button').getAttribute('name')
  window.location.href = '/' + link_name.replace('_', '/');
});

// after all ajax requests are done, display the summary account
$(document).ajaxComplete(function() {
  display_summary_account();
});

// if there is less than two accounts, don't show the summary accounts
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

// gets the currently active account by checking the URL of the current page
function get_active_account_name(){
  url_arr = window.location.pathname.split('/');
  if (url_arr[1].toLowerCase() == 'accounts') {
    return url_arr[2]
  } else{
    return null;
  }
}