module AccountHelper
  def li_class(instance_id, account_id)
    c = "account-button clickable"

    if instance_id == 0
      c += " no-sorting"
    else
      c += " sortable"
    end
    
    c += " active" if instance_id == account_id
    return c
  end
  
end
