class SendgridMailer < Devise::Mailer   
	helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'

  def confirmation_instructions(record, token, _opts={})
  	confirmation_url = "#{root_url}users/confirmation?confirmation_token=#{token}"
  	subs = {
  		title: "Welcome to Stishly",
  		greeting: "Hi #{record.first_name},",
  		message: "Thank you for signing up! Please confirm your email address by clicking the button below.",
  		confirm_text: "Confirm My Account",
  		token: token,
  		confirmation_url: confirmation_url,
  		message_alt: "Alternatively, you can copy and paste the following URL in your browser: #{confirmation_url}",
  	}

	  Sendgrid.send(record.email, subs, "d-46d71cf815ac42a1897b6353684fa831")
	end

	def unlock_instructions(record, token, _opts={})
		unlock_url = "#{root_url}users/unlock?unlock_token=#{token}"
		subs = {
			title: "Unlock Your Account",
			greeting: "Hi #{record.first_name},",
			message: "Your account has been locked due to an excessive number of unsuccessful sign in attempts. Click the below button to unlock your account.",
			unlock_text: "Unlock My Account",
			unlock_url: unlock_url,
			message_alt: "Alternatively, you can copy and paste the following URL in your browser: #{unlock_url}",
		}

		Sendgrid.send(record.email, subs, "d-bd7e7f16294a479e91ff0249d4a1d530")
	end

	def reset_password_instructions(record, token, _opts={})
		reset_url = "#{root_url}users/password/edit?reset_password_token=#{token}"
		subs = {
			title: "Reset Password Instructions",
			greeting: "Hi #{record.first_name},",
			message: "Someone has requested a link to change your password. If this wasn't you, please ignore this email. Click on the below button to reset your password.",
			reset_text: "Reset My Password",
			reset_url: reset_url,
			message_alt: "Alternatively, you can copy and paste the following URL in your browser: #{reset_url}",
		}

		Sendgrid.send(record.email, subs, "d-7b116614d8b34a53a1dcdb322749e74c")
	end

end