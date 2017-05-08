class Ability
  include CanCan::Ability

  def initialize(user)
    # ログインしていない場合は、空userを用意し判定に用いる
    # user ||= User.new

    # デフォルト
    cannot :manage, :hello # helloコントローラーにはアクセスできない
    #
    if user
      can :manage, :hello # ログインしていればhelloコントローラーにはアクセスできない
    end
  end
end
