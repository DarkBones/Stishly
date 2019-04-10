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
    if model.persisted?
      model.id
    else
      Account.get_default(User.find(model.user_id)).id
    end
  end

  def link
    if model.persisted?
      URI.encode(model.name).sub "/", "%2F"
    else
      ""
    end
  end

  def short_name
    if model.name.length + model.balance.to_s.length > 30
      model.name[0.. 20 - model.balance.to_s.length] + "..."
    else
      model.name
    end
  end

  def balance_float
    currency = Money::Currency.new(model.currency)

    model.balance.to_f / currency.subunit_to_unit
  end

end
