class HelloController < ApplicationController
  # authorize_resource
  def index
    authorize! :read, :hello
    render text: "hello"
  end
end
