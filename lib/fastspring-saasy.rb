require 'httparty'

require_relative 'httparty/txt_parser'

module FastSpring
  SITE_URL = 'http://sites.fastspring.com'
  SSL_SITE_URL = 'https://sites.fastspring.com'
  API_URL = 'https://api.fastspring.com'
end

require_relative 'fastspring-saasy/private_api_base'
require_relative 'fastspring-saasy/account'
require_relative 'fastspring-saasy/subscription'
require_relative 'fastspring-saasy/customer'
require_relative 'fastspring-saasy/order'
require_relative 'fastspring-saasy/item'
require_relative 'fastspring-saasy/payment'
require_relative 'fastspring-saasy/address'

require_relative 'fastspring-saasy/public_api_base'
require_relative 'fastspring-saasy/localized_store_pricing'

require_relative 'fastspring-saasy/error'

