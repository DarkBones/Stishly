# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  first_name_enc         :binary(65535)
#  last_name_enc          :binary(65535)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  timezone               :string(255)      default("Europe/London")
#  country_code           :string(255)
#  country_id             :bigint
#  currency               :string(255)      default("USD")
#  finished_setup         :boolean          default(FALSE)
#  encrypted_email        :string(255)
#  encrypted_email_iv     :string(255)
#  email_bidx             :string(255)
#  provider               :string(255)
#  uid                    :string(255)
#  hash_id                :string(255)
#  subscription           :string(255)      default("free")
#  stripe_id              :string(255)
#  free_trial_eligable    :boolean          default(TRUE)
#  last_plan_check        :datetime
#  is_admin               :boolean          default(FALSE)
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "Get currency" do
    current_user = users(:bas)

    currency = User.get_currency(current_user)
    assert currency.is_a?(Money::Currency), format_error('Unexpected currency class', 'Money::Currency', currency.class.name)
  end
end
