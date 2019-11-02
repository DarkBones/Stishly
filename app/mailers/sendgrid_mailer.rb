class SendgridMailer < Devise::Mailer   
	helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'

  def confirmation_instructions(record, token, _opts={})
  	subs = {
  		title: "Welcome to Stishly",
  		greeting: "Hi #{record.first_name},",
  		message: "Thank you for signing up! Please confirm your email address by clicking the button below.",
  		confirmText: "Confirm My Account",
  		token: token,
  		confirmationUrl: "#{root_url}users/confirmation?confirmation_token=#{token}",
  	}
	  #Sendgrid.send(record.email, subs, "d-46d71cf815ac42a1897b6353684fa831")
	  Sendgrid.send("donkerbc@gmail.com", subs, "d-46d71cf815ac42a1897b6353684fa831")
	end

end