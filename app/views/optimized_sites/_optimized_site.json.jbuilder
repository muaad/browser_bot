json.extract! optimized_site, :id, :name, :root_url, :action, :enabled, :implementation, :created_at, :updated_at
json.url optimized_site_url(optimized_site, format: :json)
