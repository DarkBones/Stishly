//"use strict";

var newTransactionsFormTotalAmount = 0;

function getFormId(obj) {
  return "#" + $(obj).parents(".transactionform").attr("id");
}

function getCurrencyFromAccount(account) {
  var currency;

  account = account.split(" ");
  currency = account[account.length - 1];
  currency = currency.replace("(", "");
  currency = currency.replace(")", "");

  return currency;
}

function getTransactionTotalFromMultiple(formId) {
  let total = 0;

  let $target = $(formId + " #transaction_transactions");
  let text = $target.val();
  let lines = text.split("\n");

  let line = lines.pop();
  let words = [];
  while (typeof(line) !== "undefined") {
    words = line.split(" ");

    if (!isNaN(parseFloat(words[words.length - 1]))) {
      total += parseFloat(words[words.length - 1]);
    }

    line = lines.pop();
  }

  return total;

}

function updateTransactionsTotal(formId, force=false) {
  var currency, total, $targetTotal, $targetTransactions, $targetCurrency, totalStr;

  $targetTotal = $(formId + " #transactions-total");
  $targetTransactions = $(formId + " #transaction_transactions");

  $targetCurrency = $(formId + " #transaction_currency");

  total = getTransactionTotalFromMultiple(formId);

  if(typeof(total) === "undefined") {
    return;
  }

  if(total === newTransactionsFormTotalAmount && !force) {
    return;
  }

  totalStr = total.toString().replace(".", "$");

  currency = $targetCurrency.val();

  $.ajax({
    type: "GET",
    dataType: "text",
    url: "/api/v1/currencies/" + currency + "/format/" + totalStr + "/?float=true",
    beforeSend(){
      $targetTotal.hide();
      insertAjaxSpinner($targetTotal.parent().parent().find("#total_ajax_spinner"), 38);
    },
    complete(){
      removeAjaxSpinner($targetTotal.parent().parent().find("#total_ajax_spinner"));
    },
    success(data) {
      $targetTotal.text(data);
      $targetTotal.show();
      newTransactionsFormTotalAmount = total;
    }
  });

}

// returns true if there are multiple transactions
function isTransactionMultiple(formId) {
  if ($(formId + " #multiple-multiple").hasClass("active")) {
    return true;
  } else {
    return false;
  }
}

// returns the type of transaction
function getTransactionType(formId) {
  var type;

  if ($(formId + " #type-expense").hasClass("active")) {
    return "expense";
  } else if ($(formId + " #type-income").hasClass("active")) {
    return "income";
  } else {
    return "transfer";
  }

}

function updateTransactionResult(formId) {
  let isMultiple = isTransactionMultiple(formId);
  let rate = 1;
  let amount = 0;
  let type = getTransactionType(formId);

  let $rateTarget = $(formId + " #transaction_rate");
  let $resultTarget = $(formId + " #transaction_account_currency");
  let $amountTarget = $(formId + " #transaction_amount");
  let $accountTarget = $(formId + " #transaction_to_account");
  let $spinnerTarget = $(formId + " #transaction_account_currency_spinner");
  if (type === "transfer") {
    $rateTarget = $(formId + " #transaction_rate_from_to");
    $resultTarget = $(formId + " #transaction_to_account_currency");
    $accountTarget = $(formId + " #transaction_to_account");
    $spinnerTarget = $(formId + " #transaction_transfer_currency_spinner");
  }

  if ($resultTarget.is(":visible")) {
    rate = $rateTarget.val();
    if (isMultiple) {
      amount = getTransactionTotalFromMultiple(formId);
    } else {
      amount = $amountTarget.val();
    }

    $.ajax({
      type: "GET",
      dataType: "json",
      url: "/api/v1/accounts/" + encodeURI($accountTarget.val()) + "/currency",
      beforeSend() {
        $resultTarget.hide();
        $spinnerTarget.show();
      },
      complete() {
        $resultTarget.show();
        $spinnerTarget.hide();
      },
      success(data) {
        let result = Math.round((amount * rate) * data.subunit_to_unit) / data.subunit_to_unit;
        let subunitDigits = Math.floor(Math.log10(data.subunit_to_unit));
        $resultTarget.val(result.toFixed(subunitDigits));
      }
    });
  }

  if(isMultiple){
    updateTransactionsTotal(formId);
  }
}

