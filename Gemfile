source "http://rubygems.org"

gem "htmlentities", ">= 4.3.1"
gem "rspec", '2.5.0'
gem "rake"
gem "curb"

platforms :ruby_18 do
  # Needs libonig-dev debian/ubuntu package
  gem "oniguruma", ">=1.1.0"
end

group :development do
  gem 'webmock', '~>1.8.9'
  gem 'vcr', '~>2.2.4'
end
