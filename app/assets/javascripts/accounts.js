$(document).on('turbolinks:load', ()=> {

  // Disable the submit button
  $("#accountform").find("input[type=submit]").attr("disabled", "disabled");

  // decide whether to show the summary account
  display_summary_account();

});

function UpdateAccountNameInput(inputObject) {
  var $accountform = $();

  var $input = $('#' + inputObject.id);
  $accountform = $input.closest('#accountform');
  var inputValue = $input.val();

  // don't allow dots in input field
  $input.val(inputValue.replace(/\./g, ""));

  if (inputValue.length > 0) {
    $accountform.find("input[type=submit]").removeAttr("disabled");
  } else {
    $accountform.find("input[type=submit]").attr("disabled", "disabled");
  }
}

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