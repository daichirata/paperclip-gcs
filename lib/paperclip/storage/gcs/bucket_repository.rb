require "singleton"

module Paperclip
  module Storage
    module Gcs
      class BucketRepository
        include Singleton

        CACHE_KEY = self.class.name.freeze

        def self.find(client, bucket_name)
          instance.find(client, bucket_name)
        end

        def find(client, bucket_name)
          buckets[[client, bucket_name]] ||= client.bucket(bucket_name)
        end

        private

        def buckets
          Thread.current[CACHE_KEY] ||= {}
        end
      end
    end
  end
end
