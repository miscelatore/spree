# cc_payment_method = Spree::Gateway::Bogus.where(
#   name: 'Credit Card',
#   description: 'Bogus payment gateway.',
#   active: true
# ).first_or_create!
#
# cc_payment_method.store_ids = Spree::Store.ids
# cc_payment_method.save!
#
# check_paymemt_method = Spree::PaymentMethod::Check.where(
#   name: 'Check',
#   description: 'Pay by check.',
#   active: true
# ).first_or_create!
#
# check_paymemt_method.store_ids = Spree::Store.ids
# check_paymemt_method.save!

cc_payment_method = Spree::Gateway::PayPalExpress.where(
  name: 'PayPal',
  description: 'Gateway di pagamento PayPal.',
  display_on: 'both',
  auto_capture: true,
  active: true
).first_or_create!

cc_payment_method.store_ids = Spree::Store.ids
cc_payment_method.save!

cc_payment_method = Spree::Gateway::StripeGateway.where(
  name: 'Stripe',
  description: 'Gateway di pagamento Stripe.',
  display_on: 'both',
  auto_capture: true,
  active: true
).first_or_create!

cc_payment_method.store_ids = Spree::Store.ids
cc_payment_method.save!