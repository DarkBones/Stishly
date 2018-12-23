class AccountDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def form_id
    if model.is_real
      model.id
    else
      Account.get_default(User.find(model.user_id)).id
    end
  end

  def link
    if model.is_real
      URI.encode(model.name)
    else
      ""
    end
  end

end