// whether the transfer currency rate should be shown
function showTransferCurrencyRates(formId, type=null) {
  var from, to, fromCurrency, toCurrency, $submitButton;

  if (type == null) {
    type = getTransactionType(formId);
  }

  if (type === "transfer") {
    $(formId + " #transfer-currency-options").hide();

    fromCurrency = getCurrencyFromAccount($(formId + " #transaction_from_account option:selected").text());
    toCurrency = getCurrencyFromAccount($(formId + " #transaction_to_account option:selected").text());

    from = encodeURI($(formId + " #transaction_from_account").val());
    to = encodeURI($(formId + " #transaction_to_account").val());

    $submitButton = $(formId + " input[type='submit']");

    if (fromCurrency !== toCurrency) {
      $.ajax({
        type: "GET",
        dataType: "json",
        url: "/api/transfer_accounts/" + from + "/" + to,
        beforeSend() {
          $submitButton.attr("disabled", true);
          $(formId +  " #transfer_conversion_spinner").show();
        },
        complete() {
          $(formId + " #transfer_conversion_spinner").hide();
        },
        success(data) {
          $submitButton.removeAttr("disabled");
          $(formId + " #to_account_currency").text("Amount in " + data.to_account.currency);
          $(formId + " #transfer-currencies").show();
          $(formId + " #rate_from_to").text("Rate " + data.from_account.currency + " to " + data.to_account.currency);
          $(formId + " #transaction_rate_from_to").val(data.currency_rate);

          updateTransactionResult(formId);
        }
      });
    } else {
      $(formId + " #transaction_rate_from_to").val(1);
      $(formId + " #transfer-currencies").hide();
    }
  } else {
    $(formId + " #transfer-currencies").hide();
  }

}

function changeTransactionType(type, obj, formId=null) {
  if (formId == null){
    formId = getFormId(obj);
  }

  switch(type) {
    case "transfer":
      $(formId + " #single-account").hide();
      $(formId + " #categories").hide();
      $(formId + " #transfer-account").show();
      $(formId + " #type").removeClass("bg-danger");
      $(formId + " #type").addClass("bg-warning");
      $(formId + " #type").removeClass("bg-success");
      $(formId + " #transaction-currency-options").hide();
      $(formId + " #transaction_type_transfer").prop("checked", true);
      break;
    case "income":
      $(formId + " #single-account").show();
      $(formId + " #categories").show();
      $(formId + " #transfer-account").hide();
      $(formId + " #type").removeClass("bg-danger");
      $(formId + " #type").removeClass("bg-warning");
      $(formId + " #type").addClass("bg-success");
      $(formId + " #transaction-currency-options").show();
      $(formId + " #transaction_type_income").prop("checked", true);
      break;
    default:
      $(formId + " #single-account").show();
      $(formId + " #categories").show();
      $(formId + " #transfer-account").hide();
      $(formId + " #type").addClass("bg-danger");
      $(formId + " #type").removeClass("bg-warning");
      $(formId + " #type").removeClass("bg-success");
      $(formId + " #transaction-currency-options").show();
      $(formId + " #transaction_type_expense").prop("checked", true);
  }

  showTransferCurrencyRates(formId, type);
}

function changeTransactionMultiple(type, obj){
  var formId = getFormId(obj);
  switch (type) {
    case "single":
      $(formId + " #amount").show();
      $(formId + " #transactions").hide();
      break;
    default:
      $(formId + " #amount").hide();
      $(formId + " #transactions").show();
  }

  setTimeout(function(){
    updateTransactionResult(formId);
  }, 1000);
}


