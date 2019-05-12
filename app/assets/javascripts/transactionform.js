function getFormId(obj) {
  return "#" + $(obj).parents(".transactionform").attr("id");
}

function changeTransactionType(type, obj, formId=null) {
  if (formId == null){
    var formId = getFormId(obj)
  }

  switch(type) {
    case "transfer":
      $(formId + " #single-account").hide();
      $(formId + " #categories").hide();
      $(formId + " #transfer-account").show();
      $(formId + " #type").removeClass("bg-danger");
      $(formId + " #type").addClass("bg-warning");
      $(formId + " #type").removeClass("bg-success");
      $(formId + ' #transaction-currency-options').hide();
      $(formId + " #transaction_type_transfer").prop("checked", true);
      break;
    case "income":
      $(formId + " #single-account").show();
      $(formId + " #categories").show();
      $(formId + " #transfer-account").hide();
      $(formId + " #type").removeClass("bg-danger");
      $(formId + " #type").removeClass("bg-warning");
      $(formId + " #type").addClass("bg-success");
      $(formId + ' #transaction-currency-options').show();
      $(formId + " #transaction_type_income").prop("checked", true);
      break;
    default:
      $(formId + " #single-account").show();
      $(formId + " #categories").show();
      $(formId + " #transfer-account").hide();
      $(formId + " #type").addClass("bg-danger");
      $(formId + " #type").removeClass("bg-warning");
      $(formId + " #type").removeClass("bg-success");
      $(formId + ' #transaction-currency-options').show();
      $(formId + " #transaction_type_expense").prop("checked", true);
  }

  showTransferCurrencyRates(formId, type);
}

function changeTransactionMultiple(type, obj){
  var formId = getFormId(obj)
  switch (type) {
    case "single":
      $(formId + " #amount").show();
      $(formId + " #transactions").hide();
      break;
    default:
      $(formId + " #amount").hide();
      $(formId + " #transactions").show();
  }
}

function updateTransactionResult(formId) {
  var type, multipleTransactions, rate, amount, $accountTarget, $rateTarget, $resultTarget, $amountTarget;

  rate = 1;
  amount = 0;
  $rateTarget = $(formId + " #transaction_rate");
  $resultTarget = $(formId + " #transaction_account_currency");
  $amountTarget = $(formId + " #transaction_amount");
  type = getTransactionType(formId);
  multipleTransactions = isTransactionMultiple(formId);

  if (multipleTransactions) {
    $amountTarget = $(formId + " #transaction_transactions");
  }

  if (type === "transfer") {
    $rateTarget = $(formId + " #transaction_rate_from_to");
    $resultTarget = $(formId + " #transaction_to_account_currency");
    $accountTarget = $(formId + " #transaction_to_account");
  } else {
    $accountTarget = $(formId + " #transaction_account");
  }

  if ($resultTarget.is(":visible")) {
    rate = $rateTarget.val();
    if (multipleTransactions) {
      amount = getTransactionTotalFromMultiple(formId);
    } else {
      amount = $amountTarget.val();
    }
  }

  $.ajax({
    type: "GET",
    dataType: "json",
    url: "/api/account_currency_details/" + encodeURI($accountTarget.val()),
    success(data) {
      result = Math.round((amount * rate) * data.subunit_to_unit) / data.subunit_to_unit
      $resultTarget.val(result);

      if (multipleTransactions){
        updateTransactionsTotal(formId);
      }
    }
  });

  if (multipleTransactions) {
    updateTransactionsTotal(formId);
  }
}


