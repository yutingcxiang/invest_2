class SessionsController < ApplicationController
  def new
  end

  def create
    if auth_hash
      @user = User.find_or_create_by(uid: auth['uid']) do |u|
        u.username = auth['info']['name']
        u.email = auth['info']['email']
        u.password = SecureRandom.hex
      end
      session[:user_id] = @user.id
      redirect_to user_path(@user.id)
    else
      @user = User.find_by(username: params[:username])
      if @user && @user.authenticate(params[:password])
        session[:user_id] = @user.id
        redirect_to user_path(@user.id)
      else
        flash[:notice] = "Invalid username or password. Please try again."
        redirect_to signin_path
      end
    end
  end

  def destroy
    session.clear
    redirect_to root_path
  end

  private

  def auth
    request.env['omniauth.auth']
  end
end
