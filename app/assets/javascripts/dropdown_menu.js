$(document).on('turbolinks:load', ()=> {

  $('.dropdown').on('click', (event) => {
    $(event.target).next('.dropdown__options').toggle();
    $(event.target).next('.dropdown__options').find('#search-categories').focus();
  });

  $('.dropdown__options li').on('click', (event) => {
    $(event.target).closest('.dropdown__options').siblings('.dropdown__selected').html($(event.target).html());
    $(event.target).closest('.dropdown__options').hide();
    $(event.target).closest('.dropdown').next('input').val($(event.target).attr('class').split('_')[1]);
  });

  $('#search-categories').on('keyup', (event) => {
    SearchCategories($(event.target).closest('.dropdown__options'), $(event.target).val(), event);
  });

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