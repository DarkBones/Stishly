# == Schema Information
#
# Table name: posts
#
#  id           :bigint           not null, primary key
#  title        :string(255)
#  body         :text(65535)
#  thumbnail    :string(255)
#  published_on :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  slug         :string(255)
#  tags         :string(255)
#

require 'rails_helper'

RSpec.describe Post, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
