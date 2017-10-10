require 'spec_helper'

describe MagicCardsRetriever do
  before :each do
    stub_request_and_returns_200
  end

  it 'returns all cards grouped by set' do
    mcr = MagicCardsRetriever.new

    mcr.get_cards
    mcr.group_by_field(:setName)

    expect(mcr.cards).to eq(all_cards_grouped_by_set)
  end

  it 'returns all cards grouped by set and rarity' do
    mcr = MagicCardsRetriever.new

    mcr.get_cards
    mcr.group_by_field(:setName, :rarity)

    expect(mcr.cards).to eq(all_cards_grouped_by_set_and_rarity)
  end

  it 'returns red and blue cards of the "Khans of Tarkir" set' do
    mcr = MagicCardsRetriever.new

    mcr.get_cards(color: 'red,blue', setName: 'Khans of Tarkir')

    expect(mcr.cards).to eq(khans_of_tharkir_red_and_blue_cards)
  end
end
