## Scout Rails Instrumentation Plugin

This plugin works together with http://scoutapp.com to provide insight into the
health and performance of your Rails application while it runs in production.

It captures Rails metrics silently in the background, imposing negligable 
overhead itself. 

Scoutapp.com uses the gathered information to give you a heads-up when 
something changes on your app (for example, if a certain controller action 
slows down a lot relative to the same day last week), or if it looks like 
your database queries are having problems (for example, if a query is slow 
because of a missing index).

Learn more at http://scoutapp.com.

## Installation

Install like any other plugin:

    cd [YOUR_RAILS_APP_ROOT]
    script/plugin install git://github.com/highgroove/scout_rails_instrumentation.git

The installer will print out a welcome message with further instructions 
(or see the instructions in welcome.txt). The gist of what you'll do:

* Log into your Scout account at http://scoutapp.com.
* In the web interface, tell Scout you're using Rails instrumentation, 
  and note the ID it provides.
* Set that ID in `config\scout.yml`
* Deploy your application, and see the metrics on Scoutapp.com

## What to Expect

This plugin is very gentle to you Rails application. It is designed to work
in conjunction with the Scout Agent (http://github.com/highgroove/scout_agent/tree/master),
but if the agent is not available, the plugin will log a message and your
application will continue to run normally, without the instrumentation.

* Negligable overhead: the plugin imposes 1 ms or less overhead per request.
* Unintrusive failure: if you forget to install the Scout Agent gem (the 
	plugin's only dependency), your application will continue to run normally.
* Easily enabled/disabled: after installation, you will have a new 
  `/config/scout.yml` configuration file. You can enable or disable 
  the plugin from any time from this configuration file.

## If You're Just Evaluating ...

Not 100% sure about Scout as a monitoring solution? Give it a try!
This plugin will not cause any problems in your application, and it's
trivial to disable/reenable/remove if you decide Scout isn't right for you.
We think you'll love being seeing exactly what's going on within your
production Rails application and getting trending alerts through scoutapp.com.

## Compatibility

This plugin is known to work with:
* Rails: 2.0 - 2.3.2
* Ruby: MRI 1.8.6-1.9.1, REE 1.8.6 

