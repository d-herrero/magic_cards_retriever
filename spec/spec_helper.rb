require_relative '../lib/magic_cards_retriever'
require_relative '../lib/magic_cards_retriever_cli'
require_relative 'support/requests_helper'
require          'rspec_command'
require          'webmock/rspec'

# We redefine the time limit of the API as we don't want to wait that much while testing.
Object.send(:remove_const, :API_TIME_LIMIT)
API_TIME_LIMIT = 5

RSpec.configure do |config|
  # RSpec-command helper module to test the CLI part of the app.
  config.include RSpecCommand

  # Stubs and responses helpers
  config.include RequestsHelper
end

# External requests disabled to ensure we only deal with stubbed ones.
WebMock.disable_net_connect!
