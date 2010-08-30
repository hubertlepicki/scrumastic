# encoding: UTF-8

class AuthenticatedController < ApplicationController
  before_filter :authenticate_user!
end