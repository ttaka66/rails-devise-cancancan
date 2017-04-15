class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # jsonでのリクエストの場合CSRFトークンの検証をスキップ
  skip_before_action :verify_authenticity_token, if: -> {request.format.json?}
end
