#!/usr/bin/env ruby

require 'faker'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql2",
  :host     => "myinstance01.cgic5q3lz0bb.us-east-1.rds.amazonaws.com",
  :username => "master",
  :password => "Kew2401Sd",
  :database => "awslambdaruby"
)

class User < ActiveRecord::Base
end

puts "Number of users: #{User.count}"
puts "First user: #{User.first.firstname} #{User.first.lastname}"
puts "Hello - '#{Faker::Name.name}' from Ruby!"
