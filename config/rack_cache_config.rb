set :verbose, true
set :metastore, 'file:/var/cache/rack/meta'
set :entitystore, 'file:/var/cache/rack/body'

on :receive do
  if request.header? 'Authorization', 'Expect'
    pass!
  else
    lookup!
  end
end

