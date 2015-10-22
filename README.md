# box-view-ruby

## Introduction

box-view-ruby is a Ruby wrapper for the BoxView API.
The BoxView API lets you upload documents and then generate secure and customized viewing sessions for them.
Our API is based on REST principles and generally returns JSON encoded responses,
and in Ruby are converted to hashes unless otherwise noted.

## Installation

We suggest installing the library as a gem.

    gem install greenhouse-box-view-ruby

Require the library into any of your Ruby files.

If you have the gem installed:

    require 'box_view'
    
## Getting Started

You can see a number of examples on how to use this library in examples.rb.
These examples are interactive and you can run this file to see box-view-ruby in action.

To run these examples, open up examples.rb and change this line to show your API token:

    BoxView.api_token = 'YOUR_API_TOKEN'
    
Save the file, make sure the example-files directory is writeable, and then run examples.rb:

    ruby examples.rb
    
You should see 15 examples run with output in your terminal.
You can inspect the examples.rb code to see each API call being used.

To start using box-view-ruby in your code, set your API token:

    BoxView.api_token = 'YOUR_API_TOKEN'
    
And now you can start using the methods in BoxView::Document, BoxView::Download, and BoxView::Session.

Read on to find out more how to use box-view-ruby.
You can also find more detailed information about our API here:
https://developers.box.com/view/
