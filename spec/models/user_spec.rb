# encoding: UTF-8

require 'spec_helper'

# Authentication is done with well-tested Devise, so won't test here.
describe "User" do
  it "should have gravatar" do
    user = User.create!(name: "Hubert Łępicki",
                        email: "hubert.lepicki@gmail.com",
                        password: "test1234a", password_confirmation: "test1234a"
                       )
    user.gravatar_url.should eql("http://gravatar.com/avatar/6bf9328eef0afadd9c9d05334f8dd42b.png?r=PG")
  end
end

