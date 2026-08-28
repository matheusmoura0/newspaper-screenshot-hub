require "test_helper"

class Admin::NewspapersControllerTest < ActionDispatch::IntegrationTest
  test "member cannot access admin area" do
    sign_in_as users(:two)
    get admin_newspapers_url
    assert_redirected_to root_url
  end

  test "admin can access newspapers" do
    sign_in_as users(:one)
    get admin_newspapers_url
    assert_response :success
  end

  test "admin can queue one manual capture" do
    sign_in_as users(:one)

    assert_enqueued_jobs 1, only: CaptureRunJob do
      post capture_admin_newspaper_url(newspapers(:one))
    end

    assert_redirected_to admin_newspaper_url(newspapers(:one))
    assert_equal "Captura manual adicionada à fila.", flash[:notice]
  end

  test "admin can queue selected newspapers in one batch" do
    sign_in_as users(:one)

    assert_enqueued_jobs 1, only: CaptureRunJob do
      post capture_selected_admin_newspapers_url, params: {
        newspaper_ids: [ newspapers(:one).id, newspapers(:two).id ]
      }
    end

    assert_redirected_to admin_newspapers_url
    assert_equal "2 jornais adicionados à fila de captura.", flash[:notice]

    activity = users(:one).activity_logs.order(:created_at).last
    assert_equal "newspapers.capture_requested", activity.action
    assert_equal 2, activity.metadata["count"]
  end

  test "batch capture requires at least one newspaper" do
    sign_in_as users(:one)

    assert_no_enqueued_jobs only: CaptureRunJob do
      post capture_selected_admin_newspapers_url
    end

    assert_redirected_to admin_newspapers_url
    assert_equal "Selecione pelo menos um jornal para capturar.", flash[:alert]
  end
end
