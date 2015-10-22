$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'box_view/version'

Gem::Specification.new do |s|
  s.name = 'greenhouse-box-view-ruby'
  s.version = BoxView::VERSION
  s.summary = 'Ruby wrapper for the BoxView API'
  s.description = 'The Box View API lets you upload documents and then generate secure and customized viewing sessions for them.'
  s.authors = ['Brandon Goldman', 'Tim Frey']
  s.email = %w(brandon.goldman@gmail.com timothy.frey@greenhouse.io)
  s.homepage = 'https://developers.box.com/view/'
  s.require_paths = %w{lib}

  s.add_dependency 'rest-client'
  s.add_dependency 'json'
  s.add_development_dependency 'rubocop'

  s.files = `git ls-files`.split("\n")
  s.require_paths = ['lib']
end
