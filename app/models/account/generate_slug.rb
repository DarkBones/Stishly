class Account
	class GenerateSlug

		def initialize(user, name)
			@user = user
			@name = name
		end

		def perform
			original_slug = @name.parameterize
      slug = original_slug

      account = @user.accounts.where(slug: slug).take
      n = 1
      until account.nil?
        slug = "#{original_slug}-#{n}"
        account = @user.accounts.where(slug: slug).take
        n += 1
      end

      return slug
		end

	end
end