require 'active_record/fixtures'

src_yml = 'test/fixtures/users.yml.noenc'
dest_yml = 'test/fixtures/users.yml'


task 'fixt' => dest_yml
#File.delete(Rails.root + dest_yml) if File.exist?(Rails.root + dest_yml)

namespace :Stishly do
	desc "generate encrypted fixture"
	file dest_yml => src_yml do |t|
		require Rails.root + "config/environment"

		encrypted_hash = {}
		for k, v in YAML.load(ERB.new(File.read(Rails.root + src_yml)).result) do
			user = User.new(v)

			encrypted_hash[k] = {}
			v.each do |key, value|
				encrypted_hash[k][key] = value unless key == "email"
			end
			encrypted_hash[k][:encrypted_email] = user.encrypted_email.strip!
			encrypted_hash[k][:encrypted_email_iv] = user.encrypted_email_iv.strip!
		end

		File.open(Rails.root + t.name, "w") do |f|
			f.write(<<EOH)
#----------------------------------------------------------------------
# DO NOT MODIFY THIS FILE!!
#
# This file is generated from #{src_yml} by:
#
#   (edit #{src_yml})
#   $ rake fixt, or
#   $ rake
#----------------------------------------------------------------------
EOH
			f.write(encrypted_hash.to_yaml)
			puts encrypted_hash.to_yaml
		end

	end
end