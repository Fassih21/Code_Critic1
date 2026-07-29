class ProjectPolicy < ApplicationPolicy

    def show?
        record.user.id == user.id
    end

    def create?
        record.user.id == user.id
    end

    def update?
        record.user.id == user.id
    end

    def destroy?
        record.user.id == user.id
    end

class Scope < ApplicationPolicy::Scope
        def resolve
            scope.where(user_id: user.id)
        end
    end
end