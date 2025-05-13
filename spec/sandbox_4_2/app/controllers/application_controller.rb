# frozen_string_literal: true

# sandbox_controllers are eager loaded, see application.rb

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
end
