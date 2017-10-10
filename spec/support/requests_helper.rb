module RequestsHelper
  # All calls to the MTG API stubbed to return some prefixed data.
  def stub_request_and_returns_200
    # MTG API throws a 500 error when you try to view an inexistent page.
    stub_request(:get, /^#{API_ENDPOINT}*/).to_return(ok_responses + [ error_500_response ])
  end

  # We simulate a "limit exceeded" response to test the app's management of this kind of errors.
  def stub_request_and_returns_403
    stub_request(:get, /^#{API_ENDPOINT}*/).to_return([ error_403_response ] + ok_responses)
  end

  def all_cards_grouped_by_set
    JSON.parse(File.open('spec/fixtures/files/all_cards_grouped_by_set.json', 'r').read)
  end

  def all_cards_grouped_by_set_and_rarity
    JSON.parse(File.open('spec/fixtures/files/all_cards_grouped_by_set_and_rarity.json', 'r').read)

  end

  def khans_of_tharkir_red_and_blue_cards
    JSON.parse(File.open('spec/fixtures/files/khans_of_tharkir_red_and_blue_cards.json', 'r').read)
  end

  private

    # 3 responses only, regardless of the fixture name, with 10 items each. Headers are made to say the same.
    def ok_responses
      [
        { body: File.open('spec/fixtures/files/all_cards/10_items_1.json', 'r').read, status:  200, headers: response_headers(rate_limit_remaining: 4999) },
        { body: File.open('spec/fixtures/files/all_cards/10_items_2.json', 'r').read, status:  200, headers: response_headers(rate_limit_remaining: 4998) },
        { body: File.open('spec/fixtures/files/all_cards/10_items_3.json', 'r').read, status:  200, headers: response_headers(rate_limit_remaining: 4997) }
      ]
    end

    def error_500_response
      {
        body:    { status: 500, error: 'Internal Server Error' }.to_json,
        status:  500,
        headers: response_headers(status: 500, rate_limit_remaining: 4999)
      }
    end

    def error_403_response
      {
        body:    { status: 403, error: 'Rate Limit Exceeded' }.to_json,
        status:  403,
        headers: response_headers(status: 403, rate_limit_remaining: 0)
      }
    end

    # Headers as the ones defined in the doc, with pagination params only for successful requests.
    def response_headers(args = {})
      headers = {
        'ratelimit-limit'     => 5000,
        'ratelimit-remaining' => args['rate_limit_remaining'] || 4999
      }

      if args['status'].nil? || args['status'].to_i == 200
        headers.merge!({
          'link'        => '',
          'page-size'   => 10,
          'count'       => 10,
          'total-count' => 30
        })
      end

      headers
    end
end
