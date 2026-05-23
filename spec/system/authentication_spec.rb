# spec/system/authentication_spec.rb
require 'rails_helper'

RSpec.describe 'Authentication' do
  fixtures :all

  it 'logs in and thoroughly tests the home page with many Capybara helpers' do
    # 1. Navigation
    visit root_path

    # We expect to be redirected to the login page
    expect(page).to have_current_path(new_session_path)

    # 2. Form interaction
    fill_in 'email_address', with: 'john@company.com'
    fill_in 'password', with: '45Strong-Password67!'
    click_button 'Sign in'

    # 3. After login - we are now on the home page
    expect(page).to have_current_path(root_path)

    # === TEXT & CONTENT ASSERTIONS ===
    # have_content vs have_text
    expect(page).to have_content('Hello john@company.com!')
    # looks for visible text (recommended)
    expect(page).to have_text('You are a [')
    # exact match, including whitespace
    expect(page).to have_no_content('You are not signed in')
    # negative assertion

    # === LINKS & BUTTONS ===
    expect(page).to have_link('Sign Out')                     # <a> tag
    expect(page).to have_button('Trigger Live Update')        # <button> or <input type="submit">
    expect(page).to have_button('Import Job')

    # Subtle difference:
    # click_link    → only clicks <a> tags
    # click_button  → only clicks buttons / submit inputs
    # click_on      → tries both (most flexible)
    click_on 'Trigger Live Update'   # safest and most commonly used

    # === CSS & SELECTOR HELPERS ===
    expect(page).to have_css('.box')                    # any CSS selector
    expect(page).to have_css('div', text: 'One')        # element + text
    expect(page).to have_selector('div.box div', count: 3)  # count elements
    expect(page).to have_selector('.box', minimum: 1)
    # There is at least one element with the CSS class .box

    # === SCOPING ===
    within '.box' do
      expect(page).to have_content('One')
      expect(page).to have_content('Two')
      expect(page).to have_content('Three')
      expect(page).to have_no_content('Four')
    end

    # === ADMIN-ONLY CONTENT ===
    if users(:john).admin?   # or however you check role
      expect(page).to have_content("There are #{User.count} users")
    end

    # Take a screenshot of just one part of the page
    box = find('.box')
    File.binwrite("box_section.png", box.native.screenshot_as(:png))

    # click_link 'Sign Out'
    sign_out = find('a', text: 'Sign Out')
    sign_out.click

    expect(page).to have_current_path(new_session_path)
    expect(page).to have_content('Forgot password?')
    expect(page).to have_no_content('Sign Out')

    # === DEBUGGING HELPERS (uncomment when needed) ===
    # save_and_open_page          # saves an .html page
    # page.save_screenshot('home_page.png')
  end
end
