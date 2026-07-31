ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods
    include Devise::Test::IntegrationHelpers

    parallelize(workers: :number_of_processors, with: :threads)
  end
end