class SessionsController < ApplicationController

  skip_before_filter :login_required!

  def new
  end

  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      flash[:notice] = "Logged in!"
      redirect_to root_url
    else
      flash.now[:error] = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end
