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
      payment = Spree::Payment.find_by_source_id(credit_card)
      errors.add(:payment, "couldn't find corresponding payment") if payment.nil?

      if payment.response_code.present?
        token = payment.response_code

        response = provider.authorize(money, token, options)

        if response.success?
          payment.response_code = nil
          payment.save!
        end
      else
        response = ActiveMerchant::Billing::Response.new(true, 'Paymill authorization not necessary, because credit card was already authorized')
      end
      response
    end
    
    def capture(money, authorization, options = {})
      provider.capture(money, authorization, options)
    end
    
    def void(response_code, credit_card, options = {})
      amount = credit_card[:subtotal].to_i
      provider.refund(amount, response_code, options)
    end
  end
end

