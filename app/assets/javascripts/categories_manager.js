$(document).on("turbolinks:load", () => {
	$("#categories_list li").click(function(event){
	  event.stopPropagation();

	  var id = $(event.target).attr("id");
	  if (typeof(id) === "undefined") {
	  	return false;
	  }

	  id = id.split(/_(.+)/)[1];
	  
	  if ($(event.target).parents("li").find("span#category_" + id).is(":visible")){
		  $.ajax({
		  	type: "GET",
		  	dataType: "html",
		  	url: "/api/v1/forms/edit_category/" + id,
		  	success(data) {
		  		$(event.target).parents("li").find("span#category_" + id).hide();
		  		$(event.target).parents("li").find("span#edit_category_" + id).show();
		  		$(event.target).parents("li").find("span#edit_category_" + id).html(data);
		  	}
		  });
	  }
	});
});

// close the symbols dropdown when clicking outside of it
$(document).mouseup(function(e) {
  var $container = $(".dropdown-menu-symbols");

  if($container.is(":hidden")) {
    return false;
  } else if (typeof($(e.target).parents(".dropdown-menu-symbols").attr("class")) === "undefined") {
  	$container.hide();
  }
});

// search symbols
function searchCategorySymbol(obj) {
	var text = $(obj).val().replace(/[^a-z0-9]/gi,"");
	var symbLength, symbPos, symb, name;
	var symbArr = $(obj).parents(".dropdown-menu-symbols").find(".category_symbol").toArray();

	symbLength = symbArr.length;
	symbPos = 0;

	while (symbPos < symbLength) {
    symb = $(symbArr.pop());

    name = $(symb).attr("name").replace(/[^a-z0-9]/gi,"");
    
    if(name.toUpperCase().indexOf(text.toUpperCase()) === -1) {
    	$(symb).hide();
    } else {
    	$(symb).show();
    }

    symbPos += 1;
  }
}

function selectCategorySymbol(obj) {
	$("#category_symbol").val($(obj).attr("name"));
	$("button#dropdownMenuSymbols").html($(obj).find(".symbol").html());
	$(".dropdown-menu-symbols").hide();
}