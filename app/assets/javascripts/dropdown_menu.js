$(document).on('click', '.dropdown', (event)=> {
  $(event.target).next('.dropdown__options').show();
  $(event.target).next('.dropdown__options').find('#search-categories').focus();
  event.stopPropagation();

});

$(document).on('click', '.dropdown__options li', (event)=> {
  $(event.target).closest('.dropdown__options').siblings('.dropdown__selected').html($(event.target).html());
  $(event.target).closest('.dropdown__options').hide();
  $(event.target).closest('.dropdown').next('input').val($(event.target).attr('class').split('_')[1]);
});

$(document).on('keyup', '#search-categories', (event)=> {
  SearchCategories($(event.target).closest('.dropdown__options'), $(event.target).val(), event);
});

$(document).on('click', (event) => {
  $('.dropdown__options').hide();
});

function SearchCategories($categories, text, event) {
  li = $categories.find('li')
  for (i = 0; i < li.length; i++){

    if (li[i].innerText.toUpperCase().indexOf(text.toUpperCase()) != -1) {
      li[i].style.display = "";
    } else {
      li[i].style.display = "none";
    }
  }
}