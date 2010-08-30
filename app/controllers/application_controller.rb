# encoding: UTF-8

# Base controller for all other controllers.
class ApplicationController < ActionController::Base
  protect_from_forgery  
  before_filter :ensure_utf8_params
  before_filter :set_layout
#  before_filter :localize
  
  rescue_from ::PermissionDenied, :with => :permission_denied
  
  protected
  
  # Ensures that params contains only UTF8. There is brutal conversion of encodings
  # taking place. This is needed because Rack doesn't detect encoding here.
  def ensure_utf8_params(hash = nil)
    hash = params if hash.nil?
    hash.each do |k,v|
      if v.kind_of?(Hash)
        ensure_utf8_params(v)
      elsif v.kind_of?(String)
        hash[k] = v.force_encoding('UTF-8')
      end
    end
  end

  # Render nice permission denied information
  def permission_denied
    respond_to do |format|
      format.html { render :template => "shared/forbidden", :status => :forbidden }
      format.any  { head :forbidden }
    end
  end

  # Sets layout for all requests except XHR (Ajax) ones.
  def set_layout
    if request.xhr?
      self.class.layout false
    else
      self.class.layout "application"
    end
  end

#  def localize
#    I18n.locale = "pl"
#  end
end
