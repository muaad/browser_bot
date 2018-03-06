require 'test_helper'

class OptimizedSitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @optimized_site = optimized_sites(:one)
  end

  test "should get index" do
    get optimized_sites_url
    assert_response :success
  end

  test "should get new" do
    get new_optimized_site_url
    assert_response :success
  end

  test "should create optimized_site" do
    assert_difference('OptimizedSite.count') do
      post optimized_sites_url, params: { optimized_site: { action: @optimized_site.action, enabled: @optimized_site.enabled, implementation: @optimized_site.implementation, name: @optimized_site.name, root_url: @optimized_site.root_url } }
    end

    assert_redirected_to optimized_site_url(OptimizedSite.last)
  end

  test "should show optimized_site" do
    get optimized_site_url(@optimized_site)
    assert_response :success
  end

  test "should get edit" do
    get edit_optimized_site_url(@optimized_site)
    assert_response :success
  end

  test "should update optimized_site" do
    patch optimized_site_url(@optimized_site), params: { optimized_site: { action: @optimized_site.action, enabled: @optimized_site.enabled, implementation: @optimized_site.implementation, name: @optimized_site.name, root_url: @optimized_site.root_url } }
    assert_redirected_to optimized_site_url(@optimized_site)
  end

  test "should destroy optimized_site" do
    assert_difference('OptimizedSite.count', -1) do
      delete optimized_site_url(@optimized_site)
    end

    assert_redirected_to optimized_sites_url
  end
end