function updateTransactionRate(obj) {
  var $rateTarget, $resultTarget, isMultiple, $amountTarget, result, amount, rate, formId;

  formId = getFormId(obj);
  $rateTarget = $(formId + " #transaction_rate");
  $resultTarget = $(formId + " #transaction_account_currency");
  isMultiple = isTransactionMultiple(formId);
  result = 0;
  amount = 0;
  rate = 0;

  if (isMultiple) {
    $amountTarget = $(formId + " #transactions textarea");
  } else {
    $amountTarget = $(formId + " #transaction_amount");
  }

  if($resultTarget.is(":visible")) {
    result = $resultTarget.val();
    if (isMultiple) {
      amount = getTransactionTotalFromMultiple(formId);
    } else {
      amount = $amountTarget.val();
    }
    rate = result / amount;
    $rateTarget.val(rate);
  }

}

function changeTransactionCurrency(obj, ignore=false, lockCurrency=true){
  // return if the form only uses base transaction fields
  var formId, result, currency, account, $submitButton, $spinnerContainer, $spinner;

  if (ignore) {
    return;
  }

  if(lockCurrency){
    $(obj).addClass("changed");
  }

  formId = getFormId(obj);
  result = 0;

  $(formId + " #currency-rate").hide();
  $(formId + " #currency-result").hide();

  currency = $(formId + " #transaction_currency").val();

  account = $(formId + " #single-account select").val();

  $spinnerContainer = $(formId + " #currency_conversion_ajax_spinner_container");
  $spinner = $(formId + " #currency_conversion_ajax_spinner_container #currency_conversion_ajax_spinner");

  $submitButton = $(formId + " input[type='submit']");

  $.ajax({
    type: "GET",
    dataType: "json",
    url: "/api/v1/accounts/" + encodeURI(account) + "/currency",
    beforeSend() {
      $submitButton.attr("disabled", true);
      $spinnerContainer.show();
      insertAjaxSpinner($spinner, 38);
    },
    success(dataCurrency) {
      $submitButton.removeAttr("disabled");
      if (dataCurrency.iso_code !== currency){
        $.ajax({
          type: "GET",
          dataType: "text",
          url: "/api/v1/currencies/" + currency + "/rate/" + dataCurrency.iso_code,
          beforeSend() {
            $submitButton.attr("disabled", true);
            $spinnerContainer.show();
            insertAjaxSpinner($spinner, 38);
          },
          complete() {
            $spinnerContainer.hide();
            removeAjaxSpinner($spinner);
          },
          success(dataRate) {
            $(formId + " #account_currency").text("Amount in " + dataCurrency.iso_code);
            $(formId + " #currency-rate").show();
            $(formId + " #currency-result").show();
            $(formId + " #currency-rate input").val(dataRate);

            if ($(formId + " #amount").is(":visible")){
              result = $(formId + " #amount input").val() * dataRate;
            } else{
              result = getTransactionTotalFromMultiple(formId) * dataRate;
            }

            $(formId + " #currency-result input").val(Math.round(result * dataCurrency.subunit_to_unit) / dataCurrency.subunit_to_unit);
            $submitButton.removeAttr("disabled");
          }
        });

      } else {
        $(formId + " #currency-rate").hide();
        $(formId + " #currency-result").hide();
        $(formId + " #currency-rate input").val("");
        $(formId + " #currency-result input").val("");

        $spinnerContainer.hide();
        removeAjaxSpinner($spinner);
      }
    }
  });
  updateTransactionsTotal(formId, true);
  updateTransactionResult(formId);
}

