class ReviewPolicy < ApplicationPolicy
    def show?
        record.code_file.project.user.id == user.id
    end
    def create?
        record.code_file.project.user.id == user.id
    end 
    def update?
        record.code_file.project.user.id == user.id
    end
    def destroy?
        record.code_file.project.user.id == user.id
    end
    class Scope < ApplicationPolicy::Scope
        def resolve
            scope.joins(code_file: :project).where(projects: { user_id: user.id })
        end
    end
end