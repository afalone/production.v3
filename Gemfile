source 'http://rubygems.org'

gem 'rails', '3.0.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'


# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'
gem "andand"
gem "resque"
gem "fastercsv"
gem "resque-retry"
gem "resque-scheduler"
gem "state_machine"
gem "passenger"

gem "nokogiri"
gem 'pg', "~>0.9.0"
gem "will_paginate", "~>3.0.pre2"
#, :git => "http://github.com/mislav/will_paginate.git", :branch => "rails3"
platforms :mri do
  gem "haml"
  gem "haml-rails"
  gem "simple_form"
  gem "jquery-rails"
  gem 'pdf-toolkit', :require => 'pdf/toolkit'
  gem "rmagick", :require => 'RMagick'
end

platforms :mswin do

  #at win machines install nothing
end
# To use debugger
# gem 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
 group :development, :test do
   gem "factory_girl"
   gem "cucumber"
   gem "cucumber-rails"
   gem "rspec", "~>2.2.0"
   gem "rspec-rails", "~>2.2.0"
   gem "resque_spec"
   gem 'webrat'
   gem "bullet"
   #gem "relevance-rcov"
 end

gem 'hoptoad_notifier', "~>2.4.2"
