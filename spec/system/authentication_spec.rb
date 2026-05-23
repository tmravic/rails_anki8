# spec/system/authentication_spec.rb
require 'rails_helper'

RSpec.describe 'Authentication' do
  fixtures :all

  it 'redirects unauthenticated users to the login page and shows the sign-in form' do
    visit root_path

    # We expect to be redirected to the login page
    expect(page).to have_current_path(new_session_path)

    # Check the login form elements
    expect(page).to have_field('email_address')
    expect(page).to have_field('password')
    expect(page).to have_button('Sign in')
    expect(page).to have_link('Forgot password?')
    sleep 1
    fill_in "email_address", with: "john@company.com"
    fill_in "password", with: "123456"
    click_button "Sign in"
    sleep 1
    expect(page).to have_current_path(root_path)
    sleep 1
  end
end
