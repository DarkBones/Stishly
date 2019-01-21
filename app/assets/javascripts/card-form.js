$(document).on('turbolinks:load', ()=> {

  $('.card-form__close').on('click', (event) => {
    ToggleCardForm('#' + $(event.target).closest('.card-form').attr('id'));
  });

});

function ToggleCardForm (formId) {
  $('#overlay').fadeToggle(200);
  $(formId).slideToggle(100);
}