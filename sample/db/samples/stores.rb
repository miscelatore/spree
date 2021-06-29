default_store = Spree::Store.default
default_store.checkout_zone = Spree::Zone.find_by(name: 'Europa')
default_store.default_country = Spree::Country.default
default_store.supported_currencies = 'EUR'
default_store.supported_locales = 'it'
default_store.url = Rails.env.development? ? 'localhost:3000' : 'demoecommerce.seo.it'
default_store.save!

currencies = %w[EUR]
Spree::Price.where(currency: 'EUR').each do |price|
  currencies.each do |currency|
    new_price = Spree::Price.find_or_initialize_by(currency: currency, variant: price.variant)
    new_price.amount = if %w[EUR GBP].include?(currency)
                         price.amount * 0.8
                       else
                         price.amount * 1.2
                       end
    new_price.save
  end
end

Spree::PaymentMethod.all.each do |payment_method|
  payment_method.stores = Spree::Store.all
end

if defined?(Spree::StoreProduct) && Spree::Product.method_defined?(:stores)
  Spree::Product.all.each do |product|
    product.store_ids = Spree::Store.ids
    product.save
  end
end
