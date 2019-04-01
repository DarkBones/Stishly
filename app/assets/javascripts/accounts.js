$(document).on('turbolinks:load', ()=> {

  // Disable the submit button
  $("#accountform").find("input[type=submit]").attr("disabled", "disabled");

  // decide whether to show the summary account
  displaySummaryAccount();

});

function updateAccountNameInput(inputObject) {
  var $accountform = $();
  var $input = $();
  var inputValue = "";

  $input = $('#' + inputObject.id);
  $accountform = $input.closest('#accountform');
  inputValue = $input.val();

  // don't allow dots in input field
  $input.val(inputValue.replace(/\./g, ""));

  if (inputValue.length > 0) {
    $accountform.find("input[type=submit]").removeAttr("disabled");
  } else {
    $accountform.find("input[type=submit]").attr("disabled", "disabled");
  }
}

function goToAccount(object) {
  var linkName = "";
  var url = "";

  $accountButton = $('#' + object.id);
  linkName = $accountButton.attr('name');
  url = '/' + linkName.replace('_', '/');
  window.location.href = url;
}

// after all ajax requests are done, display the summary account
$(document).ajaxComplete(function() {
  displaySummaryAccount();
});

// if there is less than two accounts, don't show the summary accounts
function displaySummaryAccount() {
  if ($("#accounts_list li").length < 3) {
    $("#accounts_list li").first().hide();
  } else{
    $("#accounts_list li").first().show();
  }

  // if there are no accounts, display the instruction to create an account
  if ($("#accounts_list li").length > 1) {
    $("#accounts_list p").hide();
  } else{
    $("#accounts_list p").show();
  }
}

// gets the currently active account by checking the URL of the current page
function getActiveAccountName(){
  var url_arr = [];

  url_arr = window.location.pathname.split('/');
  if (url_arr[1].toLowerCase() === 'accounts') {
    if (url_arr[2].length > 0){
      return decodeURI(url_arr[2]);
    }
  }

  return null;
}