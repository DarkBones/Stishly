APP_CONFIG = YAML.load_file(Rails.root.join('config/system_parameters.yml'))
ENV = YAML.load_file(Rails.root.join('config/aws.yml'))