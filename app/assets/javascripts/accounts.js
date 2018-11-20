function showAccountCreationForm(){
  var x = document.getElementById("create-account-form");
  x.style.display = "block";
}

document.addEventListener("turbolinks:load", function() {

  $(".sortable-list").sortable({
    cancel: ".no-sorting",
    handle: ".sort-handle",
    delay: 150,
    update: function(e, ui) {
      Rails.ajax({
        url: $(this).data("url"),
        type: "PATCH",
        data: $(this).sortable('serialize'),
      });
    }
  });

  $(".sortable-list").disableSelection();

});