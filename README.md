Welcome to spree_paymill
========================

This is a [SpreeCommerce](http://www.spreecommerce.com) extension for using the [Paymill](http://www.paymill.com) payment service.

[![Code Climate](https://codeclimate.com/github/webionate/spree_paymill.png)](https://codeclimate.com/github/webionate/spree_paymill)
[![Build Status](https://travis-ci.org/webionate/spree_paymill.png?branch=master)](https://travis-ci.org/webionate/spree_paymill)

Setup
=====
* Add spree_paymill to the Gemfile of your spree store
    `gem 'spree_paymill' , :git => 'git://github.com/webionate/spree_paymill.git'`

* Don't forget to run Bundler
    `$ bundle install`
* Install the extension
    `$ rails g spree_paymill:install`

* Login to your backoffice of the spree store

* Go to configuration >> paymentmethods and add a new payment method

* Select `Spree::BillingIntegration::PaymillCreditCard` and submit the form

* You are receiving 2 additional input fields to enter the private and public key from Paymill

* Login to the Paymill backoffice, copy the keys from there, enter them in the Spree backoffice and submit the form again

* You're ready to go!

NOTE
====
spree_paymill is currently in a testing phase. It is already capable of handling payments and refunds via credit cards (MasterCard and Visa). Handling of debit cards currently isn't supported. Although we've tested spree_paymill on our systems, we currently don't guarantee, that it will work in your environment too.

If you want to use spree_paymill in a production environment you'll have to contact Paymill to receive live keys.

Questions?
==========
Just contact us via our [website](http://www.webionate.de)
