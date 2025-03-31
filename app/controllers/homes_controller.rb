class HomesController < ApplicationController

  skip_before_action :authenticate_user!

  def index
    render :index
  end

  def policy
    render :policy
  end

  def terms
    render :terms
  end

  def tokushoho
    render :tokushoho
  end
  
end
