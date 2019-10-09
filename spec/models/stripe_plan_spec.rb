# == Schema Information
#
# Table name: stripe_plans
#
#  id                     :bigint           not null, primary key
#  currency               :string(255)
#  price_eur              :integer
#  price_month            :integer
#  price_year             :integer
#  plan_id_month          :string(255)
#  plan_id_year           :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  plan_id_month_no_trial :string(255)
#  plan_id_year_no_trial  :string(255)
#

require 'rails_helper'

RSpec.describe StripePlan, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
