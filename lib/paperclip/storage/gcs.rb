require "google-cloud-storage"

require "paperclip/gcs/version"
require "paperclip/storage/gcs/bucket_repository"
require "paperclip/storage/gcs/client_repository"
require "paperclip/storage/gcs/credentials_resolver"

module Paperclip
  module Storage
    module Gcs
      DEFAULT_GCS_HOST_NAME = "storage.googleapis.com"

      def self.extended(base)
        base.instance_eval do
          @gcs_options        = @options[:gcs_options] || {}
          @gcs_credentials    = @options[:gcs_credentials]
          @gcs_bucket_name    = @options[:gcs_bucket]
          @gcs_protocol       = @options[:gcs_protocol]
          @gcs_host_alias     = @options[:gcs_host_alias]
          @gcs_host_name      = @options[:gcs_host_name]
          @gcs_encryption_key = @options[:gcs_encryption_key]
          @gcs_metadata       = normalize_style(@options[:gcs_metadata])
          @gcs_permissions    = normalize_style(@options[:gcs_permissions])
          @gcs_storage_class  = normalize_style(@options[:gcs_storage_class])
          @gcs_cache_control  = normalize_style(@options[:gcs_cache_control])
          @gcs_content_type   = normalize_style(@options[:gcs_content_type])
          @gcs_content_disposition = normalize_style(@options[:gcs_content_disposition])

          unless @options[:url].to_s.match(%r{\A:gcs_(alias|path|domain)_url\z}) || @options[:url] == ":asset_host".freeze
            @options[:path] = path_option.gsub(/:url/, @options[:url]).sub(%r{\A:rails_root/public/system}, "".freeze)
            @options[:url] = ":gcs_path_url".freeze
          end
        end

        Paperclip.interpolates(:gcs_alias_url) do |attachment, style|
          "#{attachment.gcs_protocol}//#{attachment.gcs_host_alias}/#{attachment.path(style)}"
        end unless Paperclip::Interpolations.respond_to?(:gcs_alias_url)

        Paperclip.interpolates(:gcs_path_url) do |attachment, style|
          "#{attachment.gcs_protocol}//#{attachment.gcs_host_name}/#{attachment.gcs_bucket_name}/#{attachment.path(style)}"
        end unless Paperclip::Interpolations.respond_to?(:gcs_path_url)

        Paperclip.interpolates(:gcs_domain_url) do |attachment, style|
          "#{attachment.gcs_protocol}//#{attachment.gcs_bucket_name}.#{attachment.gcs_host_name}/#{attachment.path(style)}"
        end unless Paperclip::Interpolations.respond_to?(:gcs_domain_url)

        Paperclip.interpolates(:asset_host) do |attachment, style|
          "#{attachment.path(style)}"
        end unless Paperclip::Interpolations.respond_to?(:asset_host)
      end

      def expiring_url(time = 3600, style = default_style)
        if file_path = path(style)
          gcs_bucket.signed_url(file_path, expires: time)
        else
          url(style)
        end
      end

      def exists?(style = default_style)
        if original_filename
          gcs_bucket.find_file(path(style))
        else
          false
        end
      rescue Google::Cloud::Error
        false
      end

      def flush_writes
        @queued_for_write.each do |style, file|
          log("saving #{path(style)}")

          opts = {
            content_type: gcs_content_type(file, style),
            content_disposition: gcs_content_disposition(style),
            cache_control: gcs_cache_control(style),
            encryption_key: gcs_encryption_key,
            acl: gcs_permissions(style),
            storage_class: gcs_storage_class(style),
            metadata: gcs_metadata(style),
          }
          gcs_bucket.upload_file(file.path, path(style), **opts)
        end
        after_flush_writes
        @queued_for_write = {}
      end

      def flush_deletes
        @queued_for_delete.each do |path|
          begin
            log("deleting #{path}")

            gcs_bucket.file(path).delete
          rescue Google::Cloud::Error
            # Ignore this.
          end
        end
        @queued_for_delete = []
      end

      def copy_to_local_file(style, local_dest_path)
        log("copying #{path(style)} to local file #{local_dest_path}")

        gcs_bucket.file(path(style)).download(local_dest_path, encryption_key: gcs_encryption_key)
      rescue Google::Cloud::Error => e
        warn("#{e} - cannot copy #{path(style)} to local file #{local_dest_path}")
        false
      end

      def gcs_protocol
        unwrap_proc(@gcs_protocol, self)
      end

      def gcs_host_alias
        unwrap_proc(@gcs_host_alias, self)
      end

      def gcs_host_name
        unwrap_proc(@gcs_host_name, self) || DEFAULT_GCS_HOST_NAME
      end

      def gcs_bucket_name
        (unwrap_proc(@gcs_bucket_name, self) || gcs_credentials[:bucket]) or
          raise ArgumentError, "missing required :gcs_bucket option"
      end

      private

      def normalize_style(opts)
        opts = { default: opts } unless opts.respond_to?(:merge)
        opts.merge(default: opts[:default])
      end

      def unwrap_proc(obj, *args)
        obj.respond_to?(:call) ? obj.call(*args) : obj
      end

      def gcs_encryption_key
        unwrap_proc(@gcs_encryption_key, self)
      end

      def gcs_permissions(style = default_style)
        unwrap_proc(@gcs_permissions[style] || @gcs_permissions[:default], self, style)
      end

      def gcs_content_type(file, style = default_style)
        unwrap_proc(@gcs_content_type[style] || @gcs_content_type[:default], self, style) || file.content_type
      end

      def gcs_content_disposition(style = default_style)
        unwrap_proc(@gcs_content_disposition[style] || @gcs_content_disposition[:default], self, style)
      end

      def gcs_storage_class(style = default_style)
        unwrap_proc(@gcs_storage_class[style] || @gcs_storage_class[:default], self, style)
      end

      def gcs_cache_control(style = default_style)
        unwrap_proc(@gcs_cache_control[style] || @gcs_cache_control[:default], self, style)
      end

      def gcs_metadata(style = default_style)
        unwrap_proc(@gcs_metadata[style] || @gcs_metadata[:default], self, style)
      end

      def gcs_credentials
        @_gcs_credentials ||= CredentialsResolver.resolve(unwrap_proc(@gcs_credentials, self))
      end

      def gcs_client
        @_gcs_client ||= ClientRepository.find(gcs_credentials.slice(:project, :keyfile).merge(
                                                 @gcs_options.slice(:scope, :retries, :timeout)))
      end

      def gcs_bucket
        @_gcs_bucket ||= BucketRepository.find(gcs_client, gcs_bucket_name)
      end
    end
  end
end
