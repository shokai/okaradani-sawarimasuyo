#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'bundler'
Bundler.require

parser = ArgsParser.parse ARGV do
  arg :threshold, 'temperature threshold', :default => 20
  arg :twitter_user, 'twitter username', :alias => :twitter
  arg :say_path, 'say command path', :alias => :say, :default => `which say`.strip
  arg :help, 'show help', :alias => :h
end

if parser.has_option? :help or !parser.has_param? :twitter_user
  STDERR.puts parser.help
  STDERR.puts
  STDERR.puts "e.g.  #{$0} --twitter shokai_log --threshold 20 --say /usr/local/bin/saykana"
  exit 1
end

client = Tw::Client.new
client.auth

tweets = client.user_timeline(parser[:twitter_user]).select{|m|
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
  system "#{parser[:say_path]} 'おんどがわかりません、えらーっぽいです'"
  exit 1
end

temp = tweets[0]["気温"]
puts "現在の気温 #{temp}度"
system "#{parser[:say_path]} 'げんざいのきおん'"
sleep 0.5
system "#{parser[:say_path]} '#{temp.to_i}ど'"
exit unless temp < parser[:threshold]

sleep 0.5
system "#{parser[:say_path]} 'おからだにさわりますよ'"

