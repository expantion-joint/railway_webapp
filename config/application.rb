require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Src
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # 追加
    config.i18n.default_locale = :ja
    config.time_zone = "Tokyo"
    
    # 追加 Active Job のキューアダプターを設定
    config.active_job.queue_adapter = :sidekiq
    Sidekiq.configure_server do |config|
      config.redis = { url: ENV.fetch('REDIS_URL', 'redis://rails-redis-railway:6379/0') }
      # 定期的に非同期実行するための設定
      config.on(:startup) do
        schedule_file = "config/sidekiq.yml"
    
        if File.exist?(schedule_file)
          Sidekiq::Scheduler.reload_schedule!
        end
      end
    end

    Sidekiq.configure_client do |config|
      config.redis = { url: ENV.fetch('REDIS_URL', 'redis://rails-redis-railway:6379/0') }
    end


    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
