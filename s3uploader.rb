require 'sinatra'
require 'aws-sdk'

S3_BUCKET_NAME = ENV['S3_BUCKET_NAME']

client = Aws::S3::Client.new(region: 'us-east-1', endpoint: ENV['S3_ENDPOINT'],
                             force_path_style: true, ssl_verify_peer: false)
s3 = Aws::S3::Resource.new(client: client)

get "/" do
  @objects = []
  s3.bucket(S3_BUCKET_NAME).objects.each do |object|
    @objects << {:key => object.key, :size => object.size}
  end

  haml :index
end

post "/upload" do
  key = params['file'][:filename]
  #TODO Check if object already exists
  s3.bucket(S3_BUCKET_NAME).object(key).put(body: params['file'][:tempfile].read)
  #TODO Forward to error message if upload failed

  redirect to('/')
end