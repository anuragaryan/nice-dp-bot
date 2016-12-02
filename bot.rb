#!/usr/bin/env ruby

require 'Twitter'
require 'nokogiri'
require 'net/http'

while true
  begin
    config = {
      consumer_key:        'o6rFg3HSQ4hOEfLl2JarRyJVi',
      consumer_secret:     'APS94iaHY6zzfb0GJOkovFkqekG7U3ba6NWvPBwCO9feaLonaZ',
      access_token:        '804771446589300736-zXvkZuOuLBy6WC5MVRbuxJGIxwjMBYY',
      access_token_secret: 'DtSTESRfSWfAOgTRrvx0B5mCoXaJwMhPJ74ZacV0gCNg0'
    }
    my_username = 'NiceDpBot'
    rClient = Twitter::REST::Client.new config
    sClient = Twitter::Streaming::Client.new(config)

    #This is to thank everyone who follows.
    #sClient.user do |object|
    #if object.is_a? Twitter::Streaming::Event and object.name==:follow
    #user = object.source
    #if user.screen_name != my_username
    #rClient.update("@#{user.screen_name} Thanks for following me #{user.name} :)")
    #rClient.follow("#{user.screen_name}")
    #puts "New follower : #{object.source.name}"
    #end
    #end
    #end


    puts "Following and thanking done"
    #This is to actually check who changed their dp.
    response = Net::HTTP.get_response(URI.parse("http://bioischanged.com/feed/AnuragKnows/Jgx0FBdrJdnU3q1Ge4Xqenc5b0tjLFR8"))
    doc = Nokogiri::XML(response.body)
    first_time_stamp = doc.xpath('//item').first.xpath('link').text[-8..-1]
    first_screen_name = doc.xpath('//item').first.xpath('title').text.split.first
    last_time_stamp = doc.xpath('//item').last.xpath('link').text[-8..-1]
    last_screen_name = doc.xpath('//item').last.xpath('title').text.split.first
    while true
      puts "first - #{first_time_stamp}-#{first_screen_name}       ///////      last - #{last_time_stamp}-#{last_screen_name}"
      doc.xpath('//item').each do |item|
        response = Net::HTTP.get_response(URI.parse("http://bioischanged.com/feed/AnuragKnows/Jgx0FBdrJdnU3q1Ge4Xqenc5b0tjLFR8"))
        doc = Nokogiri::XML(response.body)
        temp_screen_name = item.xpath('title').text.split.first
        temp_time_stamp = item.xpath('link').text[-8..-1]
        if(temp_screen_name == last_screen_name && temp_time_stamp == last_time_stamp)
          last_time_stamp = first_time_stamp
          last_screen_name = first_screen_name
          break
        else
          puts "#{temp_screen_name} - #{temp_time_stamp}"
        end
      end
      sleep 30
    end

    sleep 30

    # topics to watch
    #topics = ['#rails', '#ruby', '#coding', '#codepen']
    #sClient.filter(:track => topics.join(',')) do |tweet|
    #if tweet.is_a?(Twitter::Tweet)
    #puts tweet.text 
    #rClient.fav tweet
    #end
    #end
  rescue => e
    puts e
    puts 'error occurred, waiting for 5 seconds'
    sleep 5
  end

end
