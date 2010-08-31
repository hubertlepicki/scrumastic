# encoding: UTF-8

class UserSearchesController < AuthenticatedController
  def create
    conditions = {confirmation_token: nil}
    conditions["$or"] = [{name: /#{params[:q]}/i},
                         {nickname: /#{params[:q]}/i},
                         {email: /#{params[:q]}/i}] unless params[:q].blank?
    conditions[:_id] = {"$nin" => MongoUtils.from_string(params[:exclude_ids])} unless params[:exclude_ids].blank?

    @people = User.where conditions
  end
end
