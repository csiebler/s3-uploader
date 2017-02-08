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

get '/load/:marker' do |marker|
    @objects = []
    response = s3.list_objects({bucket: S3_BUCKET_NAME, max_keys: 25, marker: marker})
    response.contents.each do |o|
      @objects << {key: o.key, size: (o.size / 1048576.0).round(1), 
                   date: o.last_modified,
                   id: Base64.strict_encode64(o.key)}
    end
    haml :files
end

post "/upload" do
  #TODO Check if object already exists
  #TODO Forward to error message if upload failed
  key = params['file'][:filename]
  s3.put_object({bucket: S3_BUCKET_NAME, key: key, body: params['file'][:tempfile].read})
  redirect to('/')
end

get "/download/:id" do |id|
  key = Base64.strict_decode64(id)
  url = signer.presigned_url(:get_object, bucket: S3_BUCKET_NAME, key: key,
                             expires_in: 30, response_content_disposition: 'attachment') 
  redirect to(url)
end