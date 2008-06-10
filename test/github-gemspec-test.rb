#!/usr/bin/env ruby

# This file simulates the environment railsdb.gemspec has to run in on github

require 'rubygems/specification'
data = File.read( File.dirname( __FILE__ ) + '/../railsdb.gemspec' )
spec = nil
Thread.new { spec = eval("$SAFE = 3\n#{data}") }.join
puts spec
