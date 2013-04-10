[![Build Status](https://travis-ci.org/pivotal/whiteboard.png?branch=master)](https://travis-ci.org/pivotal/whiteboard)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/pivotal/whiteboard)

Goals
=====
Whiteboard is an app which aims to increase the effectiveness of office wide standups, and increase communication with the technical community by sharing what we learn with the outside world.  It does this by making two things easy - emailing a summary of standup to everyone in the company and by creating a blog post of the items which are deemed of public interest.

Background
==========
At Pivotal Labs we have an office wide standup every morning at 9:06 (right after breakfast). The current format is new faces (who's new in the office), helps (things people are stuck on) and interestings (things that might be of interest to the office).

Before Whiteboard, one person madly scribbled notes, and one person ran standup using a physical whiteboard as a guide to things people wanted to remember to talk about.  Whiteboard provides an easy interface for people to add items they want to talk about, and then a way to take those items and assemble them into a blog post and an email with as little effort as possible.  The idea is to shift the writing to the person who knows about the item, and reduce the role of the person running standup to an editor.

Features
========
- Add New Faces, Helps and Interesting
- Summarize into posts
- Two click email sending (the second click is for safety)
- Two click Posts to Wordpress (untransformed markdown at the moment)
- Allow authorized IP addresses to access the board without restriction
- Allow users to sign in with Google Apps SSO if outside authorized IPs

Usage
=====
Deploy to Heroku. Tell people in the office to use it.  At standup, go over the board, then add a title and click 'create post'.  The board is then cleared for the next day, and you can edit the post at your leisure and deliver it when ready.

Development
===========
Whiteboard is a Rails 3 app. It uses rspec with capybara for request specs.  Please add tests if you are adding code.

Whiteboard [is on Pivotal Tracker](https://www.pivotaltracker.com/projects/560741).

The following environment variables are necessary for posting to a wordpress blog.

    export WORDPRESS_BLOG_HOST=<blog server>
    export WORDPRESS_BASIC_AUTH_USER=<user> #optional
    export WORDPRESS_BASIC_AUTH_PASSWORD=<password> #optional
    export WORDPRESS_XMLRPC_ENDPOINT_PATH=/wordpress/xmlrpc.php
    export WORDPRESS_USER=<username>
    export WORDPRESS_PASSWORD=<password>

The following environment variables are necessary for posting to email via sendgrid.

    export EMAIL_DELIVERY_ADDRESS=<mailinglist@example.com>
    export SENDGRID_USERNAME=<username>
    export SENDGRID_PASSWORD=<password>

Deployment
==========
	heroku apps:create sf-whiteboard --stack cedar
	heroku addons:add sendgrid:starter
	heroku config:add WORDPRESS_USER=username WORDPRESS_PASSWORD=password WORDPRESS_BLOG_HOST=blogname.wordpress.com
	heroku config:add WORDPRESS_BASIC_AUTH_USER=<user> WORDPRESS_BASIC_AUTH_PASSWORD=<password>
	heroku config:add WORDPRESS_XMLRPC_ENDPOINT_PATH=/wordpress/xmlrpc.php
	heroku config:add EMAIL_DELIVERY_ADDRESS=mailinglist@example.com
	heroku config:add AUTHORIZED_IP_ADDRESSES='{ :sf => [ IPAddr.new("10.0.0.1/24") ] }'
	heroku config:add EXCEPTIONAL_API_KEY=<you exceptional API key>
	git push heroku

Author
======
Whiteboard was written by [Matthew Kocher](https://github.com/mkocher).

License
=======
Whiteboard is MIT Licensed. See MIT-LICENSE for details.
