require File.expand_path('../test_helper', __FILE__)

class UsersControllerTest < ActionController::TestCase
  def setup
    setup_db

    @users_count = 20
    @users_count.times do |i|
      User.create(:login => "user#{user_num(i)}", :email => "user#{user_num(i)}@example.com", :change => i % 2)
    end
  end

  def teardown
    teardown_db
  end

  test "default" do
    get(:index)

    assert_table do
      assert_colgroup
      assert_thead
      assert_tbody
      assert_user(1, 0)
      assert_user(@users_count, @users_count - 1)
    end
  end

  test "order" do
    params = { :order => 'login', :sort => 1 }
    get(:index, params)

    assert_table do
      assert_colgroup
      assert_thead
      assert_tbody
      assert_user(1, @users_count - 1)
      assert_user(@users_count, 0)
    end

    get(:index, :order => 'login', :sort => 0)

    assert_table do
      assert_user(1, 0)
      assert_user(@users_count, @users_count - 1)
    end

    # поле сортировки - зарезервированное слово в mysql
    assert_nothing_raised do
      get(:index, :order => 'change')
    end
  end

  test "no_colgroup" do
    get(:index, :no_colgroup => 1)

    assert_table do
      assert_no_colgroup
      assert_thead
      assert_tbody
    end
  end

  test "no_thead" do
    get(:index, :no_thead => 1)

    assert_table do
      assert_colgroup
      assert_no_thead
      assert_tbody
    end
  end

  test "custom_row" do
    get(:index, :custom_row => 1)

    assert_table do
      @users_count.times do |i|
        assert_select "tbody > tr:nth-child(#{i + 1})[id=user#{user_num(i)}]", 1
      end
    end
  end

  protected

  def user_num(num)
    sprintf("%03d", num)
  end

  def user_id(num)
    num + 1
  end

  def assert_table
    assert_select "table#users" do
      yield
    end
  end

  def assert_colgroup
    assert_select "colgroup" do
      assert_select "col", 3
      assert_select "col:nth-child(1).login", 1
      assert_select "col:nth-child(2).email", 1
      assert_select "col:nth-child(3).mail", 1
    end
  end

  def assert_no_colgroup
    assert_select "colgroup", false
  end

  def assert_thead
    assert_select "thead" do
      assert_select "tr", 1
      assert_select "tr:nth-child(1) > th:nth-child(1) a", "Login"
      assert_select "tr:nth-child(1) > th:nth-child(2) a", "Email"
    end
  end

  def assert_no_thead
    assert_select "thead", false
  end

  def assert_tbody(rows = nil)
    assert_select "tbody > tr", rows || @users_count
  end

  def assert_user(row, user = nil)
    user ||= row
    td = "tbody > tr:nth-child(#{row}) > td:nth-child"

    assert_select "#{td}(1)", "user#{user_num(user)}"
    assert_select "#{td}(1) > a[href=#{user_path(user_id(user))}]", "user#{user_num(user)}"
    assert_select "#{td}(2)", "user#{user_num(user)}@example.com"
    assert_select "#{td}(3)", "user#{user_num(user)}@example.com"
  end
end