#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'bundler'
Bundler.require

threshold = 20

client = Tw::Client.new
client.auth

tweets = client.user_timeline('shokai_log').select{|m|
  Time.now - m.time < 60*60
}.sort{|a,b|
  b.time <=> a.time
}.map{|m|
  JSON.parse m.text rescue nil
}.select{|m|
  m.kind_of? Hash and [Fixnum, Float].include? m["気温"].class
}

p tweets

if tweets.empty?
  STDERR.puts '温度がわかりません、エラーっぽいです'
  system 'saykana おんどがわかりません、えらーっぽいです'
  exit 1
end

temp = tweets[0]["気温"]
puts "現在の気温 #{temp}度"
system "saykana 'げんざいのきおん'"
sleep 0.5
system "saykana '#{temp.to_i}ど'"
exit unless temp < threshold

sleep 0.5
system 'saykana おからだにさわりますよ'

