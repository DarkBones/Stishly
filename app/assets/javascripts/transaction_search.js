function searchTransactions(obj) {
	var $results = $(obj).next(".transaction_search_results")
	if($(obj).val().length >= 3) {
		$.ajax({
			type: "GET",
			dataType: "html",
			url: "/api/v1/transaction_search/" + $(obj).val(),
			success(data) {
				$results.html(data);

				if(data.length > 0) {
					if($results.is(":hidden")){
						$results.addClass("show");
					}
				} else {
					if($results.is(":visible")){
						$results.removeClass("show");
					}
				}
			}
		});
	} else{
		if($results.is(":visible")){
			$results.html("");
			$results.removeClass("show");
		}
	}
}

function showTransactionSearchResults(obj) {
	var $results = $(obj).next(".transaction_search_results")

	if($results.find("ul").length > 0) {
		$results.addClass("show");
	}
}

function fillTransactionDetails(obj) {
	var $root = $(obj).parents(".transactionform_root");

	$root.find(".transaction_search_results").removeClass("show");

	$.ajax({
		type: "GET",
		dataType: "json",
		url: "/api/v1/transactions/" + $(obj).attr("id"),
		success(data){

			// Description
			$root.find("#transaction_description").val(data.description);

			// Type
			if(data.transfer_account) {
				$root.find("#type-transfer").trigger("click");
			} else{
				if(data.direction < 0) {
					$root.find("#type-expense").trigger("click");
				} else {
					$root.find("#type-income").trigger("click");
				}
			}

			// Account(s)
			$root.find("#transaction_account").val(data.account.slug);
			$root.find("#transaction_from_account").val(data.account.slug);
			$root.find("#transaction_account").trigger("change");
			$root.find("#transaction_from_account").trigger("change");
			if(data.transfer_account) {
				$root.find("#transaction_to_account").val(data.transfer_account.slug);
				$root.find("#transaction_to_account").trigger("change");
			}

			// Category
			if(data.category) {
				$root.find(".category_" + data.category.id).trigger("click");
			} else {
				$root.find(".category_0").trigger("click");
			}

			// Single / multiple
			if(data.children) {
				$root.find("#multiple-multiple").trigger("click");
			} else {
				$root.find("#multiple-single").trigger("click");
			}

			// Child transactions
			if(data.children) {
				$root.find("#transaction_transactions").val("");
				var children = data.children
				var child;
				var transactions = "";
				while (children.length > 0) {
					child = children.pop();
					
					if (transactions.length > 0) {
						transactions += "\n";
					}
					transactions += child.description + " " + child.amount_f * data.direction;
				}
				$root.find("#transaction_transactions").val(transactions);
				$root.find("#transaction_transactions").trigger("keyup");
			} else {
				if(data.transfer_account) {
					$root.find("#transaction_amount").val(data.amount_f * -1);
				} else {
					$root.find("#transaction_amount").val(data.amount_f);
				}
			}

			// Currency
			if(!data.transfer_account) {
				$root.find("#transaction_currency").val(data.currency);
				$root.find("#transaction_currency").trigger("change");
			} else {
				if(data.account.currency == data.transfer_account.currency) {
					$root.find("#transfer-currencies").hide();
				} else {
					$root.find("#transfer-currencies").show();
				}
			}

		}
	});
}

$(document).on("click", (event) => {
  $(".transaction_search_results").removeClass("show");
});