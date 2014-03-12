//= require store/spree_frontend

$(document).ready(function () {
    var form = $("#checkout_form_payment");

    function unableSubmitButton() {
        $('.store-button').attr('disabled', false).removeClass('disabled');
    }

    function PaymillResponseHandler(error, result) {
        if (error) {
            console.log('ERROR: ' + error.apierror);
            if (error.apierror == 'field_invalid_card_cvc') {
                alert("CVC invalid");
            }
            unableSubmitButton();
        } else {
            var token = result.token;
            form.append("<input type='hidden' name='order[payments_attributes][][response_code]' value='" + token + "'/>");
            form.get(0).submit();
        }
    }

    var tdsInit = function (redirect, cancelFn) {
        var checkout_div = $('#checkout[data-hook=""]');
        var iframe = document.createElement('iframe');
        var url = redirect.url;
        var params = redirect.params;

        iframe.id = 'tdsIframe';
        iframe.width = 600;
        iframe.height = 500;
        iframe.style.zIndex = 0xffffffff;
        iframe.style.background = '#fff';
        iframe.style.position = 'absolute';
        iframe.style.border = 'none';

        checkout_div.after(iframe);

        // Grab the iframes document object in all browsers.
        var iframeDoc = iframe.contentWindow || iframe.contentDocument;
        if (iframeDoc.document) iframeDoc = iframeDoc.document;

        // Create the form containing the redirect parameters and submit it
        // to load the card issuing bank's verification page.
        var iframe_form = iframeDoc.createElement('form');
        iframe_form.method = 'post';
        iframe_form.action = url;

        for (var k in params) {
            var input = iframeDoc.createElement('input');
            input.type = 'hidden';
            input.name = k;
            input.value = decodeURIComponent(params[k]);
            iframe_form.appendChild(input);
        }

        if (iframeDoc.body) iframeDoc.body.appendChild(iframe_form);
        else iframeDoc.appendChild(iframe_form);

        iframe_form.submit();

        $('#checkout[data-hook=""]').css('display', 'none');
    };

    var tdsCleanup = function () {
        var iframe = document.getElementById('tdsIframe');
        iframe.parentNode.removeChild(iframe);
    };

    form.submit(function (event) {

        var cc_payment_method = $('.f-creditcards:visible')
        cc_payment_method_id = cc_payment_method.attr('data-hook');
        if ($('#order_payments_attributes__payment_method_id_' + cc_payment_method_id).prop('checked')) {
            var paymill_code = $("#checkout_form_payment #payment_method_" + cc_payment_method_id);

            if (paymill_code.find('p[data-hook="card_number"] #card_number').val() != "") {
                var exp_month = paymill_code.find('p[data-hook="card_expiration"]').find('select[id$="_month"]').find('option:selected').val();
                var exp_year = paymill_code.find('p[data-hook="card_expiration"]').find('select[id$="_year"]').find('option:selected').val();

                if (false == paymill.validateCardNumber(paymill_code.find('p[data-hook="card_number"] #card_number').val())) {
                    alert("Card number invalid");
                    unableSubmitButton();
                    return false;
                }

                if (false == paymill.validateExpiry(exp_month, exp_year)) {
                    alert("Expiry date invalid");
                    unableSubmitButton();
                    return false;
                }

                paymill.createToken({
                    number:paymill_code.find('p[data-hook="card_number"] #card_number').val(),
                    exp_month:exp_month,
                    exp_year:exp_year,
                    cvc:paymill_code.find('p[data-hook="card_code"] #card_code').val(),
                    cardholdername:'',
                    amount:cc_payment_method.data('orderamount'),
                    currency:'EUR'
                }, PaymillResponseHandler, tdsInit, tdsCleanup);

                return false;
            }
        }
    });
});
