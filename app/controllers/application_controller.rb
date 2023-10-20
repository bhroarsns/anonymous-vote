class ApplicationController < ActionController::Base
  include Pundit::Authorization
  require 'csv'
end
