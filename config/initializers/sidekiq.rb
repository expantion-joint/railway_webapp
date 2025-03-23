Sidekiq.configure_server do |config|
	config.redis = { url: ENV.fetch('REDIS_URL', 'redis://rails-redis-railway:6379/0') }

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
  