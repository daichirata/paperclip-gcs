module Paperclip
  module Storage
    module Gcs
      module CredentialsResolver
        module_function

        def resolve(credentials)
          cred = case credentials
                 when File
                   YAML.load(ERB.new(File.read(credentials.path)).result)
                 when String, Pathname
                   YAML.load(ERB.new(File.read(credentials)).result)
                 when Hash
                   credentials
                 when NilClass
                   {}
                 else
                   raise ArgumentError, ":gcs_credentials is not a path, file, nor a hash"
                 end
          (cred.stringify_keys[env] || cred).symbolize_keys
        end

        def env
          (defined?(Rails) ? Rails.env : nil).to_s
        end
      end
    end
  end
end
