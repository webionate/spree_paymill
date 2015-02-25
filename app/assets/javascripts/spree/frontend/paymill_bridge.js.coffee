$(document).ready ->
  'use strict'
  handlePaymillError = (paymill_form_fields, error) ->
    $(paymill_form_fields.find('.paymill-error')).each(
      (index, error_item) ->
        $(error_item).html('')
    )
    switch error.apierror
      when 'field_invalid_card_holder'
        show_error paymill_form_fields.find('#card_holder'), PAYMILL_ERRORS.invalidCardHolder
      when 'field_invalid_card_number'
        show_error paymill_form_fields.find('#card_number'), PAYMILL_ERRORS.invalidCardNumber
      when 'field_invalid_card_exp_month'
        show_error paymill_form_fields.find('#card_expiry'), PAYMILL_ERRORS.invalidCardExpMonth
      when 'field_invalid_card_exp_year'
        show_error paymill_form_fields.find('#card_expiry'), PAYMILL_ERRORS.invalidCardExpYear
      when 'field_invalid_card_exp'
        paymill_form_fields.find('>.paymill-error').html(PAYMILL_ERRORS.invalidCardExp)
      when 'field_invalid_card_cvc'
        show_error paymill_form_fields.find('#card_code'), PAYMILL_ERRORS.invalidCardCvc
      else
        console.log(error)
        paymill_form_fields.find('>.paymill-error').html(PAYMILL_ERRORS.otherError)

  show_error = (input, error) ->
    span_error = $(input).parent().find('>.paymill-error')
    span_error.html(error)

  paymillResponseHandler = (payment_form, paymill_form_fields) ->
    (error, result) ->
      if error
        handlePaymillError(paymill_form_fields, error)
      else
        token = result.token
        last_digits = result.last4Digits
        paymill_form_fields.find('#gateway_payment_profile_id').val(token)
        paymill_form_fields.find('#last_digits').val(last_digits)
        paymill_form_fields.find('#card_number').val('')
        payment_form.get(0).submit();

  card_expiry_month = (paymill_form_fields) ->
    month = paymill_form_fields.find('#card_expiry').val().split('/')[0]
    if month
      month.trim()
    else
      ''

  card_expiry_year = (paymill_form_fields) ->
    year = paymill_form_fields.find('#card_expiry').val().split('/')[1]
    if year
      year = year.trim()
      if year.length == 2
        '20' + year
      else
        year
    else
      ''

  process_paymill_bridge= (event) ->
    payment_form = $(this).parents('form')
    paymill_form_fields = payment_form.find('#payment_method_' + PAYMILL_BRIDGE_DATA.paymentMethodID + ' fieldset')
    active_payment_method_id = $(payment_form).find('#payment-method-fields input:checked').val()
    if active_payment_method_id != PAYMILL_BRIDGE_DATA.paymentMethodID
      paymill_form_fields.find('#card_number').val('')
      paymill_form_fields.find('#card_code').val('')
      return

    event.preventDefault()
    paymill_params = {
      number: paymill_form_fields.find('#card_number').val()
      exp_month: card_expiry_month(paymill_form_fields);
      exp_year: card_expiry_year(paymill_form_fields)
      cvc: paymill_form_fields.find('#card_code').val()
      amount_int: PAYMILL_BRIDGE_DATA.orderTotal
      currency: PAYMILL_BRIDGE_DATA.currency
      cardholder: paymill_form_fields.find('#name_on_card_' + PAYMILL_BRIDGE_DATA.paymentMethodID).val()
    }
    paymill.createToken(
      paymill_params,
      paymillResponseHandler(payment_form, paymill_form_fields)
    )



  $('#checkout_form_payment .button[type="submit"]').click process_paymill_bridge
