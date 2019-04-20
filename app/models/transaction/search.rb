=begin
class Transaction
  class Search
    
    def initialize(current_user, query)
      @current_user = current_user
      @query = prepare_query(query)
    end

    def perform
      where = construct_where

      #puts "WHERE #{where}, (#{values})"
      #puts @current_user.transactions.where(where, get_description_value, get_currency_value, get_exclude_currency_value, get_category_value, get_from_date_value, get_to_date_value).to_sql
      return @current_user.transactions.where(
        where, 
        get_description_value, 
        get_currency_value, 
        get_exclude_currency_value, 
        get_category_value, 
        get_from_date_value, 
        get_to_date_value, 
        get_account_value,
        get_from_amount_value,
        get_to_amount_value
        )
    end

private
    
    # ensures all expected query values are there
    def prepare_query(query)
      query[:description] = "" if query[:description].nil?
      query[:description].strip!
      query[:currency] = "" if query[:currency].nil?
      query[:exclude_currency] = "" if query[:exclude_currency].nil?
      query[:category] = -1 if query[:category].nil?
      query[:from_date] = "01-Jan-1970" if query[:from_date].nil?
      query[:to_date] = "31-12-9999" if query[:to_date].nil?
      query[:account] = "" if query[:account].nil?
      query[:from_amount] = "null" if query[:from_amount].nil?
      query[:to_amount] = "null" if query[:to_amount].nil?
      query[:abs_amount] = true if query[:abs_amount].nil?

      return query
    end
    
    # constructs the WHERE clause of the search query
    def construct_where

      description = get_description
      currency = get_currency
      exclude_currency = get_exclude_currency
      category = get_category
      from_date = get_from_date
      to_date = get_to_date
      account = get_account
      from_amount = get_from_amount
      to_amount = get_to_amount

      clauses = []
      clauses.push(description)
      clauses.push(currency)
      clauses.push(exclude_currency)
      clauses.push(category)
      clauses.push(from_date)
      clauses.push(to_date)
      clauses.push(account)
      clauses.push(from_amount)
      clauses.push(to_amount)

      where = clauses.join(" AND ")

      return where
    end

    def get_to_amount
      return "ABS(transactions.user_currency_amount) > ?" if @query[:to_amount] == "null"

      clause = ""
      clause += "ABS(" if @query[:abs_amount]
      clause += "transactions.user_currency_amount"
      clause += ")" if @query[:abs_amount]
      clause += " <= ?"

      return clause
    end

    def get_to_amount_value
      return -1 if @query[:to_amount] == "null"

      amount = @query[:to_amount].to_f

      user_currency = Money::Currency.new(@current_user.currency)
      amount *= user_currency.subunit_to_unit

      amount = amount.abs if @query[:abs_amount]

      return amount
    end

    def get_from_amount
      return "ABS(transactions.user_currency_amount) > ?" if @query[:from_amount] == "null"

      clause = ""
      clause += "ABS(" if @query[:abs_amount]
      clause += "transactions.user_currency_amount"
      clause += ")" if @query[:abs_amount]
      clause += " >= ?"

      return clause
    end

    def get_from_amount_value
      return -1 if @query[:from_amount] == "null"

      amount = @query[:from_amount].to_f

      user_currency = Money::Currency.new(@current_user.currency)
      amount *= user_currency.subunit_to_unit

      amount = amount.abs if @query[:abs_amount]

      return amount
    end

    def get_account
      return "transactions.account_id like ?" if @query[:account].length == 0

      return "transactions.account_id = ?"
    end

    def get_account_value
      return "%" if @query[:account].length == 0

      return Account.get_from_name(@query[:account], @current_user).id
    end

    def get_to_date
      return "DATE(transactions.local_datetime) <= DATE(?)"
    end

    def get_to_date_value
      return @query[:to_date].to_date.strftime("%Y-%m-%d")
    end

    def get_from_date
      return "DATE(transactions.local_datetime) >= DATE(?)"
    end

    def get_from_date_value
      return "0" if @query[:from_date] == 0

      return @query[:from_date].to_date.strftime("%Y-%m-%d")
    end

    def get_category
      return "transactions.category_id > ?" if @query[:category] < 0

      return "transactions.category_id = ?"
    end

    def get_category_value
      return @query[:category]
    end

    def get_currency
      return "transactions.currency like ?" if @query[:currency].length == 0

      return "transactions.currency = ?"
    end

    def get_currency_value
      return "%" if @query[:currency].length == 0

      return @query[:currency]
    end

    def get_exclude_currency
      return "transactions.currency like ?" if @query[:exclude_currency].length == 0

      return "transactions.currency != ?"
    end

    def get_exclude_currency_value
      return "%" if @query[:exclude_currency].length == 0

      return @query[:exclude_currency]
    end

    def get_description
      return "transactions.description like ?" if @query[:description].length == 0

      clause = ""
      clause = "UPPER(" unless @query[:case_sensitive] == true
      clause += "transactions.description"
      clause += ")" unless @query[:case_sensitive] == true

      if @query[:exact] == true
        clause += " ="
      else
        clause += " like"
      end

      clause += " binary ?"
      return clause
    end

    def get_description_value
      return "%" if @query[:description].length == 0

      description = @query[:description]
      description.upcase! unless @query[:case_sensitive] == true

      description = "%#{description}%" if description.length > 0 && @query[:exact] != true

      return description
    end

  end
end
=end
