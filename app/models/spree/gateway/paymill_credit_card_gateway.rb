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

    def response_message(parsed_response)
      return parsed_response["error"] if parsed_response["error"]
      return "Transaction approved." if (parsed_response['data'] == [])

      code = parsed_response["data"]["response_code"]
      I18n.t("paymill.error_responses.#{code}") || code.to_s
    end
  end
end
