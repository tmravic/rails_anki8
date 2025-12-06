# In a Rails application configured to use import maps to manage JS dependencies,
# the `pin` and `pin_all_from` commands in this file define mappings that make
# JS modules and packages available to your app directly without a build step.

# We are avoiding the entire Node.js toolchain,
# including npm install or yarn install,
# no need for package.json either.

# A "build step" typically refers to processes like transpiling (e.g., converting
# modern JavaScript to older versions for browser compatibility), bundling
# (combining multiple files into one), or minifying code, often using tools like
# npm/yarn, Webpack, or Babel. Import maps avoid this by allowing browsers to
# import ES modules natively from individual files or URLs, as long as the browser
# supports import maps (modern browsers do).

# Pin npm packages by running ./bin/importmap

pin "application"
# This uses `pin` to map the module name "application" to a specific file (likely
# app/javascript/application.js). It makes this module available for import in your
# JS code without needing to bundle or build it. No "to:" option means it defaults
# to looking for "application.js" in the asset pipeline.

pin "@hotwired/turbo-rails", to: "turbo.min.js"
# This uses `pin` to map "@hotwired/turbo-rails" to "turbo.min.js". The file
# "turbo.min.js" comes from the turbo-rails gem (not npm/yarn, hence no package.json
# is needed). It's served via the Rails asset pipeline. This allows importing the
# module like `import { Turbo } from "@hotwired/turbo-rails"` in your JS, without
# any build step—the browser resolves it directly via the import map.

pin "@hotwired/stimulus", to: "stimulus.min.js"
# Similar to above: Maps "@hotwired/stimulus" to "stimulus.min.js", provided by the
# stimulus-rails gem. You're correct—it's from a gem, not installed via npm/yarn.
# This pin makes the Stimulus library available for import without building.

pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
# Maps "@hotwired/stimulus-loading" to "stimulus-loading.js", also from the gem.
# Again, no build step; just direct mapping for browser import.

pin_all_from "app/javascript/controllers", under: "controllers"
# This uses `pin_all_from` to automatically pin all JS files in the specified
# directory (app/javascript/controllers) under the "controllers" namespace.
# For example, if there's a file like hello_controller.js in that dir, it becomes
# importable as `import { HelloController } from "controllers/hello_controller"`.
# No individual pins needed; it handles the set without a build step.

pin "@rails/actioncable", to: "actioncable.esm.js"
# Maps "@rails/actioncable" to "actioncable.esm.js", from the actioncable gem.
# Enables importing Action Cable for real-time features without bundling.

pin_all_from "app/javascript/channels", under: "channels"
# Similar to the controllers pin: Uses `pin_all_from` for all files in
# app/javascript/channels, under the "channels" namespace. E.g., a consumer.js
# file would be importable as `import { consumer } from "channels/consumer"`.
