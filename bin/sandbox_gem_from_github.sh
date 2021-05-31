#!/bin/sh
# Used in the sandbox rake task in Rakefile

set -e

case "$DB" in
postgres)
  RAILSDB="postgresql"
  ;;
mysql)
  RAILSDB="mysql"
  ;;
sqlite|'')
  RAILSDB="sqlite3"
  ;;
*)
  echo "Invalid DB specified: $DB"
  exit 1
  ;;
esac

rm -rf ./sandbox
bundle exec rails new sandbox --database="$RAILSDB" \
  --skip-bundle \
  --skip-git \
  --skip-keeps \
  --skip-rc \
  --skip-spring \
  --skip-test \
  --skip-coffee \
  --skip-javascript \
  --skip-bootsnap

if [ ! -d "sandbox" ]; then
  echo 'sandbox rails application failed'
  exit 1
fi

cd ./sandbox

if [ "$SPREE_AUTH_DEVISE_PATH" != "" ]; then
  SPREE_AUTH_DEVISE_GEM="gem 'spree_auth_devise', path: '$SPREE_AUTH_DEVISE_PATH'"
else
  SPREE_AUTH_DEVISE_GEM="gem 'spree_auth_devise', github: 'miscelatore/spree_auth_devise', branch: 'spree_auth_devise_nx'"
fi

if [ "$SPREE_GATEWAY_PATH" != "" ]; then
  SPREE_GATEWAY_GEM="gem 'spree_gateway', path: '$SPREE_GATEWAY_PATH'"
else
  SPREE_GATEWAY_GEM="gem 'spree_gateway', github: 'miscelatore/spree_gateway', branch: 'spree_gateway_nx'"
fi

if [ "$BETTER_SPREE_PAYPAL_EXPRESS_PATH" != "" ]; then
  BETTER_SPREE_PAYPAL_EXPRESS="gem 'spree_paypal_express', path: '$BETTER_SPREE_PAYPAL_EXPRESS_PATH'"
else
  BETTER_SPREE_PAYPAL_EXPRESS="gem 'spree_paypal_express', github: 'miscelatore/better_spree_paypal_express', branch: 'better_spree_paypal_express_nx'"
fi

if [ "$SPREE_HEADLESS" != "" ]; then
cat <<RUBY >> Gemfile
gem 'spree_core', github: 'miscelatore/spree_core', branch: 'spree_core_nx'
gem 'spree_api', github: 'miscelatore/spree_api', branch: 'spree_api_nx'
gem 'spree_backend', github: 'miscelatore/spree_backend', branch: 'spree_backend_nx'
gem 'spree_sample', github: 'miscelatore/spree_sample', branch: 'spree_sample_nx'
gem 'spree_cmd', github: 'miscelatore/spree_cmd', branch: 'spree_cmd_nx'

$SPREE_AUTH_DEVISE_GEM
$SPREE_GATEWAY_GEM
$BETTER_SPREE_PAYPAL_EXPRESS

gem 'spree_i18n', github: 'miscelatore/spree_i18n', branch: 'spree_i18n_nx'

group :test, :development do
  gem 'bullet'
  gem 'pry-byebug'
  gem 'awesome_print'
end

gem 'rack-cache'
RUBY
else
cat <<RUBY >> Gemfile
gem 'spree', github: 'miscelatore/spree_i18n', branch: 'spree_nx'
$SPREE_AUTH_DEVISE_GEM
$SPREE_GATEWAY_GEM
$BETTER_SPREE_PAYPAL_EXPRESS

gem 'spree_i18n', github: 'miscelatore/spree_i18n', branch: 'spree_i18n_nx'
gem 'spree_static_content', github: 'miscelatore/spree_static_content', branch: 'spree_static_content_nx'
gem 'spree_related_products', github: 'miscelatore/spree_related_products', branch: 'spree_related_products_nx'
# gem 'spree_multi_domain', github: 'miscelatore/spree-multi-domain', branch: 'spree_multi_domain_nx'

group :test, :development do
  gem 'bullet'
  gem 'pry-byebug'
  gem 'awesome_print'
end

# ExecJS runtime
gem 'mini_racer'

# temporary fix for sassc segfaults on ruby 3.0.0 on Mac OS Big Sur
# this change fixes the issue:
# https://github.com/sass/sassc-ruby/commit/04407faf6fbd400f1c9f72f752395e1dfa5865f7
gem 'sassc', github: 'sass/sassc-ruby', branch: 'master'

gem 'rack-cache'
RUBY
fi

cat <<RUBY >> config/environments/development.rb
Rails.application.config.hosts << /.*\.lvh\.me/
RUBY

bundle install --gemfile Gemfile
bundle exec rails db:drop || true
echo "#==========================================="
echo "# bundle exec rails db:create               "
echo "#==========================================="
bundle exec rails db:create
echo "#==========================================="
echo "# bundle exec rails g spree:install ...     "
echo "#==========================================="
bundle exec rails g spree:install --auto-accept --user_class=Spree::User --enforce_available_locales=true --copy_storefront=false
echo "#==========================================="
echo "# bundle exec rails g spree:mailers_preview "
echo "#==========================================="
bundle exec rails g spree:mailers_preview
bundle exec rails g spree:auth:install
bundle exec rails g spree_gateway:install
bundle exec rails g spree_paypal_express:install

if [ "$SPREE_HEADLESS" == "" ]; then
  bundle exec rails g spree_related_products:install
  bundle exec rails g spree_static_content:install
  # bundle exec rails g spree_multi_domain:install
  # Applied at this point for the problem reported at the following URL:
  # https://github.com/spree-contrib/spree_mail_settings/issues/55
  # cat <<RUBY >> Gemfile
  # gem 'spree_mail_settings', github: 'miscelatore/spree_mail_settings', branch: 'spree_mail_settings_nx'
#RUBY
fi