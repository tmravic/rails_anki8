require 'rails_helper'

RSpec.describe "Authentication" do
  it 'redirects unauthenticated users to login page and shows the sign-in form' do
    visit root_path

    # We expect to be redirected to the login page
    expect(page).to have_current_path(new_session_path)

    # Now check the login form elements
    expect(page).to have_field('email_address')
    expect(page).to have_field('password')
    expect(page).to have_button('Sign in')
    expect(page).to have_link('Forgot password?')
  end
end
