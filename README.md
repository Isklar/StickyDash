StickyDash
==========

These are my configuration files for the Sticky Piston Network dashboard.

You can check out the default sample dashboard [here](pistonmc.com:3030/sample) and the latest version of the SPN dashboard [here](http://i.imgur.com/d4IUhVT.png)

[Disclaimer] - I have very limited knowledge of Ruby, Javascript and html. This is pretty much my first attempt at anything remotely complicated using them all, but its working so far which is nice.


About
---------
After looking at a few of the existing admin panels I realised that none of them supply the kind of thing I wanted: a quick and easy way to check all our servers are running smoothly without the hassle of logging into Minecraft
or being bogged down with extra features. I just wanted a simple, good looking page that displays all the info I need in one go.
This dashboard is built using [Dashing](http://dashing.io/) and utilises [JSONAPI](https://github.com/alecgorge/jsonapi) to retrieve various pieces of server information from player counts to tps.
This readme will be a quick introduction into Dashing and jsonapi and how to set up your own dashboard using them, if you have any questions feel free to message me on here or add me on skype (MrIsklar).

Installation
-------------

### Dashing

This is incredibly easy and only requires installation of Ruby 1.9+ if you don't have it already, Dashing's homepage has very simple and easy instructions for installation and has a brief overview of how it all works.
They can explain it a lot better than I can so I suggest reading over that first.

### JSONAPI

JSONAPI is installed like any other plugin and has incredibly easy configuration, I found that using the same username and password for each JSONAPI configuration was the easiest but you may wish to avoid this for security reasons.
Creating a user with only the required permissions needed for the widgets is a good idea as well.

### Extra Widgets

This dashboard utilises a few extra widgets, a good list of some useful ones can be found [here](https://github.com/Shopify/dashing/wiki/Additional-Widgets).

- [progress_bars](https://gist.github.com/mdirienzo/6716905)
- [rickshawgraph](https://gist.github.com/jwalton/6614023)
- [server_status](https://gist.github.com/willjohnson/6313986) (unimplemented)
- [Hotness](https://gist.github.com/rowanu/6246149) is also quite a good one.

Dashing provides an easy way to install widgets using `dashing install <Gist ID>` (make sure you're in your root folder for your dashboard before installing them.)

Getting Data Into Your Widgets
-------------------------------

JSONAPI works by sending a request payload to a specified server and receiving a json formatted response, the jobs in this dashboard use openURI to send and read the request and response, the response payload is
always an array hence the '[0]' on the end of each read. If JSONAPI is successful in getting the data you asked for, the response payload will contain a "success" key-value pair which will contain the data you requested.
Take note that if the request times out and you have no error checking in to catch it your dashboard will freeze until the request returns a success. As you can see I haven't implemented error checking into all my jobs yet.
JSONAPI provides some useful error codes if it doesnt return a success [JSON Response Structure](https://github.com/alecgorge/jsonapi#json-response-structure).

Now you've got the data from jsonapi you can send it to your desired widget / tile. Each widget has its own variables you can set that require various data types. Check the widget's .hmtl file for a list of bindings you can use.
To send the data to the widget the `send_event` function is called, you need to include your widgets ID (defined in dashboards/dashboard.erb) and the correct data type. Any tile can use a certain type of widget, for example the `Staff.rb` and 
`players.rb` both use the list widget.


