class AccountDecorator < Draper::Decorator
  delegate_all

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
    if model.persisted?
      if model.name.length + model.balance.to_s.length > 30
        model.name[0.. 20 - model.balance.to_s.length] + "..."
      else
        model.name
      end
    else
      I18n.t('account.all')
    end
  end

  def balance_float
    currency = Money::Currency.new(model.currency)

    model.balance.to_f / currency.subunit_to_unit
  end

end
