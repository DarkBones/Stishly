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

class Post < ApplicationRecord
	extend FriendlyId
  friendly_id :title, use: :slugged
	
end
