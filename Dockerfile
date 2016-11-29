FROM ruby:alpine
MAINTAINER Clemens Siebler <clemens.siebler@gmail.com>

RUN gem install sinatra shotgun haml aws-sdk

RUN mkdir /app
COPY / /app/

EXPOSE 8080
ENTRYPOINT ["shotgun", "--host", "0.0.0.0", "--port", "8080", "/app/s3uploader.rb"]
