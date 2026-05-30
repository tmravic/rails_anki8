# frozen_string_literal: true

# =============================================================================
# CUSTOM MOBILE-FU CONFIGURATION
# =============================================================================
#
# This initializer customizes the behavior of the mobile-fu gem.
#
# WHAT THE MOBILE-FU GEM NORMALLY DOES:
# - It uses Rack::MobileDetect middleware to analyze the User-Agent header.
# - It sets a request header called "X_MOBILE_DEVICE" (e.g. "iPhone", "Android").
# - It provides methods like is_mobile_device?, is_tablet_device?, mobile_device.
# - By default it can automatically switch request.format to :mobile for phones/tablets.
#
# WHY WE ARE OVERRIDING IT:
# In the production application this pattern is taken from, the team wanted
# more control, especially around letting users manually switch between
# "mobile view" and "desktop view" even when using a phone.
#
# The key mechanism they use is a cookie called `pc_style`:
#   - pc_style=0  → force mobile view even on desktop
#   - pc_style=1  → force desktop view even on a phone
#
# This file replaces the default is_mobile_device? and mobile_device methods
# with versions that respect that cookie.
# =============================================================================

module ActionController
  module MobileFu
    # This is a simplified/custom list of mobile user agents.
    # The real production version is longer.
    MOBILE_USER_AGENTS = 'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                         'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                         'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                         'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                         'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' +
                         'mobile|zune'

    module InstanceMethods
      # Custom version of is_mobile_device?
      #
      # The original gem just checks the User-Agent.
      # This version also respects the pc_style cookie so users can force
      # desktop or mobile rendering.
      def is_mobile_device?
        result = (request.user_agent.to_s.downcase =~ Regexp.new(ActionController::MobileFu::MOBILE_USER_AGENTS))

        if cookies[:pc_style] == "0"
          # User explicitly wants mobile view
          if result
            cookies.delete(:pc_style)
          else
            result = 99   # special marker meaning "treat as mobile because of cookie"
          end
        else
          cookies.delete(:pc_style) unless result
        end

        result
      end

      def mobile_device
        return "iPhone" if cookies[:pc_style] == "0"
        request.headers["X_MOBILE_DEVICE"]
      end
    end
  end
end
