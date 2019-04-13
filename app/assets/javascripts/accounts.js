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

$(document).on("turbolinks:load", () => {
  displaySummaryAccount();
});

function updateAccountNameInput(inputObject) {
  var $accountform = $();
  var $input = $();
  var inputValue = "";

  $input = $("#" + inputObject.id);
  $accountform = $input.closest("#accountform");
  inputValue = $input.val();

  // don't allow dots in input field
  $input.val(inputValue.replace(/\./g, ""));

  // don't allow question marks in input field
  $input.val(inputValue.replace(/\?/g, ""));
}

function goToAccount(object) {
  var linkName, url, $accountButton;

  $accountButton = $("#" + object.id);
  linkName = $accountButton.attr("name");
  url = "/" + linkName.replace("_", "/");
  window.location.href = url;
}

// after all ajax requests are done, display the summary account
$(document).ajaxComplete(function() {
  displaySummaryAccount();
});

// gets the currently active account by checking the URL of the current page
function getActiveAccountName(){
  var urlArr = [];

  urlArr = window.location.pathname.split("/");
  if (urlArr[1].toLowerCase() === "accounts") {
    if (typeof(urlArr[2]) !== "undefined") {
      if (urlArr[2].length > 0){
        return decodeURI(urlArr[2]);
      }
    }
  }

  return null;
}
