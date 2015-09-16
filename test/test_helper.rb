require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'minitest/autorun'

require 'minitest/reporters'
Minitest::Reporters.use!

require 'juris_privacy'
