//$(document).on("turbolinks:load", () => {

  $(function() {
    
    window.UpdateLeftMenu = function() {
      $.ajax({
        type: "GET",
        dataType: "html",
        url: "/api/v1/render/left_menu",
        success(data) {

          $("#page-left-menu").html(data);
        }
      });
    };

    window.UpdateDailyBudget = function() {
      $.ajax({
        type: "GET",
        dataType: "json",
        url: "/api/v1/render/daily_budget",
        success(data) {
          $("#navbar-daily-budget").html(data.navbar);
          $("#left-menu-daily-budget").html(data.left_menu);
        }
      })
    }

    // gets the currently active account by checking the URL of the current page
    window.getActiveAccountName = function (){
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
    };

    // GET DATE AND TIME
    window.getDate = function () {
      var dt = new Date();
      var h = dt.getHours();
      var m = dt.getMinutes();
      var d = dt.getDate();
      var mm = dt.getMonth();
      var y = dt.getYear() + 1900;
      if(h < 10) {h = "0" + h;}
      if(m < 10) {m = "0" + m;}
      if(d < 10) {d = "0" + d;}

      var month = new Array();
      month[0] = "Jan";
      month[1] = "Feb";
      month[2] = "Mar";
      month[3] = "Apr";
      month[4] = "May";
      month[5] = "Jun";
      month[6] = "Jul";
      month[7] = "Aug";
      month[8] = "Sep";
      month[9] = "Oct";
      month[10] = "Nov";
      month[11] = "Dec";

      return d + "-" + month[parseInt(mm, 10)] + "-" + y;
    };

    window.getTime = function () {
      var dt = new Date();
      var h = dt.getHours();
      var m = dt.getMinutes();
      var d = dt.getDate();
      var mm = dt.getMonth();
      var y = dt.getYear() + 1900;
      if(h < 10) {h = "0" + h;}
      if(m < 10) {m = "0" + m;}
      if(d < 10) {d = "0" + d;}

      return h + ":" + m;
    };

    window.setTimezones = function() {
      $("#timezone_input").each(function(){
        $(this).setTimezone();
      });
    };

    // update the account title balance
    window.updateAccountTitleBalance = function() {
      var activeAccount = getActiveAccountName();
      var apiUrl = "/api/v1/render/account_title_balance";
      if (activeAccount !== null) {
        apiUrl += "/" + activeAccount.toString();
      }

      $.ajax({
        type: "GET",
        dataType: "json",
        url: apiUrl,
        success(data) {
          $("#account-title-balance").text(data.html);
          $("#editAccountBalance #account_balance").val(data.float);
        }
      });
    };

    // modified serialize function to handle hashed ids
    window.serializeHashed = function($container) {
      var str = "";
      var els = $container.find(".sortable");

      var el;
      $container.find(".sortable").each(function(){
        el = $(this).attr("id").split(/_(.+)/);
        if (str !== "") { str = str + "&"; }
        str = str + el[0] + "[]=" + el[1];
      });

      console.log(str);

      return str;
    };

    window.serializeHashedNested = function($container) {
      var result = "";
      var parentId = "";
      var el;

      $container.find(".sortable").each(function() {
        if ($(this).parents(".sortable").length === 0) {
          parentId = "root";
        } else {
          parentId = $(this).parents(".sortable").attr("id").split(/_(.+)/)[1];
        }
        if (result !== "") { result += "&"; }
        el = $(this).attr("id").split(/_(.+)/);

        result += el[0] + "[]=" + el[1] + "." + parentId;
      });

      return result;
    };

    // sets the category colors on the categories page
    window.setCategoryColors = function($target) {
      var color = "";
      var c;

      $target.find(".sortable").each(function() {
        if(typeof($(this).attr("color")) === "undefined") {
          c = $(this).parents("li[color]").attr("color");
          if (typeof(c) === "undefined") {
            color = "#808080";
          } else {
            color = c;
          }

        } else {
          color = $(this).attr("color");
        }
        $(this).find(".rounded-circle").css("background-color", color + ";");
      });
    }


  });

//});
