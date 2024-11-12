require "google/cloud/storage"

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
          clients[config] ||= Google::Cloud::Storage.new(
            project_id: config[:project],
            credentials: config[:keyfile],
            endpoint: config[:gcs_host_name],
            **config.slice(:scope, :retries, :timeout)
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
