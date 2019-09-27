require 'active_record/fixtures'

src_yml = 'test/fixtures/users.yml.noenc'
dest_yml = 'test/fixtures/users.yml'
cat_yml = 'test/fixtures/categories.yml'


task 'fixt' => dest_yml
#File.delete(Rails.root + dest_yml) if File.exist?(Rails.root + dest_yml)

namespace :Stishly do
	desc "generate encrypted fixture"
	file dest_yml => src_yml do |t|
		require Rails.root + "config/environment"

		encrypted_hash = {}
		for k, v in YAML.safe_load(ERB.new(File.read(Rails.root + src_yml)).result) do
			user = User.new(v)
			encrypted_hash[k] = {}

			encrypted_hash[k][:first_name_enc] = user.first_name_enc.to_msgpack
			encrypted_hash[k][:last_name_enc] = user.last_name_enc.to_msgpack

			v.each do |key, value|
				encrypted_hash[k][key] = value unless key == "email" || key.include?("_name")
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

	# CATEGORIES
	namespace :Stishly do
		desc "generate categories fixture"
		require Rails.root + "config/environment"

		def get_categories(k, template, id, user_id, categories={}, parent_id=nil)
			template.each do |key, value|
				cat_id = "#{k}_#{key}_#{id}"
				categories[cat_id] = {}

				categories[cat_id]["id"] = rand(10 ** 10)
				categories[cat_id]["user_id"] = user_id
				categories[cat_id]["name"] = value[:name]
				categories[cat_id]["symbol"] = value[:symbol]
				categories[cat_id]["color"] = value[:color] unless value[:color].nil?
				categories[cat_id]["position"] = categories.length
				categories[cat_id]["parent_id"] = parent_id unless parent_id.nil?
				categories[cat_id]["hash_id"] = SecureRandom.urlsafe_base64(6)

				id += 1

				unless value[:children].nil?
					categories = categories.merge(get_categories(k, value[:children], id, user_id, categories, categories[cat_id]["id"]))
				end

			end

			return categories
		end

		categories = {}
		template = {
			entertainment: {
				name: 'Entertainment',
				symbol: 'theater-masks',
				color: '#FBD237',
				children: {
					date: {
						name: 'Date',
						symbol: 'heart',
						children: {
							cinema: {
								name: 'Cinema',
								symbol: 'film',
							}
						}
					},
					hobbies: {
						name: 'Hobbies',
						symbol: 'palette',
					},
					holiday: {
						name: 'Holiday',
						symbol: 'suitcase-rolling',
					},
					lottery_gambling: {
						name: 'Lottery / Gambling',
						symbol: 'ticket-alt'
					},
					social: {
						name: 'Social',
						symbol: 'user-friends'
					},
					software: {
						name: 'Software',
						symbol: 'code'
					},
					sport_events: {
						name: 'Sport Events',
						symbol: 'football-ball'
					},
					subscriptions: {
						name: 'Subscriptions',
						symbol: 'money-bill-wave-alt'
					},
					tv: {
						name: 'TV',
						symbol: 'tv',
					},
					video_games: {
						name: 'Video Games',
						symbol: 'gamepad'
					}
				}
			},
			food_drinks: {
				name: 'Food & Drinks',
				symbol: 'utensils',
				color: '#F4CDC3',
				children: {
					bars_pubs: {
						name: 'Bars / Pubs',
						symbol: 'glass-cheers'
					},
					fast_food: {
						name: 'Fast Food',
						symbol: 'hamburger'
					},
					groceries: {
						name: 'Groceries',
						symbol: 'shopping-basket'
					},
					order_takeout: {
						name: 'Order / Take-out',
						symbol: 'pizza-slice'
					},
					restaurant: {
						name: 'Restaurant',
						symbol: 'concierge-bell'
					}
				}
			},
			health: {
				name: 'Health',
				symbol: 'heartbeat',
				color: '#D7AE91',
			},
			household: {
				name: 'Household',
				symbol: 'home',
				color: '#86D7E1',
			},
			income: {
				name: 'Income',
				symbol: 'coins',
				color: '#7CB436',
			},
			investments: {
				name: 'Investments',
				symbol: 'file-invoice-dollar',
				color: '#FF470E',
			},
			other: {
				name: 'Other',
				symbol: 'ellipsis-h',
				color: '#4588A5',
			},
			shopping: {
				name: 'Shopping',
				symbol: 'shopping-bag',
				color: '#4588A5',
			},
			transport: {
				name: 'Transport',
				symbol: 'shuttle-van',
				color: '#567243',
			},
			vehicle: {
				name: 'Vehicle',
				symbol: 'cog',
				color: '#004C8F',
			}
		}

		for k, v in YAML.safe_load(ERB.new(File.read(Rails.root + src_yml)).result) do
			id = categories.length + 1
			categories = categories.merge(get_categories(k, template, id, v["id"]))
		end
		
		File.open(Rails.root + cat_yml, "w") do |f|
			f.write(<<EOH)
#----------------------------------------------------------------------
# DO NOT MODIFY THIS FILE!!
#----------------------------------------------------------------------
EOH
			f.write(categories.to_yaml)
		end

	end

end