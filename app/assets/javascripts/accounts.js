//"use strict";

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

function goToAccount(object) {
  var linkName, url, $accountButton;

  $accountButton = $("#" + object.id);
  linkName = $accountButton.attr("name");
  url = "/accounts"
  if(typeof(linkName) !== "undefined") {
    url += "/" + linkName;
  }
  window.location.href = url;
}

// after all ajax requests are done, display the summary account
$(document).ajaxComplete(function() {
  displaySummaryAccount();
});

function toggleAccountBalanceEdit(obj) {
  if($("#editAccountBalance").length > 0) {
    $("#account-title-balance").hide();
    $("#editAccountBalance").show();
  }
}

// close the edit acco"unt balance container when clicking outside of it
$(document).mouseup(function(e) {
  var $container = $("#editAccountBalance");

  if($container.is(":hidden")) {
    return false;
  }

  var $input = $("#editAccountBalance #account_balance");
  var $balance = $("#account-title-balance");

  if(!$input.is(e.target)) {
    $container.hide();
    $input.val($balance.attr("balance_float"));
    $balance.show();
  }
});
