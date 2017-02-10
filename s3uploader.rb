require 'sinatra'
require 'aws-sdk'

S3_BUCKET_NAME = ENV['S3_BUCKET_NAME']
S3_ENDPOINT = ENV['S3_ENDPOINT']

s3 = Aws::S3::Client.new(region: 'us-east-1', endpoint: S3_ENDPOINT,
                             force_path_style: true, ssl_verify_peer: false)
signer = Aws::S3::Presigner.new({client: s3})

get "/" do
  haml :index
end

get "/versioning" do
  s3.get_bucket_versioning({bucket: S3_BUCKET_NAME}).status
end

get '/load/:id' do |id|
    key = decode(id)
    @objects = []
    response = s3.list_objects({bucket: S3_BUCKET_NAME, max_keys: 25, marker: key})
    response.contents.each do |o|
      @objects << {key: o.key, size: size_in_mb(o.size), 
                   date: o.last_modified, id: encode(o.key)}
    end
    haml :files
end

post "/upload" do
  #TODO Forward to error message if upload failed
  key = params['file'][:filename]
  s3.put_object({bucket: S3_BUCKET_NAME, key: key, body: params['file'][:tempfile].read})
  redirect to('/')
end

get "/:id/download" do |id|
  key = decode(id)
  url = signer.presigned_url(:get_object, bucket: S3_BUCKET_NAME, key: key,
                             expires_in: 30, response_content_disposition: 'attachment') 
  redirect to(url)
end

get "/:id/download/:version" do |id, version|
  key = decode(id)
  url = signer.presigned_url(:get_object, bucket: S3_BUCKET_NAME, key: key, version_id: version,
                             expires_in: 30, response_content_disposition: 'attachment') 
  redirect to(url)
end

get "/:id/versions" do |id|
  key = decode(id)
  @objects = []
  response = s3.list_object_versions({bucket: S3_BUCKET_NAME, prefix: key})
  # TODO Remove isLatest
  response.versions.each do |o|
    @objects << {key: o.key, size: size_in_mb(o.size),
                 date: o.last_modified, version: o.version_id, id: encode(o.key)}
  end
  haml :versions
end

def size_in_mb(value)
  (value / 1048576.0).round(1)
end

def encode(value)
  Base64.strict_encode64(value)
end

def decode(value)
  Base64.strict_decode64(value)
end