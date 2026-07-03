# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "stellwerk"

require "minitest/autorun"
require "mocha/minitest"

require_relative "support/fake_reference"
