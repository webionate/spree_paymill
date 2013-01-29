module Spree
  class BillingIntegration::PaymillCreditCard < Spree::BillingIntegration
    preference :private_key, :string
    preference :public_key, :string
    
    attr_accessible :preferred_private_key, :preferred_public_key, :preferred_server, :preferred_test_mode
    
    def provider_class
      ActiveMerchant::Billing::PaymillGateway
    end
    
    def payment_source_class
      CreditCard
    end
    
    def authorize(money, credit_card, options = {})
      order = Spree::Order.find_by_number(options[:order_id])
      
      options[:api_key] = preferred_private_key
      options[:token] = order.payment.response_code
      
      provider.authorize(money, credit_card, options)
    end
    
    def capture(authorization, credit_card, options = {})
      order = Spree::Order.find_by_number(options[:order_id])
      
      options[:api_key] = preferred_private_key
      options[:preauthorization] = order.payment.response_code
      
      provider.capture(authorization, credit_card, options)
    end
    
    def void(response_code, credit_card, options = {})
      return ActiveMerchant::Billing::PaymillResponse.new(true, 'Paymill refund not necessary, because payment was in preauth state') if response_code.start_with?("preauth_")
      
      options[:api_key] = preferred_private_key
      
      provider.refund(response_code, credit_card, options)
    end
    
    
    private
    def init_data
      ::Paymill.api_key = preferred_private_key
    end
  end
end

