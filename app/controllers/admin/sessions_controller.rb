class Admin::SessionsController < ApplicationController

  def impersonate
    flash[:notice] = "Welcome to this users account #{params[:id]}"
    session[:original_user_id] = session[:user_id]
    session[:user_id] = params[:id]
    redirect_to '/'
  end

end
