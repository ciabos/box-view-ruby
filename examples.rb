# = Examples

# Require libraries and set API token
require 'pathname'
require_relative 'lib/box_view'
BoxView.api_token = 'YOUR_API_TOKEN'

# == Example #1
# 
# Upload a file to BoxView. We're uploading Form W4 from the IRS by URL.
puts 'Example #1 - Upload Form W4 from the IRS by URL.'
form_w4_url = 'http://www.irs.gov/pub/irs-pdf/fw4.pdf'
print '  Uploading... '
uuid = nil

begin
  uuid = BoxView::Document.upload(form_w4_url)
  puts 'success :)'
  puts '  UUID is ' + uuid
rescue BoxViewError => e
  puts 'failed :('
  puts '  Error Code: ' + e.code
  puts '  Error Message: ' + e.message
end

# == Example #2
# 
# Check the status of the file from Example #1.
puts ''
puts 'Example #2 - Check the status of the file we just uploaded.'
print '  Checking status... '

begin
  status = BoxView::Document.status(uuid)
  
  unless status.has_key? 'error'
    puts 'success :)'
    puts '  File status is ' + status['status'] + '.'
    puts '  File ' + (status['viewable'] ? 'is' : 'is not') + ' viewable.'
  else
    puts 'failed :('
    puts '  Error Message: ' + status['error']
  end
rescue BoxViewError => e
  puts 'failed :('
  puts '  Error Code: ' + e.code
  puts '  Error Message: ' + e.message
end

# == Example #3
# 
# Upload another file to BoxView. We're uploading Form W4 from the IRS as a PDF.
puts ''
puts 'Example #3 - Upload a sample .pdf as a file.'
uuid2 = nil
file_path = String(Pathname.new(File.expand_path(__FILE__)).dirname) + '/example-files/form-w4.pdf'

if File.exists? file_path
  file_handle = File.open(file_path, 'r+')
  print '  Uploading... '

  begin
    uuid2 = BoxView::Document.upload(file_handle)
    puts 'success :)'
    puts '  UUID is ' + uuid2
  rescue BoxViewError => e
    puts 'failed :('
    puts '  Error Code: ' + e.code
    puts '  Error Message: ' + e.message
  end
else
  puts '  Skipping because the sample pdf can\'t be found.'
end

# == Example #4
# 
# Check the status of both files we uploaded in Examples #1 and #3.
puts ''
puts 'Example #4 - Check the status of both files at the same time.'
print '  Checking statuses... '

begin
  statuses = BoxView::Document.status([uuid, uuid2])
  
  if statuses
    puts 'success :)'
    
    unless statuses[0].has_key? 'error'
      puts '  File #1 status is ' + statuses[0]['status'] + '.'
      puts '  File #1 ' + (statuses[0]['viewable'] ? 'is' : 'is not') + ' viewable.'
    else
      puts '  File #1 failed :('
      puts '  Error Message: ' . statuses[0]['error']
    end
    
    unless statuses[1].has_key? 'error'
      puts '  File #2 status is ' + statuses[1]['status'] + '.'
      puts '  File #2 ' + (statuses[1]['viewable'] ? 'is' : 'is not') + ' viewable.'
    else
      puts '  File #2 failed :('
      puts '  Error Message: ' . statuses[1]['error']
    end
  else
    puts 'failed :('
    puts '  Statuses were not returned.'
  end
rescue BoxViewError => e
  puts 'failed :('
  puts '  Error Code: ' + e.code
  puts '  Error Message: ' + e.message
end

# == Example #5
# 
# Wait ten seconds and check the status of both files again.
puts ''
puts 'Example #5 - Wait ten seconds and check the statuses again.'
print '  Waiting... '
sleep(10)
puts 'done.'
print '  Checking statuses... '

begin
  statuses = BoxView::Document.status([uuid, uuid2])
  
  if statuses
    puts 'success :)'
    
    unless statuses[0].has_key? 'error'
      puts '  File #1 status is ' + statuses[0]['status'] + '.'
      puts '  File #1 ' + (statuses[0]['viewable'] ? 'is' : 'is not') + ' viewable.'
    else
      puts '  File #1 failed :('
      puts '  Error Message: ' . statuses[0]['error']
    end
    
    unless statuses[1].has_key? 'error'
      puts '  File #2 status is ' + statuses[1]['status'] + '.'
      puts '  File #2 ' + (statuses[1]['viewable'] ? 'is' : 'is not') + ' viewable.'
    else
      puts '  File #2 failed :('
      puts '  Error Message: ' . statuses[1]['error']
    end
  else
    puts 'failed :('
    puts '  Statuses were not returned.'
  end
rescue BoxViewError => e
  puts 'failed :('
  puts '  Error Code: ' + e.code
  puts '  Error Message: ' + e.message
end

# == Example #6
# 
# Delete the file we uploaded from Example #1.
puts ''
puts 'Example #6 - Delete the first file we uploaded.'
print '  Deleting... '

begin
  deleted = BoxView::Document.delete(uuid)
  
  if deleted
    puts 'success :)'
    puts '  File was deleted.'
  else
    print 'failed :('
  end
rescue BoxViewError => e
  puts 'failed :('
  puts '  Error Code: ' + e.code
  puts '  Error Message: ' + e.message
end

# == Example #7
# 
# Download the file we uploaded from Example #3 as an original
puts ''
puts 'Example #7 - Download a file as an original.'
print '  Downloading... '

