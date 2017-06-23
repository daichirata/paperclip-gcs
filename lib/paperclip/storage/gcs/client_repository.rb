module Paperclip
  module Storage
    module Gcs
      class ClientRepository
        include Singleton

        CACHE_KEY = self.class.name.freeze

        def self.find(config)
          instance.find(config)
        end

        def find(config)
          clients[config] ||= Google::Cloud.storage(
            config[:project],
            config[:keyfile],
            config.slice(:scope, :retries, :timeout)
          )
        end

        private

        def clients
          Thread.current[CACHE_KEY] ||= {}
        end
      end
    end
  end
end
