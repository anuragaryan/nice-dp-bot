#!/usr/bin/env ruby

require 'twitter'
require 'nokogiri'
require 'net/http'
require 'thread'
require 'dotenv'
Dotenv.load

puts "Starting...."

main_thread = Thread.new do
  puts "Inside main thread"
  loop do
    begin
      config = {
        consumer_key: ENV["CONSUMER_KEY"],
        consumer_secret: ENV["CONSUMER_SECRET"],
        access_token: ENV["ACCESS_TOKEN"],
        access_token_secret: ENV["ACCESS_TOKEN_SECRET"]
      }
      my_username = 'NiceDpBot'
      rClient = Twitter::REST::Client.new config
      sClient = Twitter::Streaming::Client.new(config)

      #This is to thank everyone who follows.
      follow_thread = Thread.new do
        puts "Inside first thread"
        loop do
          begin
            puts "Following and thanking"
            sClient.user do |object|
              if object.is_a? Twitter::Streaming::Event and object.name==:follow
                user = object.source
                if user.screen_name != my_username
                  rClient.update("@#{user.screen_name} Thanks for following me #{user.name} :)")
                  rClient.follow("#{user.screen_name}")
                  puts "New follower : #{object.source.name}"
                end
              end
            end
          rescue => e
            puts e
            puts 'error occurred, waiting for 30 seconds'
            sleep 30
          end
        end
      end

      #This is to actually check who changed their dp.

      BIOISCHANGED_URL = ENV["BIOISCHANGED_URL"]
      response_first = Net::HTTP.get_response(URI.parse(BIOISCHANGED_URL))
      doc_first = Nokogiri::XML(response_first.body)
      first_time_stamp = doc_first.xpath('//item').first.xpath('link').text[-8..-1]
      first_screen_name = doc_first.xpath('//item').first.xpath('title').text.split.first
      last_time_stamp = doc_first.xpath('//item').last.xpath('link').text[-8..-1]
      last_screen_name = doc_first.xpath('//item').last.xpath('title').text.split.first

      reply_thread = Thread.new do
        puts "Inside second thread"
        loop do
          begin
            puts "first - #{first_time_stamp}-#{first_screen_name}       ///////      last - #{last_time_stamp}-#{last_screen_name}"
            response = Net::HTTP.get_response(URI.parse(BIOISCHANGED_URL))
            doc_recent = Nokogiri::XML(response.body)
            doc_recent.xpath('//item').each do |item|
              first_time_stamp = doc_recent.xpath('//item').first.xpath('link').text[-8..-1]
              first_screen_name = doc_recent.xpath('//item').first.xpath('title').text.split.first
              temp_screen_name = item.xpath('title').text.split.first
              temp_time_stamp = item.xpath('link').text[-8..-1]
              if(temp_screen_name == last_screen_name && temp_time_stamp == last_time_stamp)
                last_time_stamp = first_time_stamp
                last_screen_name = first_screen_name
                break
              else
                puts "#{temp_screen_name} - #{temp_time_stamp}"
                rClient.update("@#{temp_screen_name} Hey, Nice DP.")
                sleep 5
              end
            end
            sleep 120
          rescue => e
            puts e
            puts 'error occurred, waiting for 30 seconds'
            sleep 30
          end
        end
      end

      sleep 30

    rescue => e
      puts e
      puts 'error occurred, waiting for 5 seconds'
      sleep 5
    end
    follow_thread.join
    reply_thread.join
  end
end

main_thread.join
