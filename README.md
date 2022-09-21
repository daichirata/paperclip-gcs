# paperclip-gcs

paperclip-gcs is a Paperclip storage driver for storing files in a Google Cloud Storage.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'paperclip-gcs'
```

And then execute:

``` shell
$ bundle
```

Or install it yourself as:

``` shell
$ gem install paperclip-gcs
```

## Usage

The GCS storage engine has been developed to work as similarly to S3 storage configuration as is possible. This gem can be configured in a Paperclip initializer as follows:

``` ruby
Paperclip::Attachment.default_options[:storage] = :gcs
Paperclip::Attachment.default_options[:gcs_bucket] = "your-bucket"
Paperclip::Attachment.default_options[:url] = ":gcs_path_url"
Paperclip::Attachment.default_options[:path] = ":class/:attachment/:id/:style/:filename"
Paperclip::Attachment.default_options[:gcs_credentials] = {
    project: ENV["GCS_PROJECT"],
    keyfile: ENV["GCS_KEYFILE"],
}

```

Or, at the level of the model such as in the following example:

``` ruby
has_attached_file :avatar,
  storage: :gcs,
  gcs_bucket: "your-bucket",
  gcs_credentials: {
    project: "your-project",
    keyfile: "path/to/your/keyfile",
  }
```

See also http://www.rubydoc.info/gems/paperclip/Paperclip/Storage/S3

## Configuration

### gcs_bucket

GCS bucket name.

### gcs_credentials

You can provide the project and credential information to connect to the Storage service, or if you are running on Google Compute Engine this configuration is taken care of for you.

#### project

Project identifier for GCS. Project are discovered in the following order:

* Specify project in `project`
* Discover project in environment variables `STORAGE_PROJECT`, `GOOGLE_CLOUD_PROJECT`, `GCLOUD_PROJECT`
* Discover GCE credentials

#### keyfile

Path of GCS service account credentials JSON file. Credentials are discovered in the following order:

* Specify credentials path in `keyfile`
* Discover credentials path in environment variables `GOOGLE_CLOUD_KEYFILE`, `GCLOUD_KEYFILE`
* Discover credentials JSON in environment variables `GOOGLE_CLOUD_KEYFILE_JSON`, `GCLOUD_KEYFILE_JSON`
* Discover credentials file in the Cloud SDK's path
* Discover GCE credentials

#### bucket (optional)

Here you can specify the GCS bucket name. If `gcs_bucket` also has a bucket specification, the value of` gcs_bucket` will be used.

### gcs_options

#### retries

Number of times to retry requests on server error.

#### timeout

Default timeout to use in requests.

### gcs_protocol

The protocol for the URLs generated to your GCS assets. Can be either 'http', 'https', or an empty string to generate protocol-relative URLs. Defaults to empty string.

### gcs_host_alias

The fully-qualified domain name (FQDN) that is the alias to the GCS domain of your bucket. Used with the :gcs_alias_url url interpolation. See the link in the url entry for more information about GCS domains and buckets.

### gcs_host_name

If you are using a bucket in a custom domain, write host_name.

### gcs_encryption_key

You can also choose to provide your own AES-256 key for server-side encryption. See also [Customer-supplied encryption keys](https://cloud.google.com/storage/docs/encryption#customer-supplied).

### gcs_metadata

User provided web-safe keys and arbitrary string values that will returned with requests for the file as "x-goog-meta-" response headers.

You can set metadata on a per style bases by doing the following:

``` ruby
gcs_metadata: {
  thumb: { "foo" => "bar" }
}
```

Or globally:

``` ruby
gcs_metadata: { "foo" => "bar" }
```

### gcs_permissions

Permission for the object in GCS. Acceptable values are:

* `auth_read`       - File owner gets OWNER access, and allAuthenticatedUsers get READER access.
* `owner_full`      - File owner gets OWNER access, and project team owners get OWNER access.
* `owner_read`      - File owner gets OWNER access, and project team owners get READER access.
* `private`         - File owner gets OWNER access.
* `project_private` - File owner gets OWNER access, and project team members get access according to their roles.
* `public_read`     - File owner gets OWNER access, and allUsers get READER access.

Default is nil (bucket default object ACL). See also [official document](https://cloud.google.com/storage/docs/access-control/lists).

You can set permissions on a per style bases by doing the following:

``` ruby
gcs_permissions: {
  thumb: :public_read
}
```

Or globally:

``` ruby
gcs_permissions: :public_read
```

### gcs_storage_class

Storage class of the file. Acceptable values are:

* `dra`            - Durable Reduced Availability
* `nearline`       - Nearline Storage
* `coldline`       - Coldline Storage
* `multi_regional` - Multi-Regional Storage
* `regional`       - Regional Storage
* `standard`       - Standard Storage

You can set storage class on a per style bases by doing the following:

``` ruby
gcs_storage_class: {
  thumb: :multi_regional
}
```

Or globally:

``` ruby
gcs_storage_class: :multi_regional
```

### gcs_cache_control

The Cache-Control metadata allows you to control whether and for how long browser and Internet caches are allowed to cache your objects.

### gcs_content_disposition

The Content-Disposition metadata allows you to specify the presentation of the object in the browser.

### gcs_content_type

The Content-Type metadata allows you to specify the content type of the object. By default it will use the file content type.

### Interpolates

#### :gcs_alias_url

``` ruby
"#{attachment.gcs_protocol}//#{attachment.gcs_host_alias}/#{attachment.path(style)}"
```

#### :gcs_path_url

``` ruby
"#{attachment.gcs_protocol}//#{attachment.gcs_host_name}/#{attachment.gcs_bucket_name}/#{attachment.path(style)}"
```

#### :gcs_domain_url

``` ruby
"#{attachment.gcs_protocol}//#{attachment.gcs_bucket_name}.#{attachment.gcs_host_name}/#{attachment.path(style)}"
```

#### :asset_host

``` ruby
"#{attachment.path(style)}"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/daichirata/paperclip-gcs.
