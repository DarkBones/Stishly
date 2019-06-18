# == Schema Information
#
# Table name: messages
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)
#  title      :string(255)
#  body       :text(65535)
#  read       :boolean          default(FALSE)
#  read_at    :datetime
#  link       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Message, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
