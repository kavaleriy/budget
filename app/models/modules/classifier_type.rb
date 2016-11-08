class Modules::ClassifierType
  include Mongoid::Document

  field :name, type: String
  field :code, type: Array
  field :payer, type: Boolean
  field :receipt, type: Boolean

  def self.all_types
    unwind = {"$unwind"=>"$code"}
    group_stage = {
        "$group" => {
            "_id" => nil,
            "codes" => { "$push" => "$code" }
        }
    }
    project={
        "$project"=>{"_id"=>0, "code"=>"$codes"}
    }
    self.collection.aggregate([unwind, group_stage, project])[0][:code]
  end
end