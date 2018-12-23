module AccountHelper
  def li_class(instance_id, account)
    c = "account-button clickable"

    if instance_id == 0
      c += " no-sorting"
    else
      c += " sortable"
    end
    
    if account
      c += " active" if instance_id == account.id
    end
    return c
  end
  
end
