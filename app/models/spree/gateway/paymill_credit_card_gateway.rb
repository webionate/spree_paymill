module Spree
  class Gateway::PaymillCreditCardGateway <  ActiveMerchant::Billing::PaymillGateway
    private

    def action_with_token(action, money, payment_method, options)
      token = token(payment_method)
      send("#{action}_with_token", money, token, options)
    end

    def token(payment_method)
      if payment_method.is_a? String
        payment_method
      else
        payment_method.gateway_payment_profile_id
      end
    end
  end
end
