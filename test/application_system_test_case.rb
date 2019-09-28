require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Devise::Controllers::Helpers

  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  def login_user(user, password)
    visit root_path

    all('a', :text => 'Sign in')[0].click

    fill_in "Email", with: user.unconfirmed_email
    fill_in "Password", with: password

    #page.execute_script("$('input[name=\"commit\"]').click()")
    #page.execute_script("$('input[type=\"submit\"]').click()")
    find('button[type="submit"]').click
  end

  def login_as_blank
    user = users(:new)
    password = "SomePassword123^!"

    login_user(user, password)
  end

  def login_as_blank_free
    user = users(:new_free)
    password = "SomePassword123^!"

    login_user(user, password)
  end

  def logout
    sleep 2
    page.find(".navbar-gear").click
    click_on "Sign out"
  end

  def create_transaction(params)
    fill_form_transaction(params)
    click_on I18n.t('buttons.create_transaction.text')
    sleep 1
  end

  def fill_form_transaction(params)
    # click on new transaction
    click_on I18n.t('buttons.new_transaction.text')

    # select the transaction type
    find("#transactionform #type-#{params[:type]}").click unless params[:type].nil?

    # fill in the description
    find('#transactionform #transaction_description').set(params[:description]) unless params[:description].nil?

    # select the account(s)
    find('#transactionform #transaction_account').find(:option, params[:account]).select_option unless params[:account].nil?
    find('#transactionform #transaction_from_account').find(:option, params[:from_account]).select_option unless params[:from_account].nil?
    find('#transactionform #transaction_to_account').find(:option, params[:to_account]).select_option unless params[:to_account].nil?

    # select currency
    find('#transactionform #transaction_currency').find(:option, params[:currency]).select_option unless params[:currency].nil?

    # select category
    unless params[:category].nil?
      category = Category.where(user_id: 8, name: params[:category]).take
      find('#transactionform #categories-dropdown').click
      find(".category_#{category.hash_id}").click
    end

    # select multiple / single
    find("#transactionform #multiple-#{params[:multiple]}").click unless params[:multiple].nil?

    # fill in the amount
    find('#transactionform #transaction_amount').set(params[:amount]) unless params[:amount].nil?

    # fill in the transactions
    find('#transactionform #transaction_transactions').set(params[:transactions]) unless params[:transactions].nil?

    # fill in the date and time
    find('#transactionform #transaction_date').set(params[:date]) unless params[:date].nil?
    find('#transactionform #transaction_time').set(params[:time]) unless params[:time].nil?
  end

  def start_transaction
    login_user(users(:transactions), 'SomePassword123^!')
    visit '/accounts'
  end

end
