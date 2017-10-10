# MTG API cards endpoint.
API_ENDPOINT = 'https://api.magicthegathering.io/v1/cards'

# Time in seconds in which we can make the max. requests specified the "Rate Limits" part of the doc:
# https://docs.magicthegathering.io/#documentationrate_limits
API_TIME_LIMIT = 3600

# Max number of simultaneous threads. This value depends on your system, so run some benchmarks an change it as needed.
MAX_THREADS = 5

# Location of the "ruby" command to execute the CLI version of this script in its specific tests.
RUBY_COMMAND_LOCATION = 'ruby'
