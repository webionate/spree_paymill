module Spree
  class Gateway::PaymillCreditCard < Gateway

    preference :public_key, :string
    preference :private_key, :string
    preference :currency, :string, default: 'EUR'

    def method_type
      'paymill_credit_card'
    end

    def require_card_numbers?
      false
    end

    def provider_class
      Spree::Gateway::PaymillCreditCardGateway
    end
  end
end
