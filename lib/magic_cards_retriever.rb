require          'net/http'
require          'json'
require_relative '../config'
require_relative 'thread_pool'

class MagicCardsRetriever
  attr_reader :cards,
              :last_api_lock,
              :first_mtg_api_call,
              :get_cards,
              :group_by_field

  def initialize
    @cards         = Array.new
    @last_api_lock = nil
  end

  # The "cards" attr will be set only after calling this method, getting info from the MTG API.
  def get_cards(args = {})
    call_mtg_api(args)
  end

  def group_by_field(fields, cards_list = nil)
    @cards = self.class.group_by_field(fields, cards_list || @cards)
  end

  # This method can group an array of cards by any field.
  # The first field you pass will be on the top of the agrupation tree.
  # It's a class method to make possible calling it with a previously calculated list of cards (as shown in "test.rb").
  def self.group_by_field(fields, cards_list)
    unless cards_list.nil?
      unless [ String, Symbol, Array ].include? fields.class
        raise "Invalid argument. It should be an array or a string separated by commas or pipes. Value given: #{fields}"
      end

      fields = fields.to_s       if fields.is_a?(Symbol)
      fields = fields.split(',') if fields.is_a?(String) && fields.include?(',')
      fields = fields[0].to_s    if fields.is_a?(Array) && fields.length == 1

      if fields.is_a?(Array)
        # We use recursivity just in case we have several fields.
        fields.each do |field|
          cards_list = group_by_field(field, cards_list)
        end
      else
        if cards_list.is_a?(Array)
          # We group the list of cards by a the value of a specific field.
          cards_list = cards_list.group_by{ |x| x[fields] }

          # We convert the hash to an array and then to a hash again with its keys indicating the field used to group them.
          cards_list = Hash[cards_list.map{ |k,v| [ "#{fields}->#{k}", v ] }]
        elsif cards_list.is_a?(Hash)
          # If there's more than one key in the hash, probably because it had been grouped by another field before,
          # we use recursivity again.
          cards_list.each do |kk,vv|
            cards_list[kk] = group_by_field(fields, vv)
          end
        end
      end
    end

    cards_list
  end

  protected

    def call_mtg_api(args, cards = Array.new)
      uri       = URI(API_ENDPOINT)
      uri.query = URI.encode_www_form(args)

      res = Net::HTTP.get_response(uri)

      if res.is_a?(Net::HTTPSuccess)
        headers = res.to_hash.transform_values(&:first)

        cards.push JSON.parse(res.body)

        # The MTG API has a rate limit we should respect,
        # so we inspect the headers to know if we can continue making requests or we should wait.
        check_api_rate_limit(headers)

        # We assume we want all MTG cards if no "page" param is specified.
        # For doing so, we inspect the headers looking for the total of cards and making the requests needed.
        unless args.include?('page')
          # We create a new thread for every extra request to increase speed,
          # using a pool with a maximum size fixed in the config file.
          threads_pool = ThreadPool.new(MAX_THREADS)

          cards_pages_needed(headers).times do |page|
            threads_pool.dispatch do
              args         ||= {}
              args['page']   = page + 1

              p "Requesting page #{args['page']}..."
              call_mtg_api(args, cards)
              p "Page #{args['page']} retrieved successfully."
            end
          end

          threads_pool.shutdown
        end
      else
        raise "Error retrieving the information from the MTG API. Endpoint used: #{API_ENDPOINT}. Params: #{args}. Headers: #{headers}. Body: #{res.body}"
      end

      cards = cards[0] if cards.is_a?(Array) && cards.length == 1 && cards[0].is_a?(Hash) && cards[0].keys == [ 'cards' ]

      @cards = cards
    end

    def check_api_rate_limit(headers)
      # A bit excesive waiting that much, but necessary if we want to retrieve all MTG cards respecting the API's rate limit.
      if headers.include?('ratelimit-remaining') && headers['ratelimit-remaining'].to_i > 0
        if @last_api_lock.nil?
          @last_api_lock      = Time.now.utc - API_TIME_LIMIT
          @first_mtg_api_call = true
        else
          @first_mtg_api_call = false
        end

        sleep(seconds_to_api_unlock)
      end
    end

    def seconds_to_api_unlock
      seconds_from_last_lock = Time.now.utc.to_i - @last_api_lock.to_i
      seconds_to_unlock      = API_TIME_LIMIT - seconds_from_last_lock

      p "#{seconds_from_last_lock} seconds from last lock." unless @first_mtg_api_call

      if seconds_to_unlock <= 0
        0
      else
        p "API rate limit exceeded. Waiting #{seconds_to_unlock} seconds to retrieve more cards..."

        seconds_to_unlock
      end
    end

    def cards_pages_needed(headers)
      unless headers.include?('total-count') && headers.include?('page-size')
        raise "No \"total-count\" or \"page-size\" headers found. Headers given: #{headers}"
      end

      pages_needed = (headers['total-count'].to_i / headers['page-size'].to_i).ceil

      p "#{headers['total-count']} cards found, #{headers['page-size']} per page. Pages needed to show them all: #{pages_needed}"

      pages_needed
    end
end