begin
  file = BoxView::Download.document(uuid2)
  filename = String(Pathname.new(File.expand_path(__FILE__)).dirname) + '/example-files/test-original.pdf'
  file_handle = File.open(filename, 'w')
  file_handle.write(file)
  puts 'success :)'
  puts '  File was downloaded to ' + filename + '.'
rescue BoxViewError => e
  puts 'failed :('
  puts '  Error Code: ' + e.code
  puts '  Error Message: ' + e.message
end

# == Example #8
# 
# Download the file we uploaded from Example #3 as a PDF
puts ''
puts 'Example #8 - Download a file as a PDF.'
print '  Downloading... '

begin
  file = BoxView::Download.document(uuid2, true)
  filename = String(Pathname.new(File.expand_path(__FILE__)).dirname) + '/example-files/test.pdf'
  file_handle = File.open(filename, 'w')
  file_handle.write(file)
  puts 'success :)'
  puts '  File was downloaded to ' + filename + '.'
rescue BoxViewError => e
  puts 'failed :('
  puts '  Error Code: ' + e.code
  puts '  Error Message: ' + e.message
end

# == Example #9
# 
# Download the file we uploaded from Example #3 with all options
puts ''
puts 'Example #9 - Download a file with all options.'
print '  Downloading... '

begin
  file = BoxView::Download.document(uuid2, true, true, 'all')
  filename = String(Pathname.new(File.expand_path(__FILE__)).dirname) + '/example-files/test-with-options.pdf'
  file_handle = File.open(filename, 'w')
  file_handle.write(file)
  puts 'success :)'
  puts '  File was downloaded to ' + filename + '.'
rescue BoxViewError => e
  puts 'failed :('
  puts '  Error Code: ' + e.code
  puts '  Error Message: ' + e.message
end

# == Example #10
# 
# Download the file we uploaded from Example #3 as a default thumbnail
puts ''
puts 'Example #10 - Download a default thumbnail from a file.'
print '  Downloading... '

begin
  file = BoxView::Download.thumbnail(uuid2)
  filename = String(Pathname.new(File.expand_path(__FILE__)).dirname) + '/example-files/thumbnail.png'
  file_handle = File.open(filename, 'w')
  file_handle.write(file)
  puts 'success :)'
  puts '  File was downloaded to ' + filename + '.'
rescue BoxViewError => e
  puts 'failed :('
  puts '  Error Code: ' + e.code
  puts '  Error Message: ' + e.message
end

# == Example #11
# 
# Download the file we uploaded from Example #3 as a large thumbnail
puts ''
puts 'Example #11 - Download a large thumbnail from a file.'
print '  Downloading... '

begin
  file = BoxView::Download.thumbnail(uuid2, 250, 250)
  filename = String(Pathname.new(File.expand_path(__FILE__)).dirname) + '/example-files/thumbnail-large.png'
  file_handle = File.open(filename, 'w')
  file_handle.write(file)
  puts 'success :)'
  puts '  File was downloaded to ' + filename + '.'
rescue BoxViewError => e
  puts 'failed :('
  puts '  Error Code: ' + e.code
  puts '  Error Message: ' + e.message
end

# == Example #12
# 
# Download extracted text from the file we uploaded from Example #3
puts ''
puts 'Example #12 - Download extracted text from a file.'
print '  Downloading... '

begin
  file = BoxView::Download.text(uuid2)
  filename = String(Pathname.new(File.expand_path(__FILE__)).dirname) + '/example-files/text.txt'
  file_handle = File.open(filename, 'w')
  file_handle.write(file)
  puts 'success :)'
  puts '  File was downloaded to ' + filename + '.'
rescue BoxViewError => e
  puts 'failed :('
  puts '  Error Code: ' + e.code
  puts '  Error Message: ' + e.message
end

# == Example #13
# 
# Create a session key for the file we uploaded from Example #3 with default
# options.
puts ''
puts 'Example #13 - Create a session key for a file with default options.'
print '  Creating... '
session_key = nil

begin
  session_key = BoxView::Session.create(uuid2)
  puts 'success :)'
  puts '  The session key is ' + session_key + '.'
rescue BoxViewError => e
  puts 'failed :('
  puts '  Error Code: ' + e.code
  puts '  Error Message: ' + e.message
end

# == Example #14
# 
# Create a session key for the file we uploaded from Example #3 all of the
# options.
puts ''
puts 'Example #14 - Create a session key for a file with all of the options.'
print '  Creating...'
session_key = nil

begin
  user = {'id' => 1,
          'name' => 'John BoxView'}
  session_key = BoxView::Session.create(uuid2, {'is_editable' => true,
                                                 'user' => user,
                                                 'filter' => 'all',
                                                 'is_admin' => true,
                                                 'is_downloadable' => true,
                                                 'is_copyprotected' => false,
                                                 'is_demo' => false,
                                                 'sidebar' => 'visible'})
  puts 'success :)'
  puts '  The session key is ' + session_key + '.'
rescue BoxViewError => e
  puts 'failed :('
  puts '  Error Code: ' + e.code
  puts '  Error Message: ' + e.message
end

# == Example #15
# 
# Delete the file we uploaded from Example #2.
puts ''
puts 'Example #15 - Delete the second file we uploaded.'
print '  Deleting... '

begin
  deleted = BoxView::Document.delete(uuid2)
  
  if deleted
    puts 'success :)'
    puts '  File was deleted.'
  else
    print 'failed :('
  end
rescue BoxViewError => e
  puts 'failed :('
  puts '  Error Code: ' + e.code
  puts '  Error Message: ' + e.message
end
