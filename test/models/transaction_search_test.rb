require 'test_helper'

class TransactionSearchTest < ActiveSupport::TestCase
  test "search by nothing" do
    current_user = users(:transaction_search)
    search_query = {}

    transactions = Transaction.search(current_user, search_query)

    assert transactions.length >= 203, format_error("Unexpected search result count", ">= 203", transactions.length)
  end

  test "search by description" do
    current_user = users(:transaction_search)
    search_query = {
      description: "one"
    }

    transactions = Transaction.search(current_user, search_query)

    assert transactions.length == 110, format_error("Unexpected search result count", 109, transactions.length)
  end

  test "search by description exact" do
    current_user = users(:transaction_search)
    search_query = {
      description: "one",
      exact: true
    }

    transactions = Transaction.search(current_user, search_query)

    assert transactions.length == 1, format_error("Unexpected search result count", 1, transactions.length)
  end

  test "search by description case insensitive" do
    current_user = users(:transaction_search)
    search_query = {
      description: "two hundred and one"
    }

    transactions = Transaction.search(current_user, search_query)
    assert transactions.length == 1, format_error("Unexpected search result count", 1, transactions.length)

    search_query = {
      description: "two hundred and one",
      case_sensitive: true
    }

    transactions = Transaction.search(current_user, search_query)
    assert transactions.length == 0, format_error("Unexpected search result count", 0, transactions.length)

    current_user = users(:transaction_search)
    search_query = {
      description: "Two Hundred And One"
    }

    transactions = Transaction.search(current_user, search_query)
    assert transactions.length == 1, format_error("Unexpected search result count", 1, transactions.length)
  end

  test "search by currency" do
    current_user = users(:transaction_search)
    search_query = {
      currency: "JPY"
    }

    transactions = Transaction.search(current_user, search_query)
    assert transactions.length == 1, format_error("Unexpected search result count", 1, transactions.length)
  end

  test "search by excluding currency" do
    current_user = users(:transaction_search)
    search_query = {
      exclude_currency: "EUR"
    }

    transactions = Transaction.search(current_user, search_query)
    assert transactions.length == 1, format_error("Unexpected search result count", 1, transactions.length)

    search_query = {
      exclude_currency: "JPY"
    }

    transactions = Transaction.search(current_user, search_query)
    assert transactions.length >= 203, format_error("Unexpected search result count", ">= 203", transactions.length)
  end

  test "search by currency and description" do
    current_user = users(:transaction_search)
    search_query = {
      description: "two hundred and two",
      currency: "JPY"
    }

    transactions = Transaction.search(current_user, search_query)
    assert transactions.length == 1, format_error("Unexpected search result count", 1, transactions.length)
  end

  test "search by currency and exact description" do
    current_user = users(:transaction_search)
    search_query = {
      description: "two hundred and two",
      currency: "JPY",
      exact: true
    }

    transactions = Transaction.search(current_user, search_query)
    assert transactions.length == 0, format_error("Unexpected search result count", 0, transactions.length)

    search_query = {
      description: "two hundred and two JPY",
      currency: "JPY",
      exact: true
    }

    transactions = Transaction.search(current_user, search_query)
    assert transactions.length == 1, format_error("Unexpected search result count", 1, transactions.length)
  end

  test "search by category" do
    current_user = users(:transaction_search)
    search_query = {
      category: 85
    }

    transactions = Transaction.search(current_user, search_query)
    assert transactions.length == 1, format_error("Unexpected search result count", 1, transactions.length)
  end

  test "search by from date" do
    current_user = users(:transaction_search)
    search_query = {
      from_date: (Time.now - 5.months).strftime("%d-%b-%Y")
    }

    transactions = Transaction.search(current_user, search_query)
    assert transactions.length == 9, format_error("Unexpected search result count", 9, transactions.length)
  end

  test "search by to date" do
    current_user = users(:transaction_search)
    search_query = {
      to_date: (Time.now - 5.months).strftime("%d-%b-%Y")
    }

    all_transactions = Transaction.search(current_user, {})
    transactions = Transaction.search(current_user, search_query)
    assert transactions.length >= 194 && transactions.length < all_transactions.length, format_error("Unexpected search result count", ">= 194 && < #{all_transactions.length}", transactions.length)
  end

  test "search by account" do
    current_user = users(:transaction_search)
    search_query = {
      account: "Savings account"
    }

    transactions = Transaction.search(current_user, search_query)
    assert transactions.length == 10, format_error("Unexpected search result count", 10, transactions.length)
  end

  test "search by from amount" do
    current_user = users(:transaction_search)
    search_query = {
      from_amount: 199.92
    }

    transactions = Transaction.search(current_user, search_query)
    assert transactions.length == 7, format_error("Unexpected search result count", 7, transactions.length)
  end

  test "search by to amount" do
    current_user = users(:transaction_search)
    search_query = {
      to_amount: 15
    }

    transactions = Transaction.search(current_user, search_query)
    assert transactions.length == 15, format_error("Unexpected search result count", 15, transactions.length)
  end

end
