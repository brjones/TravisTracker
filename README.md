# TravisTracker
TravisTracker is a sinatra + bootstrap app for displaying the status of travis-ci builds for multiple respositories and monit status from multiple servers.

## Installation

Clone the repository:

`git clone https://github.com/brjones/TravisTracker.git`

cd into TravisTracker's root directory:

`cd TravisTracker`

Run bundle install to install the gems:

`bundle install`

Run bower install to install all the Javascript dependencies:

`bower install`

Execute the assets generation (currently just copies CSS and JS files
 into /public)

`rake`

Run the web server:

`rackup`

Go to `localhost:9292` in your browser and it should just work...

##Configuration

To add your own repositories simple replace the placeholder repositories in the `config.yml` in the format of yourGithubAccount/yourRepositoryName

And don't forget to restart the app once you've made changes to the config!

