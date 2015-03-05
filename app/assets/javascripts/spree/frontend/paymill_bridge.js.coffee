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

  displayError = (field, error) ->
    field.addClass('error')
    errorLabel = field.parent().find('label.error')
    errorLabel.html(error)
    errorLabel.show()

  clearErrors = (paymillFormFields) ->
    paymillFormFields.find('#paymill_error').hide()
    inputs = paymillFormFields.find('input')
    $.each(inputs, (index, input) ->
      $(input).removeClass('error')
    )
    errors = paymillFormFields.find('label.error')
    $.each(errors, (index, error) ->
      $(error).hide()
      $(error).html = ''
    )
  paymillResponseHandler = (paymentForm, paymillFormFields) ->
    (error, result) ->
      if error
        handlePaymillError(paymillFormFields, error)
      else
        token = result.token
        last4Digits = result.last4Digits
        paymillFormFields.find('#gateway_payment_profile_id').val(token)
        paymillFormFields.find('#last_digits').val(last4Digits)
        paymentForm.get(0).submit();

  validatePaymentData = (paymillFormFields, paymillParams) ->
    valid= true
    if !paymill.validateHolder(paymillParams.cardholder)
      displayError(paymillFormFields.find('#name_on_card_' + PAYMILL_BRIDGE_DATA.paymentMethodID), PAYMILL_ERRORS.invalidCardHolder)
      valid = false
    if !paymill.validateCardNumber(paymillParams.number)
      displayError(paymillFormFields.find('#card_number'), PAYMILL_ERRORS.invalidCardNumber)
      valid = false
    if !paymill.validateExpiry(paymillParams.exp_month, paymillParams.exp_year)
      displayError(paymillFormFields.find('#card_expiry'), PAYMILL_ERRORS.invalidCardExp)
      valid = false
    if !paymill.validateCvc(paymillParams.cvc)
      displayError(paymillFormFields.find('#card_code'), PAYMILL_ERRORS.invalidCardCvc)
      valid = false
    return valid

  processPaymillBridge= (event) ->
    paymentForm = $(this).parents('form')
    paymentFormFields = paymentForm.find('#payment_method_' + PAYMILL_BRIDGE_DATA.paymentMethodID + ' fieldset')
    activePaymentMethodId = $(paymentForm).find('#payment-method-fields input:checked').val()
    if activePaymentMethodId != PAYMILL_BRIDGE_DATA.paymentMethodID
      return
    event.preventDefault()
    clearErrors(paymentFormFields)
    cardExpiry = paymentFormFields.find('#card_expiry').payment('cardExpiryVal')
    paymillParams = {
      number: paymentFormFields.find('#card_number').val()
      exp_month: cardExpiry.month
      exp_year: cardExpiry.year
      cvc: paymentFormFields.find('#card_code').val()
      amount_int: PAYMILL_BRIDGE_DATA.orderTotal
      currency: PAYMILL_BRIDGE_DATA.currency
      cardholder: paymentFormFields.find('#name_on_card_' + PAYMILL_BRIDGE_DATA.paymentMethodID).val()
    }
    if !validatePaymentData(paymentFormFields, paymillParams)
      return
    paymill.createToken(
      paymillParams,
      paymillResponseHandler(paymentForm, paymentFormFields)
    )

  $('#checkout_form_payment [type="submit"]').click processPaymillBridge
