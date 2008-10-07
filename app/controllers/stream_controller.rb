class StreamController < ApplicationController
  %w{join part disconnect}.each do |action|
    define_method(action) do
      render :text => ""
    end
  end
  
  def join
    session = session_data_by_id(params[:session_id])
    unless session && session[:user_id] == params[:client_id]
      render :text => "403", :status => 403
    end
  end
end