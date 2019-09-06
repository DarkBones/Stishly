module Friendlyable
	extend ActiveSupport::Concern

	included do
		extend ::FriendlyId
		before_create :set_hash_id
		friendly_id :hash_id
	end

	def set_hash_id
		hash_id = nil
		loop do
			hash_id = SecureRandom.urlsafe_base64(6)#.gsub('_','+')
			break unless self.class.name.constantize.where(:hash_id => hash_id).exists?
		end

		self.hash_id = hash_id
	end

end
