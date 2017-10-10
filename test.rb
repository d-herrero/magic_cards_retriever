require_relative 'lib/magic_cards_retriever'

mcr_cards_grouped_by_set = MagicCardsRetriever.new

mcr_cards_grouped_by_set.get_cards.group_by_field(:set)

p "=========="
p "Cards grouped by set: \n\n#{mcr_cards_grouped_by_set.cards}"
p "=========="

cards_grouped_by_set_and_rarity = MagicCardsRetriever.group_by_field(:rarity, mcr_cards_grouped_by_set.cards)

p "=========="
p "Cards grouped by set and rarity: \n\n#{cards_grouped_by_set_and_rarity}"
p "=========="

mcr_red_blue_khans_tarkir_cards = MagicCardsRetriever.new

mcr_red_blue_khans_tarkir_cards.get_cards(color: 'red,blue', setName: 'Khans of Tarkir')

p "=========="
p "Red and blue cards of the \"Khans of Tarkir\" set: \n\n#{mcr_red_blue_khans_tarkir_cards.cards}"
p "=========="