function changeTransactionAccount(obj) {
  var formId, account, transactionType, currency, $currencyTarget;

  formId = getFormId(obj);
  account = $(obj).text();
  transactionType = getTransactionType(formId);

  $currencyTarget = $(formId + " #transaction_currency");

  currency = getCurrencyFromAccount($(formId + " #transaction_account option:selected").text());

  if ($currencyTarget.hasClass("changed")){
    if (transactionType !== "transfer") {
      if (currency === $currencyTarget.val()){
        $(formId + " #currency-rate").hide();
        $(formId + " #currency-result").hide();
      } else {
        changeTransactionCurrency($(formId + " #currency-result"));
      }
    } else {
      $(formId + " #currency-rate").show();
      $(formId + " #currency-result").show();
    }

    //return;
  }

  if (transactionType !== "transfer") {
    if (!$currencyTarget.hasClass("changed")){
      $currencyTarget.val(currency);
    }
  } else {
    if ($(obj).attr("id") === "transaction_from_account") {
      $(formId + " #transaction_currency").val(currency);
    }
    showTransferCurrencyRates(formId);
  }  

  updateTransactionsTotal(formId, true);
}

function changeTransactionToAccount(obj) {
  var formId = getFormId(obj);
  showTransferCurrencyRates(formId);
}

function resetAccountOptions(formId) {
  var activeAccount;

  activeAccount = getActiveAccountName();
  if (activeAccount) {
    $(formId + "#transaction_account").val(activeAccount);
    $(formId + " #transaction_from_account").val(activeAccount);
    $(formId + " #active_account_field").val(activeAccount);
  } else {
    $(formId + " #transaction_account").val($(formId + " #transaction_account option:first").val());
    $(formId + " #transaction_from_account").val($(formId + " #transaction_from_account option:first").val());
  }
  $(formId + " #transaction_to_account").val($(formId + " #transaction_to_account option:first").val());
}

function resetButtonGroups(formId) {
  $(formId + " #button-group").each(function(index){
    $(this).find("input").each(function(i){
      $(this).prop("checked", i===0);
    });
    $(this).find("label").each(function(i){
      if(i === 0){
        $(this).addClass("active");
      } else {
        $(this).removeClass("active");
      }
    });
  });
}

function resetTextInputs(formId) {
  $(formId + " input.form-control, " + formId + " textarea.form-control").each(function(index){
    if($(this).hasClass("ignoreReset") === false){
      $(this).val("");
    }
  });
}

function resetDateAndTime(formId) {
  $(formId + " #transaction_date").val(getDate());
  $(formId + " #transaction_time").val(getTime());
}

function resetAccountAndCurrencyDropdowns(formId) {
  var account, accountSelect;

  account = getActiveAccountName();
  if (account == null) {
    account = $(formId + " #transaction_account").find("option:first").val();
  }

  $(formId + " #transaction_account").val(account);
  $(formId + " #transaction_from_account").val(account);

  accountSelect = $(formId + " #transaction_account option:selected").text();

  $(formId + " #transaction_currency").val(getCurrencyFromAccount(accountSelect));
  $(formId + " #transaction_currency").removeClass("changed");
  
}

function resetCategoryDropdown(formId) {
  var optionHtml;

  $(formId + " #transaction_category_id").val(0);
  optionHtml = $(formId + " [id^=categoriesDropdownOptions]").find("li").first().html();
  $(formId + " button#categories-dropdown").html(optionHtml);
}

function resetTransactionMenu(formId){
  /*setTimeout(function(){ 
    console.log("FOCUS");
    $("#transaction_description").focus();
  }, 500);*/


  changeTransactionType("expense", null, formId);
  resetAccountOptions(formId);
  resetButtonGroups(formId);
  resetTextInputs(formId);
  resetDateAndTime(formId);
  resetAccountAndCurrencyDropdowns(formId);
  resetCategoryDropdown(formId);
  showTransferCurrencyRates(formId);

  // show & hide default fields
  $(formId + " div.default-show").show();
  $(formId + " div.default-hide").hide();

  newTransactionsFormTotalAmount = 0;
}

function renderTransactionMenu(formId){
  if ($("#new_transactions_form form").length === 0) {
    $.ajax({
      type: "GET",
      dataType: "html",
      url: "/api/render_transactionform",
      beforeSend(){
        insertAjaxSpinner($("#new_transactions_form"));
      },
      success(data) {
        $("#new_transactions_form").html(data);
        setDatepickers();
        resetTransactionMenu(formId);
      }
    });
  } else {
    resetTransactionMenu(formId);
  }
}