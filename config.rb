require 'singleton'

class Config
  attr_accessor :invaders, :noise_threshold, :allowed_points

  def initialize
    @invaders = []
    @noise_threshold = 0
    @allowed_points = {
      invader: ['o', '-'],
      sample: ['o', '-', 'O']
    }
  end

  def self.configure
    yield new
  end
end
