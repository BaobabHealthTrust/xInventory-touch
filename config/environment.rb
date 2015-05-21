# Load the rails application
require File.expand_path('../application', __FILE__)
APP_VERSION = `git describe`.gsub("\n", "")
# Initialize the rails application
XInventory::Application.initialize!
