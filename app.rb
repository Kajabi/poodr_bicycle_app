require "rails"
require "active_model"
require "action_controller/railtie"

class App < Rails::Application
  config.consider_all_requests_local = true
  config.eager_load = false
  config.logger = Rails.logger = Logger.new(STDOUT)

  routes.append do
    root to: "bicycle#index"
    get "calculate" => "bicycle#calculate"
  end
end

# Controllers

class BicycleController < ActionController::Base
  def index
    @gear  = Gear.new(20, 5)
    @wheel = Wheel.new(21.5, 3)
  end

  def calculate
    @gear  = Gear.new(params[:gear][:chainring].to_f, params[:gear][:cog].to_f)
    @wheel = Wheel.new(params[:wheel][:rim].to_f, params[:wheel][:tire].to_f)

    render :index
  end
end

# Models (POROs from POODR Ch. 2)

class Gear
  attr_reader :chainring, :cog, :wheel

  def initialize(chainring, cog, wheel = nil)
    @chainring = chainring
    @cog       = cog
    @wheel     = wheel
  end

  def ratio
    chainring / cog.to_f
  end

  def gear_inches
    ratio * wheel.diameter
  end
end

class Wheel
  attr_reader :rim, :tire

  def initialize(rim, tire)
    @rim  = rim
    @tire = tire
  end

  def diameter
    rim + (tire * 2)
  end

  def circumference
    diameter * Math::PI
  end
end

# So these POROs work in `form_with`
[Gear, Wheel].each { |klass| klass.send :include, ActiveModel::Model }
