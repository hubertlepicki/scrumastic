# encoding: UTF-8
require File.join(File.dirname(__FILE__), 'acceptance_helper')

feature "User registration", %q{
  In order to use Scrumastic
  As a new user
  I want to be able to register
} do
  
  scenario "Successful registration" do
    visit homepage
    click_button "Sign up"
    fill_in "Name", with: "Hubert Łępicki"
    fill_in "Nickname (can consist only of lowercase letters)", with: "hubert"
    fill_in "Email", with: "hubert.lepicki@gmail.com"
    fill_in "Password", with: "abcd1234"
    fill_in "Password confirmation", with: "abcd1234"
    within(:css, "form.registration") do
      click_button "Sign up"
    end

    User.count.should eql(1)
    page.should have_content(I18n.t("devise.registrations.signed_up"))

    confirmation_url = ActionMailer::Base.deliveries.last.body.match(/http:\/\/localhost:9887(.*)">C/)[0][0..-4]
    visit confirmation_url
    page.should have_content(I18n.t("devise.confirmations.confirmed"))
  end

  scenario "Failed registration" do
    visit homepage
    click_button "Sign up"
    within(:css, "form.registration") do
      click_button "Sign up"
    end

    User.count.should eql(0)
    page.should have_content("Email can't be blank")
    page.should have_content("Nickname can't be blank")
    page.should have_content("Name can't be blank")
    page.should have_content("Password can't be blank")
  end
end
