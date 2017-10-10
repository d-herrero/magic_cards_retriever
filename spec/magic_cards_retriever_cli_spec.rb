require 'spec_helper'

describe 'MagicCardsRetrieverCli' do
  before :each do
    stub_request_and_returns_200
  end

  # after :each do
  #   its(:stderr)     { is_expected.to eq('') }
  #   its(:exitstatus) { is_expected.to eq(0) }
  # end

  describe 'returns all cards grouped by set' do

    command "#{RUBY_COMMAND_LOCATION} lib/magic_cards_retriever_cli.rb --group_by set"

    its(:stdout) { is_expected.to eq(all_cards_grouped_by_set) }
  end

  describe 'returns all cards grouped by set and rarity' do
    command "#{RUBY_COMMAND_LOCATION} lib/magic_cards_retriever_cli.rb --group_by set,rarity"

    its(:stdout) { is_expected.to eq(all_cards_grouped_by_set_and_rarity) }
  end

  describe 'returns red and blue cards of the "Khans of Tarkir" set' do
    command "#{RUBY_COMMAND_LOCATION} lib/magic_cards_retriever_cli.rb --color red,blue --set \"Khans of Tarkir\""

    its(:stdout) { is_expected.to eq(khans_of_tharkir_red_and_blue_cards) }
  end
end