function updateTransactionRate(obj) {
  var $rateTarget, $resultTarget, isMultiple, $amountTarget, result, amount, rate;

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

function changeTransactionAccount(obj) {
  var formId, account, transactionType;
  
  formId = getFormId(obj)
  account = $(obj).val();
  transactionType = getTransactionType(formId);

  if ($(obj).attr("id") !== "transaction_to_account") {
    $(formId + " #transaction_account").val(account);
    $(formId + " #transaction_from_account").val(account);
  }

  if (transactionType !== "transfer") {
    if ($(formId + " #transaction_currency").hasClass("changed") === false) {
      $.ajax({
        type: "GET",
        dataType: "text",
        url: "/api/account_currency/" + encodeURI(account),
        success(data) {
          $(formId + " #transaction_currency").val(data);
        }
      });
    }
    changeTransactionCurrency($(formId + " #transaction_currency"), false, false);
  }

  showTransferCurrencyRates(formId);
}

function updateTransactionsTotal(formId) {
  var currency, total, $targetTotal, $targetTransactions, $targetCurrency;

  $targetTotal = $(formId + " #transactions-total");
  $targetTransactions = $(formId + " #transaction_transactions");
  $targetCurrency = $(formId + " #transaction_currency");

  total = getTransactionTotalFromMultiple(formId);

  if(typeof(total) === "undefined") {
    return;
  }

  total = total.toString().replace(".", "$");
  currency = $targetCurrency.val();

  $.ajax({
    type: "GET",
    dataType: "text",
    url: "/api/format_currency/" + total + "/" + currency + "/true",
    success(data) {
      $targetTotal.text(data);
    }
  });
}

function getTransactionTotalFromMultiple(formId) {
  var test, lines, total, words, i, $target;
  total = 0;

  $target = $(formId + " #transaction_transactions");

  text = $target.val();
  lines = text.split("\n");

  for (i=0; i<lines.length; i++) {
    if (lines[i].length > 0) {
      words = lines[i].split(" ");
      if (words.length > 0) {
        if (!isNaN(words[words.length - 1]) && words[words.length - 1].length > 0) {
          total += parseFloat(words[words.length - 1]);
        }
      }
    }
  }

  return total;
}

function changeTransactionToAccount(obj) {
  var formId = getFormId(obj)
  showTransferCurrencyRates(formId);
}

function changeTransactionCurrency(obj, ignore=false, lockCurrency=true){
  // return if the form only uses base transaction fields
  if (ignore) {
    return;
  }

  var formId, result, currency, account

  console.log(lockCurrency);
  if(lockCurrency){
    $(obj).addClass("changed");
  }

  formId = getFormId(obj);
  result = 0;

  $(formId + " #currency-rate").hide();
  $(formId + " #currency-result").hide();

  currency = $(formId + " #transaction_currency").val();

  account = $(formId + " #single-account select").val();

  $.ajax({
    type: "GET",
    dataType: "json",
    url: "/api/account_currency_details/" + encodeURI(account),
    success: function(data_currency) {
      if (data_currency.iso_code != currency){
        $(formId + " #exchange_rate_spinner").show();
        $.ajax({
          type: "GET",
          dataType: "text",
          url: "/api/currency_rate/" + currency + "/" + data_currency.iso_code,
          success: function(data_rate) {
            $(formId + ' #exchange_rate_spinner').hide();
            $(formId + ' #account_currency').text('Amount in ' + data_currency.iso_code);
            $(formId + ' #currency-rate').show();
            $(formId + ' #currency-result').show();
            $(formId + ' #currency-rate input').val(data_rate);

            if ($(formId + ' #amount').is(":visible")){
              result = $('#transactionform #amount input').val() * data_rate;
            } else{
              result = getTransactionTotalFromMultiple(formId) * data_rate;
            }

            $(formId + ' #currency-result input').val(Math.round(result * data_currency.subunit_to_unit) / data_currency.subunit_to_unit);
          }
        });

      } else {
        $(formId + ' #currency-rate').hide();
        $(formId + ' #currency-result').hide();
        $(formId + ' #currency-rate input').val('');
        $(formId + ' #currency-result input').val('');
      }
    }
  });
  updateTransactionsTotal(formId);
  updateTransactionResult(formId);
}

// handles whether the transfer currency rates should be shown
function showTransferCurrencyRates(formId, type=null) {
  var from, to;

  if (type == null) {
    type = getTransactionType(formId);
  }

  if (type === "transfer") {
    $(formId + " #transfer-currency-options").hide();
    
    from = encodeURI($(formId + " #transaction_from_account").val());
    to = encodeURI($(formId + " #transaction_to_account").val());

    $.ajax({
      type: "GET",
      dataType: "json",
      url: "/api/transfer_accounts/" + from + "/" + to,
      success: function(data) {
        if (data.from_account.currency !== data.to_account.currency){
          $(formId + " #to_account_currency").text('Amount in ' + data.to_account.currency);
          $(formId + " #transfer-currencies").show();
          $(formId + " #rate_from_to").text('Rate ' + data.from_account.currency + ' to ' + data.to_account.currency);
          $(formId + " #transaction_rate_from_to").val(data.currency_rate);
        } else {
          $(formId + " #transaction_rate_from_to").val(data.currency_rate);
          $(formId + " #transfer-currencies").hide();
        }

        updateTransactionResult(formId);
      }
    });
  } else {
    $(formId + " #transaction_rate_from_to").val(1);
    $(formId + " #transaction-currencies").hide();
    $(formId + " #transfer-currencies").hide();
    $(formId + " #transaction-currency-options").show();
  }

  updateTransactionResult(formId);
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

// returns true if there are multiple transactions
function isTransactionMultiple(formId) {
  if ($(formId + " #multiple_multiple").hasClass("active")) {
    return true;
  } else {
    return false;
  }
}

function resetTransactionMenu(formId){
  setTimeout(function(){ 
    $('#transactionform #transaction_description').trigger('focus');
  }, 500);

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
}

function resetAccountOptions(formId) {
  activeAccount = getActiveAccountName();
  if (activeAccount) {
    $(formId + "#transaction_account").val(activeAccount);
    $(formId + " #transaction_from_account").val(activeAccount);
  } else {
    $(formId + " #transaction_account").val($(formId + " #transaction_account option:first").val());
    $(formId + " #transaction_from_account").val($(formId + " #transaction_from_account option:first").val());
  }
  $(formId + " #transaction_to_account").val($(formId + " #transaction_to_account option:first").val());
}

function resetButtonGroups(formId) {
  $(formId + " #button-group").each(function(index){
    $(this).find("input").each(function(i){
      $(this).prop("checked", i==0);
    });
    $(this).find("label").each(function(i){
      if(i == 0){
        $(this).addClass("active");
      } else {
        $(this).removeClass("active");
      }
    });
  });
}

function resetTextInputs(formId) {
  $(formId + " input.form-control, " + formId + " textarea.form-control").each(function(index){
    $(this).val("");
  });
}

function resetDateAndTime(formId) {
  $(formId + " #transaction_date").val(getDate());
  $(formId + " #transaction_time").val(getTime());
}

function resetAccountAndCurrencyDropdowns(formId) {
  var account;

  account = getActiveAccountName();
  if (account == null) {
    account = $(formId + " #transaction_account").find("option:first").val();
  }

  $(formId + " #transaction_account").val(account);
  $(formId + " #transaction_from_account").val(account);

  $.ajax({
    type: "GET",
    dataType: "text",
    url: "/api/account_currency/" + encodeURI(account),
    success(data) {
      $(formId + " #transaction_currency").val(data);
    }
  });
}

function resetCategoryDropdown(formId) {
  $(formId + " #transaction_category_id").val(0);
  optionHtml = $(formId + " [id^=categoriesDropdownOptions]").find("li").first().html();
  $(formId + " button#categories-dropdown").html(optionHtml);
}