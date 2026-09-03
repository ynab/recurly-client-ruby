$LOAD_PATH.unshift lib = File.expand_path('../../lib', __FILE__)

require 'stringio'
old_stderr, $stderr = $stderr, StringIO.new
at_exit do
  # Warnings from anywhere but lib are noise, but suppressing them unconditionally
  # also swallows load errors and leaves a failing run with no output at all.
  failing = !$!.nil? && !($!.is_a?(SystemExit) && $!.success?)
  buffered, $stderr = $stderr, old_stderr
  buffered.rewind
  buffered.each_line { |line| old_stderr.puts line if failing || line.include?(lib) }
end

case ENV['XML']
  when 'nokogiri' then require 'nokogiri'
end

require 'recurly_v2'
include RecurlyV2
