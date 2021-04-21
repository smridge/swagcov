# frozen_string_literal: true

class String
  COLORS = {
    red: 31,
    green: 32,
    yellow: 33,
    blue: 34
  }.freeze

  # returns bold colors
  COLORS.each_pair do |color, value|
    define_method(color) do
      "\e[1;#{value}m#{self}\e[0m"
    end
  end
end
