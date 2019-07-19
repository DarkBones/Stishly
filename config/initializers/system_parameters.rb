APP_CONFIG = YAML.load_file(Rails.root.join('config/system_parameters.yml'))

ENV['AWS_REGION'] = "us-east-2"
ENV['AWS_ACCESS_KEY_ID'] = Rails.application.credentials.aws[:access_key_id]
ENV['AWS_SECRET_ACCESS_KEY'] = Rails.application.credentials.aws[:secret_access_key]

ENV['EMAIL_ENCRYPTION_KEY'] = Rails.application.credentials.pii[:encryption_key]
ENV['EMAIL_BLIND_INDEX_KEY'] = Rails.application.credentials.pii[:blind_index_key]