class HelloController < ApplicationController
  def index
    authorize! :read, :hello
    respond_to do |format|
      format.html { render text: 'hello' }
      format.json { render json: {hello: 'hello'} }
    end
  end
end
