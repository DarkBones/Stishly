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

      return d + "-" + month[mm] + "-" + y;
    }
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
    }

    window.setTimezones = function() {
      $("#timezone_input").each(function(){
        $(this).setTimezone();
      });
    }

    // update the account title balance
    window.updateAccountTitleBalance = function() {
      var activeAccount = getActiveAccountName();
      var url = "/api/v1/render/account_title_balance";
      if (activeAccount !== null) {
        url += "/" + activeAccount.toString();
      }

      $.ajax({
        type: "GET",
        dataType: "json",
        url: url,
        success(data) {
          $("#account-title-balance").text(data.html);
          $("#editAccountBalance #account_balance").val(data.float);
        }
      });
    }

    // modified serialize function to handle hashed ids
    window.serializeHashed = function($container) {
      var str = "";
      var els = $container.find(".sortable")

      var el;
      $container.find(".sortable").each(function(){
        el = $(this).attr("id").split(/_(.+)/);
        if (str !== "") str = str + "&"
        str = str + el[0] + "[]=" + el[1];
      });

      return str
    }


  });

//});
