require 'magic_cards_retriever'

# Explanation of every CLI option available. Better here for code readability and to change it easier if needed.
CLI_OPTIONS_DOC = {
  group_by: 'Group by any field specified in the doc for the endpoint (https://docs.magicthegathering.io/#api_v1cards_list).',
  color:    'Search by color with values separated by commas (example: "--color red,white,blue").',
  set:      'Search by set with values separated by commas (example: "--set Lorem,Ipsum").'
}

find_args = Hash.new
group_by  = String.new

OptionParser.new do |opt|
  # Possible CLI options. "-h" and "--help" options available too.
  opt.on('-g', '--group_by GROUPBY',  CLI_OPTIONS_DOC[:group_by]) { |o| group_by = o }
  opt.on('-c', '--color COLOR',       CLI_OPTIONS_DOC[:color])    { |o| find_args['color'] = o }
  opt.on('-s', '--set SET',           CLI_OPTIONS_DOC[:set])      { |o| find_args['setName'] = o }
end.parse!

unless find_args.empty?
  cards = MagicCardsRetriever.new.get_cards(find_args)
  cards = cards.group_by_field(group_by)               unless group_by.empty?
  cards
end
