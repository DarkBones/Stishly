var userCurrencyChanged = false;

function changeUserCountry(val) {
  if (!userCurrencyChanged) {
    $.ajax({
      type: "GET",
      dataType: "text",
      url: "/api/country_currency/" + val,
      success(data) {
        $("#new_user #user_currency").val(data);
      }
    });
  }
}

function changeUserCurrency(val) {
  userCurrencyChanged = true;
}

