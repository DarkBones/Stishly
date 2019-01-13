$(document).on('turbolinks:load', ()=> {

  $('.dropdown').on('click', (event) => {
    $(event.target).next('.dropdown__options').toggle();
  });

  $('.dropdown__options li').on('click', (event) => {
    $(event.target).closest('.dropdown__options').siblings('.dropdown__selected').html($(event.target).html());
    $(event.target).closest('.dropdown__options').hide();
    $(event.target).closest('.dropdown').next('input').val($(event.target).attr('class').split('_')[1]);
  });

});