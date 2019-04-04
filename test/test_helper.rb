ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def format_error(message, expected=nil, actual=nil, result: nil)
    error = message

    error += "\nexpected:\t#{expected}" unless expected.nil?
    error += "\nactual:\t\t#{actual}" unless actual.nil?
    error += "\nresult:\t\t#{result}" unless result.nil?

    return error
  end

  def wait_for_ajax
    Timeout.timeout(10) do
      active = page.evaluate_script('jQuery.active')
      until active == 0
        active = page.evaluate_script('jQuery.active')
      end
    end
  end
  
end
