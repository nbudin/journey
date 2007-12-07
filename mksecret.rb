require ‘digest/md5‘
puts [now = Time.now, now.usec, rand(0), $$, ‘journey‘].inject(Digest::MD5.new) { |md5, e| md5 << e.to_s }

