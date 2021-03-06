class Sendgrid

  def self.send(to, subsitutions, template_id)
    subsitutions[:sign_off] ||= I18n.t('models.sendgrid.substitutions.sign_off')

    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": to
            }
          ],
          "dynamic_template_data": subsitutions
        }
      ],
      "from": {
        "email": 'noreply@stishly.com',
        "name": 'Stishly'
      },
      "template_id": template_id
    }

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])

    begin
      response = sg.client.mail._("send").post(request_body: data)
      return response.status_code
    rescue StandardError => e
      puts e.message
    end
  end
  
end