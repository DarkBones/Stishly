APP_CONFIG = YAML.load_file(Rails.root.join('config/system_parameters.yml'))
#ENV = YAML.load_file(Rails.root.join('config/aws.yml'))
ENV = {}
ENV['AWS_REGION'] = "us-east-2"
ENV['AWS_ACCESS_KEY_ID'] = Rails.application.credentials.aws[:access_key_id]
ENV['AWS_SECRET_ACCESS_KEY'] = Rails.application.credentials.aws[:secret_access_key]