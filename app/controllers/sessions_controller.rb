class SessionsController < Devise::SessionsController
  respond_to :json

  def create
    self.resource = warden.authenticate!(auth_options)
  end

  private

  def respond_with_old(resource, _opts = {})
    render json: resource
  end

  def respond_to_on_destroy_old
    head :no_content
  end

end