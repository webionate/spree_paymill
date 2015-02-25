require 'spec_helper'

describe Spree::Gateway::PaymillCreditCardGateway do

  describe '#authorize' do
    context 'with a paymill token' do
      it '#calls authorize_with_token with the right arguments' do
        gateway = Spree::Gateway::PaymillCreditCardGateway.new(
          public_key: 'public', private_key: 'private'
        )
        expect(gateway).to(
          receive(:authorize_with_token)
          .with(1000, 'tok_49f3e1046351ecee7bcd', a_option: 'test' )
        )
        gateway.authorize(1000, 'tok_49f3e1046351ecee7bcd', a_option: 'test')
      end
    end
    context 'with a creditcard' do
      it '#calls authorize_with_token with the right arguments' do
        credit_card = instance_double(
          Spree::CreditCard,
          gateway_payment_profile_id: 'tok_49f3e1046351ecee7bcd'
        )
        gateway = Spree::Gateway::PaymillCreditCardGateway.new(
          public_key: 'public', private_key: 'private'
        )
        expect(gateway).to(
          receive(:authorize_with_token)
          .with(1000, 'tok_49f3e1046351ecee7bcd', a_option: 'test' )
        )

        gateway.authorize(1000, credit_card, a_option: 'test')
      end
    end
  end
end
