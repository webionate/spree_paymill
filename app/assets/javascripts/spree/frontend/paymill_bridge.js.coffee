$(document).ready ->
  'use strict'
  mapPaymillError = (apiError) ->
    switch apiError
      when 'field_invalid_card_holder'
        PAYMILL_ERRORS.invalidCardHolder
      when 'field_invalid_card_number'
        PAYMILL_ERRORS.invalidCardNumber
      when 'field_invalid_card_exp'
        PAYMILL_ERRORS.invalidCardExp
      when 'field_invalid_card_cvc'
        PAYMILL_ERRORS.invalidCardCvc
      else
        PAYMILL_ERRORS.processingError

  handlePaymillError = (paymillFormFields, error) ->
    errorDesc = mapPaymillError(error.apierror)
    errorDiv = $(paymillFormFields).find('#paymill_error')
    errorDiv.html(errorDesc)
    errorDiv.show()
    throw "Paymill Bridge error: " + error.apierror

  display_error = (field, error) ->
    field.addClass('error')
    error_label = field.parent().find('label.error')
    error_label.html(error)
    error_label.show()

  clear_errors = (paymill_form_fields) ->
    paymill_form_fields.find('#paymill_error').hide()
    inputs = paymill_form_fields.find('input')
    $.each(inputs, (index, input) ->
      $(input).removeClass('error')
    )
    errors = paymill_form_fields.find('label.error')
    $.each(errors, (index, error) ->
      $(error).hide()
      $(error).html = ''
    )
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

  validate_payment_data = (paymill_form_fields, paymill_params) ->
    valid= true
    if !paymill.validateHolder(paymill_params.cardholder)
      display_error(paymill_form_fields.find('#name_on_card_' + PAYMILL_BRIDGE_DATA.paymentMethodID), PAYMILL_ERRORS.invalidCardHolder)
      valid = false
    if !paymill.validateCardNumber(paymill_params.number)
      display_error(paymill_form_fields.find('#card_number'), PAYMILL_ERRORS.invalidCardNumber)
      valid = false
    if !paymill.validateExpiry(paymill_params.exp_month, paymill_params.exp_year)
      display_error(paymill_form_fields.find('#card_expiry'), PAYMILL_ERRORS.invalidCardExp)
      valid = false
    if !paymill.validateCvc(paymill_params.cvc)
      display_error(paymill_form_fields.find('#card_code'), PAYMILL_ERRORS.invalidCardCvc)
      valid = false
    return valid

  process_paymill_bridge= (event) ->
    payment_form = $(this).parents('form')
    paymill_form_fields = payment_form.find('#payment_method_' + PAYMILL_BRIDGE_DATA.paymentMethodID + ' fieldset')
    active_payment_method_id = $(payment_form).find('#payment-method-fields input:checked').val()
    if active_payment_method_id != PAYMILL_BRIDGE_DATA.paymentMethodID
      return
    event.preventDefault()
    clear_errors(paymill_form_fields)
    card_expiry = paymill_form_fields.find('#card_expiry').payment('cardExpiryVal')
    paymill_params = {
      number: paymill_form_fields.find('#card_number').val()
      exp_month: card_expiry.month
      exp_year: card_expiry.year
      cvc: paymill_form_fields.find('#card_code').val()
      amount_int: PAYMILL_BRIDGE_DATA.orderTotal
      currency: PAYMILL_BRIDGE_DATA.currency
      cardholder: paymill_form_fields.find('#name_on_card_' + PAYMILL_BRIDGE_DATA.paymentMethodID).val()
    }
    if !validate_payment_data(paymill_form_fields, paymill_params)
      return
    paymill.createToken(
      paymill_params,
      paymillResponseHandler(payment_form, paymill_form_fields)
    )



  $('#checkout_form_payment .button[type="submit"]').click process_paymill_bridge
