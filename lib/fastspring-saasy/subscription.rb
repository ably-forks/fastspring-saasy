require 'date'
require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/to_query'

module FastSpring
  class Subscription < PrivateApiBase
    def self.create_subscription_url(reference, referrer)
      "#{SITE_URL}/#{self.company_id}/product/#{reference}?referrer=#{referrer}"
    end

    ####################
    # type:
    #  :detail : http://sites.fastspring.com/julie/product/fontmaker
    #  :order : POST http://sites.fastspring.com/julie/product/fontmaker?action=order
    #  :instant : https://sites.fastspring.com/julie/instant/fontmaker
    #  :add : POST http://sites.fastspring.com/julie/product/fontmaker?action=add
    #  :adds : http://sites.fastspring.com/julie/product/fontmaker?action=adds
    #  :api : POST http://sites.fastspring.com/julie/api/order
    ####################
    def self.subscription_url(type, options = {})
      case type
        when :detail
          product = options.delete(:product)
          # TODO: throw error if no product
          query = options.to_param
          "#{SITE_URL}/#{self.company_id}/product/#{product}#{query.empty? ? '' : "?#{query}"}"

        when :order, :add, :adds
          self.subscription_url(:detail, options.merge(action: type))

        when :instant
          product = options.delete(:product)
          # TODO: throw error if no product
          query = {contact_fname: ' ', contact_lname: ' '}.merge(options).to_param
          "#{SSL_SITE_URL}/#{self.company_id}/instant/#{product}?#{query}"

        when :api
          "#{SITE_URL}/#{self.company_id}/api/order"
      end
    end

    def self.company_id
      FastSpring::Account.fetch(:company)
    end

    # Get the subscription from Saasy
    def find
      @response = self.class.get(base_subscription_path, :basic_auth => @auth, :ssl_ca_file => @ssl_ca_file)
      self
    end

    # Returns the base path for a subscription
    def base_subscription_path
      "/company/#{@company}/subscription/#{@reference}"
    end

    # The reason for a status change
    def status_reason
      value_for('statusReason')
    end

    # Is the subscription active?
    def active?
      status == 'active'
    end

    # Can the subscription be cancelled?
    def cancelable?
      value_for('cancelable') == 'true'
    end

    # Subscription product name
    def product_name
      value_for('productName')
    end

    def next_period_date
      Date.parse(value_for('nextPeriodDate'))
    end

    # The date the subscription ends on
    def ends_on
      Date.parse(value_for('end'))
    end

    def quantity
      value_for('quantity').to_i
    end

    def tags
      begin
        fs_tags = value_for('tags')
        result = {}
        fs_tags.split(",").each do |t| 
           k,v = t.strip.split('=')
           result[k.to_sym] = v
        end
        result
      rescue 
        nil
      end
    end

    def customer_url
      value_for('customerUrl')
    end

    # Cancel the subscription
    def destroy
      self.class.delete(base_subscription_path, :basic_auth => @auth)
    end
    alias :cancel! :destroy

    def renew_path
      "#{base_subscription_path}/renew"
    end

    # Renew the subscription
    def renew
      self.class.post(renew_path, :basic_auth => @auth)
    end

    private

    def parsed_response
      @response.parsed_response['subscription']
    end

  end
end

