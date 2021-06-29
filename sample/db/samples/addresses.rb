italy = Spree::Country.find_by!(iso: 'IT')
firenze = Spree::State.find_by!(name: 'Firenze')

# Billing address
Spree::Address.create!(
  firstname: FFaker::NameIT.first_name,
  lastname: FFaker::NameIT.last_name,
  address1: FFaker::Address.street_address,
  address2: FFaker::Address.secondary_address,
  city: FFaker::Address.city,
  state: firenze,
  zipcode: 50100,
  country: italy,
  phone: FFaker::PhoneNumberIT.phone_number
)

# Shipping address
Spree::Address.create!(
  firstname: FFaker::Name.first_name,
  lastname: FFaker::Name.last_name,
  address1: FFaker::Address.street_address,
  address2: FFaker::Address.secondary_address,
  city: FFaker::Address.city,
  state: firenze,
  zipcode: 16804,
  country: 50100,
  phone: FFaker::PhoneNumberIT.phone_number
)
