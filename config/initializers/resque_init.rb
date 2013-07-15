rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'
resque_config = YAML.load_file(rails_root + '/config/resque.yml')
Resque.redis = Redis.new(:host => resque_config[rails_env].split(':')[0], :port => resque_config[rails_env].split(':')[1], :timeout => 30)
require 'resque_scheduler'
Resque.schedule = YAML.load_file(File.join(rails_root, 'config/resque_schedule.yml'))
require "resqueable"
Dir[File.join(rails_root, "lib", "resque", "*.rb")].each {|f| require f }
require 'resque-retry'
require 'resque-retry/server'
require 'resque/failure/redis'
Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression
